import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:furever/firebase_options.dart';
// import 'package:furever/pages/home/home.dart';
import 'pages/login/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 if (!File('.env').existsSync()) {
    print("❌ ERROR: .env file not found!");
    return;
  } else {
    print("✅ .env file found!");
  }

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Login());
  }
}
