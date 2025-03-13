import 'package:flutter/material.dart';
import 'package:furever/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../signup/signup.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      // bottomNavigationBar: _signup(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              color: Color(0xffF7F7F9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'FurEver\nA Petter Tool',
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              _emailAddress(),
              const SizedBox(height: 5),
              _password(),
              const SizedBox(height: 5),
              _forgotPassword(),
              const SizedBox(height: 5),
              _loginButton(context),
              const SizedBox(height: 40),
              _signup(context),
              _signupButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'designer@gmail.com',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot your Password?',
          style: TextStyle(
            color: Color(0xff6A6A6A),
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffadf8fd),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xff082024), width: 1)),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signin(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
      },
      child: const Text(
        "Log In",
        style: TextStyle(
          color: Color(0xff082024),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
                color: Color(0xff3b3b3b),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            // const TextSpan(text: "\n"),
          ],
        ),
      ),
    );
  }

  Widget _signupButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffF7F7F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xff082024), width: 1),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup()),
        );
      },
      child: const Text(
        "Sign Up",
        style: TextStyle(
          color: Color(0xff082024),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
