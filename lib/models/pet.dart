import 'package:flutter/material.dart';

class Pet {
  const Pet({
    Key? key,
    required this.name,
    required this.breed,
    required this.sex,
    required this.age,
    required this.weight,
  });

  final String name;
  final String breed;
  final String sex;
  final int age;
  final double weight;
}
