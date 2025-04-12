import 'package:flutter/material.dart';
import 'package:furever/models/pet.dart';
import 'package:furever/services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPet extends StatefulWidget {
  const MyPet({super.key, required this.pet});

  final Pet pet;

  @override
  State<MyPet> createState() => _MyPetState();
}

class _MyPetState extends State<MyPet> {
  bool _isLoading = true;
  String _feedingInfo = "Loading...";
  String _groomingTips = "Loading...";
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _loadPetCareInfo(forceRegenerate: false);
  }

  Future<void> _loadPetCareInfo({bool forceRegenerate = false}) async {
    setState(() {
      _isLoading = true;
      _feedingInfo = "Loading feeding recommendations...";
      _groomingTips = "Loading grooming tips...";
    });

    try {
      // First try to get existing care info from Firestore
      if (!forceRegenerate) {
        final existingCareInfo = await _getPetCareInfoFromFirestore();

        if (existingCareInfo != null) {
          // Use existing data from Firestore
          setState(() {
            _feedingInfo = existingCareInfo['feedingInfo'];
            _groomingTips = existingCareInfo['groomingTips'];
            _isLoading = false;
          });
          return;
        }
      }

      // If no existing data or forced regenerate, call Gemini API
      final petCareInfo = await _geminiService.generatePetCareInfo(
        petName: widget.pet.name,
        breed: widget.pet.breed,
        sex: widget.pet.sex,
        age: widget.pet.age,
        weight: widget.pet.weight,
      );

      // Save the information to Firestore
      await _savePetCareInfoToFirestore(
        feedingInfo: petCareInfo.feedingInfo,
        groomingTips: petCareInfo.groomingTips,
      );

      setState(() {
        _feedingInfo = petCareInfo.feedingInfo;
        _groomingTips = petCareInfo.groomingTips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _feedingInfo =
            "Could not generate feeding information. Please try again later.";
        _groomingTips =
            "Could not generate grooming tips. Please try again later.";
        _isLoading = false;
      });
      print("Error loading pet care info: $e");
    }
  }

  Future<Map<String, dynamic>?> _getPetCareInfoFromFirestore() async {
    try {
      // Query to find the pet document by matching properties
      final QuerySnapshot petSnapshot =
          await FirebaseFirestore.instance
              .collection("pets")
              .where("petName", isEqualTo: widget.pet.name)
              .where("petBreed", isEqualTo: widget.pet.breed)
              .get();

      if (petSnapshot.docs.isNotEmpty) {
        // Get the first matching pet document
        final petDoc = petSnapshot.docs.first;

        // Try to get the care info document
        final careInfoDoc =
            await FirebaseFirestore.instance
                .collection("pets")
                .doc(petDoc.id)
                .collection("information")
                .doc("careInfo")
                .get();

        // If the document exists and has data, return it
        if (careInfoDoc.exists && careInfoDoc.data() != null) {
          return careInfoDoc.data()!;
        }
      }
      return null; // Return null if no data found
    } catch (e) {
      print("Error retrieving pet care info from Firestore: $e");
      return null;
    }
  }

  Future<void> _savePetCareInfoToFirestore({
    required String feedingInfo,
    required String groomingTips,
  }) async {
    try {
      // Query to find the pet document by matching properties
      final QuerySnapshot petSnapshot =
          await FirebaseFirestore.instance
              .collection("pets")
              .where("petName", isEqualTo: widget.pet.name)
              .where("petBreed", isEqualTo: widget.pet.breed)
              .get();

      if (petSnapshot.docs.isNotEmpty) {
        // Get the first matching pet document
        final petDoc = petSnapshot.docs.first;

        // Create or update the information subcollection
        await FirebaseFirestore.instance
            .collection("pets")
            .doc(petDoc.id)
            .collection("information")
            .doc("careInfo") // Use a fixed document ID for easier retrieval
            .set({
              "feedingInfo": feedingInfo,
              "groomingTips": groomingTips,
              "lastUpdated": FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print("Error saving pet care info to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(title: const Text('My Pet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [_petInfo()],
            ),
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
            "${widget.pet.name}'s Information",
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
          _isLoading
              ? _loadingIndicator()
              : Text(_feedingInfo, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text(
            "Grooming Tips",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? _loadingIndicator()
              : Text(_groomingTips, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          _isLoading
              ? Container()
              : ElevatedButton(
                onPressed: () => _loadPetCareInfo(forceRegenerate: true),
                child: const Text("Regenerate Care Info"),
              ),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Text(
          "Generating with AI...",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
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
