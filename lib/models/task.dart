import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  TimeOfDay time;

  Task({
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  String toString() {
    return 'Event{title: $title, description: $description, startTime: $time}';
  }
}