import 'package:flutter/material.dart';
import 'package:furever/models/pet.dart';
import 'package:furever/services/gemini_service.dart';

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
    _loadPetCareInfo();
  }

  Future<void> _loadPetCareInfo() async {
    setState(() {
      _isLoading = true;
      _feedingInfo = "Loading feeding recommendations...";
      _groomingTips = "Loading grooming tips...";
    });

    try {
      final petCareInfo = await _geminiService.generatePetCareInfo(
        petName: widget.pet.name,
        breed: widget.pet.breed,
        sex: widget.pet.sex,
        age: widget.pet.age,
        weight: widget.pet.weight,
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
                onPressed: _loadPetCareInfo,
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
