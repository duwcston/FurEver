import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furever/models/task.dart';
import 'package:intl/intl.dart';

class ScheduleManager {
  // Singleton pattern for global access
  static final ScheduleManager _instance = ScheduleManager._internal();
  factory ScheduleManager() => _instance;
  ScheduleManager._internal();

  // Map to store tasks by date
  final ValueNotifier<Map<DateTime, List<Task>>> tasksNotifier = ValueNotifier(
    {},
  );

  // Normalize date to compare dates without time
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Parse a time string to TimeOfDay
  static TimeOfDay parseTimeOfDay(String input) {
    final cleanInput =
        input
            .replaceAll(RegExp(r'[\u00A0\u2000-\u200F\u202F\u205F\u3000]'), ' ')
            .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
            .trim();

    final format = DateFormat('h:mm a'); // 'hh:mm a' like "02:45 PM"
    final time = format.parse(cleanInput);
    return TimeOfDay.fromDateTime(time);
  }

  // Fetch all tasks from Firestore
  Future<void> fetchTasksFromFirestore() async {
    try {
      // Get all tasks from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("tasks").get();

      // Create a new map to store the tasks by date
      final tasksMap = Map<DateTime, List<Task>>.from(tasksNotifier.value);

      // Clear the existing tasks to avoid duplicates when refreshing
      tasksMap.clear();

      // Process each document in the query results
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamp to DateTime
        final Timestamp timestamp = data["taskTime"] as Timestamp;
        final DateTime taskDateTime = timestamp.toDate();

        // Create a normalized date for grouping tasks by day
        final DateTime normalizedDate = normalizeDate(taskDateTime);

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
          date: taskDateTime,
        );

        // Add the task to the map, grouping by normalized date
        tasksMap.putIfAbsent(normalizedDate, () => []).add(task);
      }

      // Update the tasks notifier with the new map
      tasksNotifier.value = tasksMap;
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  // Fetch only upcoming tasks (limited number)
  Future<List<Task>> fetchUpcomingTasks() async {
    try {
      // Get all tasks from Firestore sorted by date
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection("tasks")
              .orderBy("taskTime")
              .get();

      final List<Task> tasks = [];
      final DateTime now = DateTime.now();

      // Process each document
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamp to DateTime
        final Timestamp timestamp = data["taskTime"] as Timestamp;
        final DateTime taskDateTime = timestamp.toDate();

        // Only include future tasks (today and later)
        if (taskDateTime.isAfter(
          DateTime(now.year, now.month, now.day - 1, now.hour, now.minute),
        )) {
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
            date: taskDateTime,
          );

          tasks.add(task);
        }
      }

      // Limit to specified number of upcoming tasks
      return tasks.toList();
    } catch (e) {
      print('Error fetching upcoming tasks: $e');
      return [];
    }
  }

  // Add a new task to Firestore
  Future<void> uploadTaskToDb(
    String title,
    String description,
    String timeString,
    DateTime selectedDay,
  ) async {
    try {
      // Parse the time string and combine with selected date
      final timeOfDay = parseTimeOfDay(timeString);

      // Create a DateTime that combines the selected date with the time
      final dateTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
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

      // Refresh the task list after adding a new task
      await fetchTasksFromFirestore();
    } catch (e) {
      print('Error uploading task: $e');
    }
  }

  // Add a task to the local tasksNotifier
  void addTask(
    String title,
    String description,
    String startTime,
    DateTime selectedDay,
  ) {
    final key = normalizeDate(selectedDay);
    final task = Task(
      title: title,
      description: description,
      time: parseTimeOfDay(startTime),
      date: DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        parseTimeOfDay(startTime).hour,
        parseTimeOfDay(startTime).minute,
      ),
    );

    final currentTasks = Map<DateTime, List<Task>>.from(tasksNotifier.value);
    currentTasks.putIfAbsent(key, () => []).add(task);
    tasksNotifier.value = currentTasks;
  }
}
