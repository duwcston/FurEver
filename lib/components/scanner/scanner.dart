import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  final List<File> _imageList = [];
  bool isFlashOn = false;
  bool isRearCamera = true;

  Future<File> saveImage(XFile? image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('$downloadPath/$fileName');

    try {
      await file.writeAsBytes(await image!.readAsBytes());
    } catch (_) {}

    return file;
  }

  void takePicture() async {
    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }

    if (isFlashOn) {
      await cameraController.setFlashMode(FlashMode.torch);
    } else {
      await cameraController.setFlashMode(FlashMode.off);
    }

    final XFile image = await cameraController.takePicture();

    // Optionally turn flash off after capturing if it was on
    if (cameraController.value.flashMode == FlashMode.torch) {
      cameraController.setFlashMode(FlashMode.off);
    }

    final file = await saveImage(image);
    setState(() {
      _imageList.add(file);
    });

    MediaScanner.loadMedia(path: file.path);
  }

  Future<void> _initializeCamera(int camera) async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras[camera],
        ResolutionPreset.high,
        enableAudio: false,
      );
      cameraValue = cameraController.initialize();
      setState(() {});
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No cameras available')));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera(0);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB2EBF2),
        onPressed: takePicture,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, size: 40, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CameraPreview(cameraController),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRearCamera = !isRearCamera;
                        });
                        if (isRearCamera) {
                          _initializeCamera(0);
                        } else {
                          _initializeCamera(1);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            isRearCamera
                                ? Icons.camera_rear
                                : Icons.camera_front,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Updated gallery preview container
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 100,
              padding: const EdgeInsets.only(left: 7, bottom: 75),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageList[index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
