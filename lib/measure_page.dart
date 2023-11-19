import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classes.dart';

class MyMeasurePage extends StatefulWidget {
  const MyMeasurePage({super.key});

  @override
  State<MyMeasurePage> createState() => _MyMeasurePageState();
}

class _MyMeasurePageState extends State<MyMeasurePage> {
  bool isSubmitted = false;

  final _formKey = GlobalKey<FormBuilderState>();

  BloodPressure myBloodPressure = BloodPressure(
    "",
    TimeStamp(0, 0, 0),
    0, // placeholder for time
    120,
    80,
  );

  DateTime _selectedDate = DateTime(0);
  int _selectedSystolic = 120;
  int _selectedDiastolic = 80;

  Future<void> _submitBloodPressure() async {
    myBloodPressure.timestamp.day = _selectedDate.day;
    myBloodPressure.timestamp.month = _selectedDate.month;
    myBloodPressure.timestamp.year = _selectedDate.year;
    myBloodPressure.calcTime();
    myBloodPressure.systolic = _selectedSystolic;
    myBloodPressure.diastolic = _selectedDiastolic;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the user ID
        String userId = user.uid;

        // Add blood pressure data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('bloodPressureReadings')
            .add(myBloodPressure.toMap());

        setState(() {
          isSubmitted = true;
        });
      }
    } catch (e) {
      print('Error submitting blood pressure: $e');
      // Handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Your Blood Pressure")),
      body: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: FormBuilder(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      child: const Text("Date of Measurement"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                    ),
                    FormBuilderDateTimePicker(
                      name: "timestamp",
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          hintText: "Select a date"),
                      inputType: InputType.date,
                      onChanged: (value) {
                        _selectedDate = value!;
                        setState(() {
                          isSubmitted = false;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      child: const Text("Systolic Pressure Measured"),
                    ),
                    FormBuilderSlider(
                      name: 'systolic',
                      initialValue: 120,
                      min: 0,
                      max: 240,
                      divisions: 240,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        _selectedSystolic = value!.toInt();
                        setState(() {
                          isSubmitted = false;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      child: const Text("Diastolic Pressure Measured"),
                    ),
                    FormBuilderSlider(
                      name: 'diastolic',
                      initialValue: 80,
                      min: 0,
                      max: 160,
                      divisions: 160,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        _selectedDiastolic = value!.toInt();
                        setState(() {
                          isSubmitted = false;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isSubmitted
                              ? MaterialStatePropertyAll(Colors.grey[500])
                              : const MaterialStatePropertyAll(Colors.blue),
                        ),
                        onPressed: isSubmitted ? null : _submitBloodPressure,
                        child: isSubmitted
                            ? const Icon(Icons.check)
                            : const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
