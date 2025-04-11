import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furever/services/auth_service.dart';
import 'package:furever/components/navbar.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _profileHeader(context),
            _profileOption(),
            _logout(context),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(height: 85, child: _navBar(context)),
    );
  }

  Column _profileOption() {
    return Column(
      children: [
        buildProfileOption(
          Icons.edit,
          "Edit profile information",
          onTap: () {},
        ),
        buildProfileOption(
          Icons.notifications_active,
          "Notifications",
          trailing: "ON",
          onTap: () {},
        ),
        buildProfileOption(
          Icons.language,
          "Language",
          trailing: "English",
          onTap: () {},
        ),
        const Divider(),
        buildProfileOption(Icons.security, "Security", onTap: () {}),
        buildProfileOption(
          Icons.color_lens,
          "Theme",
          trailing: "Light mode",
          onTap: () {},
        ),
        const Divider(),
        buildProfileOption(Icons.help, "Help & Support", onTap: () {}),
        buildProfileOption(Icons.contact_mail, "Contact us", onTap: () {}),
        buildProfileOption(Icons.privacy_tip, "Privacy policy", onTap: () {}),
      ],
    );
  }

  Widget _navBar(BuildContext context) {
    return NavBar(currentIndex: 2);
  }

  Widget _logout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffadf8fd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black),
        ),
        minimumSize: const Size(200, 30),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
      },
      child: const Text("Log Out"),
    );
  }

  Stack _profileHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 170,
          decoration: const BoxDecoration(
            color: Color(0xFFB2EBF2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              // Add a avatar image here from Icon
              child: Icon(Icons.account_circle, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              "User",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "${FirebaseAuth.instance.currentUser?.email!.toString()} | +01 234 567 89",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
      title: const Text(
        "Profile",
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildProfileOption(
    IconData icon,
    String title, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing != null
              ? Text(trailing, style: const TextStyle(color: Colors.blue))
              : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
