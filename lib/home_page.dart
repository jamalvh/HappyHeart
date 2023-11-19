import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Timestamp {
  int day;
  int month;
  int year;

  Timestamp(this.day, this.month, this.year);

  // Constructor to create Timestamp from DateTime
  Timestamp.fromDateTime(DateTime dateTime)
      : day = dateTime.day,
        month = dateTime.month,
        year = dateTime.year;
}

class BloodPressure {
  String id;
  double time;
  Timestamp timestamp;
  int systolic;
  int diastolic;

  BloodPressure(
      this.id, this.time, this.timestamp, this.systolic, this.diastolic) {
    calcTime();
  }

  void calcTime() {
    time = timestamp.year / 10 * 10000 +
        timestamp.month / 10 * 100 +
        timestamp.day / 10;
  }

  // Convert BloodPressure object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'timestamp': {
        'day': timestamp.day,
        'month': timestamp.month,
        'year': timestamp.year,
      },
      'id': id,
      'time': time,
      'systolic': systolic,
      'diastolic': diastolic,
    };
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<List<BloodPressure>> bloodPressureStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream with the user's blood pressure readings from Firestore
    initializeBloodPressureStream();
  }

  void initializeBloodPressureStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Stream of blood pressure readings for the user
      bloodPressureStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bloodPressureReadings')
          .orderBy('time', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          // Parse the data from Firestore and create BloodPressure objects
          Map<String, dynamic> data = doc.data();
          Map<String, dynamic> timestampData =
              data['timestamp'] as Map<String, dynamic>;

          Timestamp timestamp = Timestamp(
            timestampData['day'] as int,
            timestampData['month'] as int,
            timestampData['year'] as int,
          );

          String id = doc.id;
          double time = data['time'] as double;
          int systolic = data['systolic'] as int;
          int diastolic = data['diastolic'] as int;

          return BloodPressure(id, time, timestamp, systolic, diastolic);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Blood Pressure History"),
        ),
        body: StreamBuilder<List<BloodPressure>>(
          stream: bloodPressureStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wysiwyg,
                      size: 200,
                      color: Colors.grey[400],
                    ),
                    Text(
                      "No Logs Yet...",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            } else {
              // Blood pressure readings are available, build the UI
              List<BloodPressure> bloodPressureReadings = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.025),
                      width: MediaQuery.of(context).size.width * .8,
                      height: MediaQuery.of(context).size.height * .35,
                      child: LineChart(
                        LineChartData(
                          minX: 1,
                          maxX: bloodPressureReadings.length.toDouble(),
                          minY: 0,
                          maxY: 240,
                          gridData: FlGridData(
                            horizontalInterval: 100,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: Color.fromARGB(255, 178, 178, 178),
                                dashArray: [1, 0],
                              );
                            },
                          ),
                          lineBarsData: List.generate(2, (index) {
                            if (index == 0) {
                              return LineChartBarData(
                                isCurved: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                                color: Colors.blue,
                                spots: List.generate(
                                  bloodPressureReadings.length,
                                  (index) => FlSpot(
                                      index.toDouble() + 1,
                                      bloodPressureReadings[
                                              (bloodPressureReadings.length -
                                                      index.toDouble() -
                                                      1)
                                                  .toInt()]
                                          .systolic
                                          .toDouble()),
                                ),
                                isStepLineChart: false,
                              );
                            } else {
                              return LineChartBarData(
                                isCurved: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withOpacity(0.3),
                                ),
                                color: Colors.green,
                                spots: List.generate(
                                  bloodPressureReadings.length,
                                  (index) => FlSpot(
                                      index.toDouble() + 1,
                                      bloodPressureReadings[
                                              (bloodPressureReadings.length -
                                                      index.toDouble() -
                                                      1)
                                                  .toInt()]
                                          .diastolic
                                          .toDouble()),
                                ),
                                isStepLineChart: false,
                              );
                            }
                          }),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                getTitlesWidget: (value, meta) => Text(
                                    value == 1 ? '' : '$value',
                                    style:
                                        const TextStyle(color: Colors.black)),
                                showTitles: true,
                                interval: 1,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                getTitlesWidget: (value, meta) => Text(
                                    value == 0 ? '' : '$value',
                                    style:
                                        const TextStyle(color: Colors.black)),
                                showTitles: true,
                                interval: 60,
                                reservedSize: 38,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              top: BorderSide(width: 0),
                              right: BorderSide(width: 0),
                              bottom: BorderSide(width: 1),
                              left: BorderSide(width: 1),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: const Text(
                              "MM / DD / YYYY",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 6,
                            child: const Text(
                              "S",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ), // 140+ is Stage II Hypertension
                            ),
                          ),
                          const Text(
                            "D",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20), // 140+ is Stage II Hypertension
                          ),
                        ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bloodPressureReadings.length,
                      itemBuilder: (context, index) {
                        var currentItem = bloodPressureReadings[index];
                        var reversedIndex =
                            bloodPressureReadings.length - index - 1;
                        return Dismissible(
                          key: Key(reversedIndex.toString()),
                          background: Container(color: Colors.red),
                          onDismissed: (direction) async {
                            // Delete the corresponding document from Firestore
                            User? user = FirebaseAuth.instance.currentUser;
                            String userId = "";
                            if (user != null) {
                              userId = user.uid;
                            }
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('bloodPressureReadings')
                                .doc(currentItem.id)
                                .delete();
                            setState(() {
                              bloodPressureReadings.remove(currentItem);
                            });
                          },
                          child: ListTile(
                            title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Text(
                                      "${currentItem.timestamp.month.toString()} / ${currentItem.timestamp.day.toString()} / ${currentItem.timestamp.year.toString()}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    child: Text(
                                      currentItem.systolic.toString(),
                                      style: TextStyle(
                                          color: currentItem.systolic >= 140
                                              ? Colors.redAccent
                                              : Colors.black,
                                          fontSize:
                                              20), // 140+ is Stage II Hypertension
                                    ),
                                  ),
                                  Text(
                                    currentItem.diastolic.toString(),
                                    style: TextStyle(
                                        color: currentItem.diastolic >= 90
                                            ? Colors.redAccent
                                            : Colors.black,
                                        fontSize:
                                            20), // 140+ is Stage II Hypertension
                                  ),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
