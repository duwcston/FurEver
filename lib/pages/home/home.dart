import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:furever/components/chat/chat.dart';
import 'package:furever/components/map/map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furever/components/add_pet_form.dart';
import 'package:furever/components/navbar.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furever/pages/mypet/mypet.dart';
import 'package:furever/models/pet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<String> petNames = [];
  List<Pet> petList = [];

  void _addPet(Pet pet) {
    setState(() {
      petList.add(pet);
    });
    // Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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

  Widget _navBar(BuildContext context) {
    return NavBar();
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddPetForm(onPetAdded: _addPet);
                          },
                        );
                      },
                      child: Column(
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
                    ),
                    const SizedBox(width: 16),

                    ...petList.map(
                      (pet) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyPet(pet: pet),
                                  ),
                                );
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(
                                    (Random().nextDouble() * 0xFFFFFF).toInt(),
                                  ).withOpacity(1.0),
                                  // Random color
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Center(
                                  child: Text(
                                    pet.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(pet.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(radius: 23, child: Image.asset("images/logo.png")),
          Text("FurEver"),
        ],
      ),
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 100, // Add space at the top of the bar
      leading: GestureDetector(
        onTap: () {},
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
