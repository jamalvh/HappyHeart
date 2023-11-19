// ignore_for_file: unused_local_variable
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:happyheart/profile_page.dart';
import 'home_page.dart';
import 'measure_page.dart';
import 'adjust_page.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraDescription firstCamera;
  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  void loadCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    firstCamera = cameras[1];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        // Check if the user is already signed in
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator while checking auth state
          } else {
            if (snapshot.hasData) {
              print(snapshot.data!.email);
              // User is already logged in, show the main app
              return MyAppBody(camera: firstCamera);
            } else {
              // User is not logged in, show the login page
              return const MyLoginPage();
            }
          }
        },
      ),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  State<MyAppBody> createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const MyHomePage(),
      const MyMeasurePage(),
      MyAdjustPage(camera: widget.camera),
      MyProfilePage(),
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: pages.elementAt(selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: selectedIndex == 0
                  ? const Icon(Icons.view_list)
                  : const Icon(Icons.view_list_outlined),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: selectedIndex == 1
                  ? const Icon(Icons.add)
                  : const Icon(Icons.add_outlined),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: selectedIndex == 2
                  ? const Icon(Icons.monitor_heart)
                  : const Icon(Icons.monitor_heart_outlined),
              label: 'Adjust',
            ),
            BottomNavigationBarItem(
              icon: selectedIndex == 3
                  ? const Icon(Icons.account_circle)
                  : const Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (value) => setState(() {
            selectedIndex = value;
          }),
        ),
      ),
    );
  }
}
