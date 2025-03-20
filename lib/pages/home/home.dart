import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:furever/pages/chat/chat.dart';
import 'package:furever/pages/map/map.dart';
import 'package:furever/pages/profile/profile.dart';
import 'package:furever/pages/scanner/scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _userPets(),
              const SizedBox(height: 20),
              _services(context),
              const SizedBox(height: 20),
              _plans(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(height: 85, child: _navBar(context)),
    );
  }

  BottomNavigationBar _navBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Scanner()),
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
          icon: Icon(Icons.favorite_outline),
          label: "Care",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: "Scanner",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      ],
    );
  }

  Column _plans() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Plans",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "See All",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xffadf8fd),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.add, size: 25),
                ),
                const SizedBox(height: 8),
                const Text("Add Plan"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Column _services(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Services",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatBox()),
                  );
                },
                child: Container(
                  width: 170,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xffadf8fd),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SvgPicture.asset(
                        'assets/icons/chat.svg',
                        width: 24,
                        height: 24,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        "AI Assistant",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: Container(
                  width: 170,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xffadf8fd),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/map.svg'),
                      const SizedBox(width: 8),
                      Text(
                        "Maps",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _userPets() {
    return Column(
      children: [
        Text(
          "Welcome, ${FirebaseAuth.instance.currentUser?.email!.toString()}!",
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffadf8fd),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Pets",
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.add, size: 25),
                      ),
                      const SizedBox(height: 8),
                      const Text("Add Pet"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'FurEver\nA Petter Tool ',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80, // Add space at the top of the bar
      leading: GestureDetector(
        onTap: () {},
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Colors.black,
          size: 30,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
