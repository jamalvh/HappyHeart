// import necessary packages and classes
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happyheart/login_page.dart';

// ignore: must_be_immutable
class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("User signed out");
      // Navigate to the login page after successful sign-out
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const MyLoginPage())); // Replace with your login page route
    } catch (e) {
      print("Error: $e");
      // Handle sign-out errors here
      // Could show an error message to the user
    }
  }

  var currUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Email: ${currUser?.email}"),
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
