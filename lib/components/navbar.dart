import 'package:flutter/material.dart';
import 'package:furever/pages/home/home.dart';
import 'package:furever/pages/mypet/mypet.dart';
import 'package:furever/pages/profile/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furever/services/auth_service.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()), // to do
          );
        } else if (index == 1) {
          // Show the AddPetForm when "Add pet" is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          backgroundColor: Colors.grey,
          icon: Icon(Icons.calendar_today),
          label: "Schedule",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.house_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
