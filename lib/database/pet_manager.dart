import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furever/models/pet.dart';

class PetManager {
  static List<Pet> petList = [];

  // Public method to fetch pets from Firestore
  static Future<List<Pet>> fetchPetsFromFirestore() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("pets").get();

      petList =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Handle the case where petWeight might be stored as an int
            double weight = 0.0;
            var rawWeight = data['petWeight'];
            if (rawWeight is int) {
              weight = rawWeight.toDouble();
            } else if (rawWeight is double) {
              weight = rawWeight;
            }

            return Pet(
              name: data['petName'] ?? '',
              breed: data['petBreed'] ?? '',
              sex: data['petSex'] ?? '',
              age: data['petAge'] ?? 0,
              weight: weight,
            );
          }).toList();

      return petList;
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }
}
