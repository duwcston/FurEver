import 'package:flutter/material.dart';
import 'package:furever/models/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:furever/database/schedule_manager.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() {
    return _ScheduleState();
  }
}

class _ScheduleState extends State<Schedule> {
  DateTime _selectedDay = DateTime.now();
  final ScheduleManager _scheduleManager = ScheduleManager();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Set to track completed tasks by their title (could use a unique ID in production)
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    await _scheduleManager.fetchTasksFromFirestore();
    setState(() {});
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

                  // Add task locally
                  _scheduleManager.addTask(
                    title,
                    description,
                    time,
                    _selectedDay,
                  );

                  // Upload to Firestore
                  await _scheduleManager.uploadTaskToDb(
                    title,
                    description,
                    time,
                    _selectedDay,
                  );

                  // Clear the text controllers
                  _titleController.clear();
                  _descriptionController.clear();
                  _timeController.clear();

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

  TableCalendar<dynamic> _calendar() {
    return TableCalendar(
      focusedDay: _selectedDay,
      firstDay: DateTime(2020),
      lastDay: DateTime(2050),
      calendarFormat: CalendarFormat.month,
      daysOfWeekVisible: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      onPageChanged: (focusedDay) {
        setState(() {
          _selectedDay = focusedDay;
        });
      },
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final normalizedDay = ScheduleManager.normalizeDate(day);
          final hasTask = _scheduleManager.tasksNotifier.value.containsKey(
            normalizedDay,
          );

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

  ValueListenableBuilder<Map<DateTime, List<Task>>> _taskList() {
    return ValueListenableBuilder<Map<DateTime, List<Task>>>(
      valueListenable: _scheduleManager.tasksNotifier,
      builder: (context, tasksMap, _) {
        final key = ScheduleManager.normalizeDate(_selectedDay);
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
                // trailing: IconButton(
                //   icon: Icon(
                //     isCompleted
                //         ? Icons.check_circle
                //         : Icons.check_circle_outline,
                //     color: isCompleted ? Colors.green : null,
                //   ),
                //   onPressed: () {
                //     setState(() {
                //       if (isCompleted) {
                //         _completedTasks.remove(task.title);
                //       } else {
                //         _completedTasks.add(task.title);
                //       }
                //     });

                //     // Show SnackBar at the bottom of the screen
                //     final snackBar = SnackBar(
                //       content: Text(
                //         isCompleted
                //             ? 'Unmarked "${task.title}" as uncompleted'
                //             : 'Marked "${task.title}" as completed',
                //       ),
                //       duration: const Duration(seconds: 2),
                //       behavior: SnackBarBehavior.fixed,
                //     );

                //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
                //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                //   },
                // ),
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
}
