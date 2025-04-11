import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  TimeOfDay time;
  DateTime date;

  Task({
    required this.title,
    required this.description,
    required this.time,
    required this.date,
  });

  @override
  String toString() {
    return 'Event{title: $title, description: $description, startTime: $time, date: $date}';
  }
}
