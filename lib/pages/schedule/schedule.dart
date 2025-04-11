import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furever/models/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() {
    return _ScheduleState();
  }
}

class _ScheduleState extends State<Schedule> {
  DateTime _selectedDay = DateTime.now();
  late final ValueNotifier<Map<DateTime, List<Task>>> _tasksNotifier =
      ValueNotifier({});
  // final TextEditingController _taskController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Set to track completed tasks by their title (could use a unique ID in production)
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    fetchTasksFromFirestore();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  TimeOfDay parseTimeOfDay(String input) {
    final cleanInput =
        input
            .replaceAll(RegExp(r'[\u00A0\u2000-\u200F\u202F\u205F\u3000]'), ' ')
            .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
            .trim();

    final format = DateFormat('h:mm a'); // 'hh:mm a' like "02:45 PM"
    final time = format.parse(cleanInput);
    return TimeOfDay.fromDateTime(time);
  }

  Future<void> fetchTasksFromFirestore() async {
    try {
      // Get all tasks from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("tasks").get();

      // Create a new map to store the tasks by date
      final tasksMap = Map<DateTime, List<Task>>.from(_tasksNotifier.value);

      // Clear the existing tasks to avoid duplicates when refreshing
      tasksMap.clear();

      // Process each document in the query results
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamp to DateTime
        final Timestamp timestamp = data["taskTime"] as Timestamp;
        final DateTime taskDateTime = timestamp.toDate();

        // Create a normalized date for grouping tasks by day
        final DateTime normalizedDate = _normalizeDate(taskDateTime);

        // Extract hour and minute for TimeOfDay
        final TimeOfDay taskTime = TimeOfDay(
          hour: taskDateTime.hour,
          minute: taskDateTime.minute,
        );

        // Create a Task object
        final task = Task(
          title: data["taskTitle"] ?? "",
          description: data["taskDescription"] ?? "",
          time: taskTime,
        );

        // Add the task to the map, grouping by normalized date
        tasksMap.putIfAbsent(normalizedDate, () => []).add(task);
      }

      // Update the tasks notifier with the new map
      _tasksNotifier.value = tasksMap;
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> uploadTaskToDb(
    String title,
    String description,
    String timeString,
  ) async {
    try {
      // Parse the time string and combine with selected date
      final timeOfDay = parseTimeOfDay(timeString);

      // Create a DateTime that combines the selected date with the time
      final dateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      final data = await FirebaseFirestore.instance.collection("tasks").add({
        "taskTitle": title,
        "taskDescription": description,
        "taskTime": Timestamp.fromDate(
          dateTime,
        ), // Firebase Timestamp for the specific task time
      });
      print('Task uploaded successfully with id: ${data.id}');
    } catch (e) {
      print('Error uploading task: $e');
    }
  }

  void _addTask(String title, String description, String startTime) {
    final key = _normalizeDate(_selectedDay);
    final task = Task(
      title: title,
      description: description,
      time: parseTimeOfDay(startTime),
    );
    final currentTasks = Map<DateTime, List<Task>>.from(_tasksNotifier.value);
    currentTasks.putIfAbsent(key, () => []).add(task);
    _tasksNotifier.value = currentTasks;

    _titleController.clear();
    _descriptionController.clear();
    _timeController.clear();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    if (context.mounted) {
                      _timeController.text = picked.format(context);
                    }
                  }
                },
                decoration: const InputDecoration(labelText: 'Start Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_titleController.text.trim().isNotEmpty) {
                  // Store the values before they get cleared
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();
                  final time = _timeController.text.trim();

                  _addTask(title, description, time);
                  await uploadTaskToDb(title, description, time);

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                _daySelected(),
                _calendar(),
                const SizedBox(height: 10),
                _taskList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding _daySelected() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        'Selected date: ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  ValueListenableBuilder<Map<DateTime, List<Task>>> _taskList() {
    return ValueListenableBuilder<Map<DateTime, List<Task>>>(
      valueListenable: _tasksNotifier,
      builder: (context, tasksMap, _) {
        final key = _normalizeDate(_selectedDay);
        final tasksForDay = tasksMap[key] ?? [];

        if (tasksForDay.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No tasks for this day',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasksForDay.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final task = tasksForDay[index];
            final isCompleted = _completedTasks.contains(task.title);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.pets, color: Colors.blue[700]),
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration:
                        isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                    color: isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        decoration:
                            isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.time.format(context),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: isCompleted ? Colors.green : null,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isCompleted) {
                        _completedTasks.remove(task.title);
                      } else {
                        _completedTasks.add(task.title);
                      }
                    });

                    // Show SnackBar at the bottom of the screen
                    final snackBar = SnackBar(
                      content: Text(
                        isCompleted
                            ? 'Unmarked "${task.title}" as uncompleted'
                            : 'Marked "${task.title}" as completed',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.fixed,
                    );

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  TableCalendar<dynamic> _calendar() {
    return TableCalendar(
      focusedDay: _selectedDay,
      firstDay: DateTime(2020),
      lastDay: DateTime(2050),
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
        });
        // Refresh tasks when a new day is selected
        fetchTasksFromFirestore();
      },
      onFormatChanged: (format) {
        setState(() {
          if (format == CalendarFormat.month) {
            format = CalendarFormat.week;
          } else {
            format = CalendarFormat.week;
          }
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final normalizedDay = _normalizeDate(day);
          final hasTask = _tasksNotifier.value.containsKey(normalizedDay);

          if (hasTask) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blueAccent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('${day.day}', style: TextStyle(color: Colors.black)),
            );
          }

          return null;
        },
      ),
    );
  }
}
