import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  XFile? _image;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _image = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Positioned(
          top: 20,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image preview (or placeholder)
          _image == null
              ? const Center(
                child: Text(
                  'No image captured',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Image.file(
                File(_image!.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

          // Camera UI controls
          Column(
            children: [
              Positioned(
                top: 20,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.photo, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Icon(Icons.flash_on, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Slider
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Slider(
              value: 0.5,
              onChanged: (value) {},
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
            ),
          ),

          // History button
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text("History"),
              onPressed: () {},
            ),
          ),

          // Capture button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.lightBlueAccent,
              onPressed: _pickImage,
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
