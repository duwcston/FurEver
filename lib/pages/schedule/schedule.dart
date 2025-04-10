import 'package:flutter/material.dart';
import 'package:furever/pages/schedule/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  DateTime _selectedDay = DateTime.now();
  late final ValueNotifier<Map<DateTime, List<Task>>> _tasksNotifier =
       ValueNotifier({});
  // final TextEditingController _taskController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

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
                    _timeController.text = picked.format(context);
                  }
                },
                decoration: const InputDecoration(labelText: 'Start Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  _addTask(
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                    _timeController.text.trim(),
                  );
                  Navigator.pop(context);
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
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Selected date: ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2050),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                    });
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
                      final hasTask = _tasksNotifier.value.containsKey(
                        normalizedDay,
                      );

                      if (hasTask) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<Map<DateTime, List<Task>>>(
                  valueListenable: _tasksNotifier,
                  builder: (context, tasksMap, _) {
                    final key = _normalizeDate(_selectedDay);
                    final tasksForDay = tasksMap[key] ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tasksForDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDay[index];
                        return Card(
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(
                              "${task.description} - ${task.time.format(context)}",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
