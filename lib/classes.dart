class AUser {
  final String uid;
  final List<BloodPressure> bloodPressureReadings;

  AUser({
    required this.uid,
    required this.bloodPressureReadings,
  });

  // Additional methods or constructors if needed
}

class BloodPressure {
  String id;
  TimeStamp timestamp;
  double time;
  int systolic;
  int diastolic;

  BloodPressure(
      this.id, this.timestamp, this.time, this.systolic, this.diastolic) {
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

class TimeStamp {
  int day;
  int month;
  int year;

  TimeStamp(this.day, this.month, this.year);
}
