import 'package:flutter/material.dart';

class AddPetForm extends StatefulWidget {
  const AddPetForm({Key? key, required this.onPetAdded}) : super(key: key);

  final Function(String name) onPetAdded;

  @override
  _AddPetFormState createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  String? breed;
  String? name;
  int? age;
  double? weight;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Pet'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Pet Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the pet name';
                }
                return null;
              },
              onSaved: (value) {
                name = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Dog Breed'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the breed';
                }
                return null;
              },
              onSaved: (value) {
                breed = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the age';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) {
                age = int.parse(value!);
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the weight';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) {
                weight = double.parse(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              // Call the onPetAdded callback with the pet's name
              widget.onPetAdded(name!);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
