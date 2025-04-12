import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furever/models/pet.dart';
import 'package:furever/database/pet_manager.dart';

class AddPetForm extends StatefulWidget {
  const AddPetForm({super.key, required this.onPetAdded});

  final Function(Pet pet) onPetAdded;

  @override
  State<AddPetForm> createState() {
    return _AddPetFormState();
  }
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? breed;
  String? sex;
  int? age;
  double? weight;

  @override
  void initState() {
    super.initState();
    sex = 'Male'; // Default value for sex
  }

  Future<void> uploadPetToDb() async {
    try {
      final data = await FirebaseFirestore.instance.collection("pets").add({
        "petName": name.toString().trim(),
        "petBreed": breed.toString().trim(),
        "petSex": sex.toString().trim(),
        "petAge": age,
        "petWeight": weight,
      });
      print('Pet uploaded successfully with id: ${data.id}');
    } catch (e) {
      print('Error uploading pet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pet Name Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                        hintText: 'Enter your pet\'s name',
                        prefixIcon: const Icon(Icons.pets, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
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
                    const SizedBox(height: 16),

                    // Breed Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Dog Breed',
                        hintText: 'Enter your dog\'s breed',
                        prefixIcon: const Icon(
                          Icons.category,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
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
                    const SizedBox(height: 16),

                    // Sex Selection
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.pets, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Text(
                                  'Sex:',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Male',
                                        groupValue: sex,
                                        activeColor: Colors.blue,
                                        onChanged:
                                            (value) =>
                                                setState(() => sex = value),
                                      ),
                                      const Text('Male'),
                                      const SizedBox(width: 12),
                                      Radio<String>(
                                        value: 'Female',
                                        groupValue: sex,
                                        activeColor: Colors.pink,
                                        onChanged:
                                            (value) =>
                                                setState(() => sex = value),
                                      ),
                                      const Text('Female'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Age Selection
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Age (years)',
                        hintText: 'Select age',
                        prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      value: age,
                      items:
                          List.generate(21, (index) => index)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an age';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          age = value;
                        });
                      },
                      onSaved: (value) {
                        age = value;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),

                    // Weight Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'Enter your pet\'s weight',
                        prefixIcon: const Icon(
                          Icons.monitor_weight,
                          color: Colors.grey,
                        ),
                        suffixText: 'kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
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

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Call the onPetAdded callback with the pet info
                        final pet = Pet(
                          name: name!,
                          breed: breed!,
                          sex: sex!,
                          age: age!,
                          weight: weight!,
                        );
                        widget.onPetAdded(pet);
                        await uploadPetToDb(); // Upload pet to Firestore
                        await PetManager.fetchPetsFromFirestore(); // Fetch updated pet list
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add Pet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
