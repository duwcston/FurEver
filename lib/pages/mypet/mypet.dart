import 'package:flutter/material.dart';
import 'package:furever/models/pet.dart';

class MyPet extends StatefulWidget {
  const MyPet({super.key, required this.pet});

  final Pet pet;

  @override
  State<MyPet> createState() => _MyPetState();
}

class _MyPetState extends State<MyPet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(title: const Text('My Pet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [_petInfo()],
          ),
        ),
      ),
    );
  }

  _petInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffadf8fd),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Pet Information",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),
          _infoRow("Name", widget.pet.name),
          _infoRow("Breed", widget.pet.breed),
          _infoRow("Age", widget.pet.age.toString()),
          _infoRow("Weight", widget.pet.weight.toString()),
          _infoRow("Sex", widget.pet.sex),
          const SizedBox(height: 16),
          Text(
            "Feeding Info",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Feed Buddy twice a day with high-quality dog food. Ensure fresh water is always available.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            "Grooming Tips",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Brush Buddy's coat daily to prevent matting. Bathe him once a month or as needed.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
