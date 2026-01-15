class ActivityFrame {
  final int timestamp;
  final int heartRate;
  final double temperature;
  final int spo2;
  final int steps;
  final int stepDelta;

  ActivityFrame({
    required this.timestamp,
    required this.heartRate,
    required this.temperature,
    required this.spo2,
    required this.steps,
    required this.stepDelta,
  });
}

