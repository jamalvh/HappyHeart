// ignore_for_file: unused_local_variable
import 'dart:typed_data';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class MyAdjustPage extends StatefulWidget {
  const MyAdjustPage({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<MyAdjustPage> createState() => _MyAdjustPageState();
}

class _MyAdjustPageState extends State<MyAdjustPage> {
  bool isProperPosition = false;
  bool isBusy = false;

  // Step 3:
  late CameraController _cameraController;
  late Future<void> _initalizeCameraControllerFuture;
  late CameraImage img;

  Offset shoulderPosition = const Offset(0, 0);
  Offset wristPosition = const Offset(0, 0);
  Offset elbowPosition = const Offset(0, 0);

  final poseDetector = PoseDetector(options: PoseDetectorOptions());

  void loadCamera() {
    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);
    _initalizeCameraControllerFuture =
        _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() async {
          await _cameraController.startImageStream((imageStream) {
            img = imageStream;
            poseEstimateOnImage();
          });
        });
      }
    });
  }

  // Run pose estimation with Google MLkit on an image
  poseEstimateOnImage() async {
    if (!isBusy) {
      isBusy = true;
      Uint8List b = img.planes[0].bytes;
      InputImage inputImage = InputImage.fromBytes(
          bytes: b,
          metadata: InputImageMetadata(
              size: Size(img.width.toDouble(), img.height.toDouble()),
              rotation: InputImageRotation.rotation0deg,
              format: InputImageFormat.bgra8888,
              bytesPerRow: img.planes[0].bytesPerRow));

      final List<Pose> poses = await poseDetector.processImage(inputImage);
      for (Pose pose in poses) {
        // to access all landmarks
        pose.landmarks.forEach((_, landmark) {
          final type = landmark.type;
          final x = landmark.x;
          final y = landmark.y;
        });

        // to access specific landmarks
        final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
        final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
        final wrist = pose.landmarks[PoseLandmarkType.rightWrist];

        setState(() {
          shoulder != null
              ? shoulderPosition = Offset(shoulder.x, shoulder.y)
              : isProperPosition = false;
          elbow != null
              ? elbowPosition = Offset(elbow.x, elbow.y)
              : isProperPosition = false;
          wrist != null
              ? wristPosition = Offset(wrist.x, wrist.y)
              : isProperPosition = false;
        });
        checkIfProperPosition();
      }
      isBusy = false;
    }
  }

  // check if arm is at 90 degree angle using Pythagoras theorem
  void checkIfProperPosition() {
    bool isNinetyDegrees = false;
    double x1 = shoulderPosition.dx;
    double y1 = shoulderPosition.dy;
    double x2 = elbowPosition.dx;
    double y2 = elbowPosition.dy;
    double x3 = wristPosition.dx;
    double y3 = wristPosition.dy;

    // Calculate the sides
    var A = pow((x2 - x1), 2) + pow((y2 - y1), 2);

    var B = pow((x3 - x2), 2) + pow((y3 - y2), 2);

    var C = pow((x3 - x1), 2) + pow((y3 - y1), 2);

    // Check Pythagoras Formula
    if ((A > 0 && B > 0 && C > 0) &&
        ((A <= (B + C) + 15000 && A >= (B + C) - 15000) ||
            (B <= (A + C) + 10000 && B >= (A + C) - 15000) ||
            (C <= (A + B) + 15000 && C >= (A + B) - 15000))) {
      isNinetyDegrees = true;
    }
    setState(() {
      isProperPosition = isNinetyDegrees;
    });
  }

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isProperPosition ? Colors.lightBlue : Colors.white,
        appBar: AppBar(title: const Text("Realtime Adjustment")),
        body: Align(
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                    child: FutureBuilder(
                      future: _initalizeCameraControllerFuture,
                      builder: (context, snapshot) {
                        // Step 4:
                        // If camera future done initializing
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(3)),
                              child: CameraPreview(_cameraController));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(isProperPosition ? "OK" : "ADJUST",
                          style: TextStyle(
                              color: isProperPosition
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                  ),
                ],
              ),
              // LANDMARK DOTS:
              // Positioned(
              //   left: shoulderPosition.dx,
              //   top: shoulderPosition.dy,
              //   child: Container(
              //     width: 20,
              //     height: 20,
              //     decoration: const BoxDecoration(
              //         color: Colors.blue, shape: BoxShape.circle),
              //   ),
              // ),
              // Positioned(
              //   left: elbowPosition.dx,
              //   top: elbowPosition.dy,
              //   child: Container(
              //     width: 20,
              //     height: 20,
              //     decoration: const BoxDecoration(
              //         color: Colors.green, shape: BoxShape.circle),
              //   ),
              // ),
              // Positioned(
              //   left: wristPosition.dx,
              //   top: wristPosition.dy,
              //   child: Container(
              //     width: 20,
              //     height: 20,
              //     decoration: const BoxDecoration(
              //         color: Colors.red, shape: BoxShape.circle),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
