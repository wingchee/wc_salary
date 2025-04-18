class ToiletSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double monthlySalary;
  final double earnedAmount;
  final Duration duration;

  ToiletSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.monthlySalary,
    required this.earnedAmount,
    required this.duration,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'monthlySalary': monthlySalary,
      'earnedAmount': earnedAmount,
      'durationInSeconds': duration.inSeconds,
    };
  }

  // Create from Firestore document
  factory ToiletSession.fromMap(Map<String, dynamic> map) {
    return ToiletSession(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      monthlySalary: map['monthlySalary'],
      earnedAmount: map['earnedAmount'],
      duration: Duration(seconds: map['durationInSeconds']),
    );
  }
}
