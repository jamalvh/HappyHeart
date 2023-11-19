// Import necessary packages and classes
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happyheart/main.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to the adjust page after successful login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MyApp()));
    } catch (e) {
      // Handle login errors here
      // You can show an error message to the user
    }
  }

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Might add additional logic here, such as sending a verification email
      // Automatically sign in after registration
      _signInWithEmailAndPassword(context);
      await initializeUserData(); // Wait for user data initialization
    } catch (e) {
      // Handle registration errors here
      // Could show an error message to the user
    }
  }

  Future<void> initializeUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Get the user ID
        String userId = user.uid;
        // Initialize the bloodPressureReadings list for the user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'bloodPressureReadings': []});
      }
    } catch (e) {
      // print('Error initializing user data: $e');
      // throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _signInWithEmailAndPassword(context);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _registerWithEmailAndPassword(context);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
