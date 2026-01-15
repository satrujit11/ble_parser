import 'package:ble_parser/models/activity_frame.dart';
import 'package:flutter/foundation.dart';

class WristStateDetector {
  final int windowSizeSeconds;
  final List<ActivityFrame> _buffer = [];

  bool _stableState = true;
  int _confidenceCount = 0;

  int? lastSteps;

  WristStateDetector({this.windowSizeSeconds = 30});

  void addFrame(ActivityFrame frame) {
    _buffer.add(frame);

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - windowSizeSeconds * 1000;

    // 1️⃣ Identify frames that will be removed
    final expiredFrames = _buffer.where((f) => f.timestamp < cutoff).toList();

    // 2️⃣ Print them BEFORE removal
    if (expiredFrames.isNotEmpty) {
      debugPrint('--- Evicting ${expiredFrames.length} frames ---');
      for (final f in expiredFrames) {
        debugPrint(
          'ts=${DateTime.fromMillisecondsSinceEpoch(f.timestamp)} | '
          'HR=${f.heartRate} | '
          'Temp=${f.temperature} | '
          'SpO2=${f.spo2} | '
          'Steps=${f.steps} | '
          'ΔSteps=${f.stepDelta}',
        );
      }
      print('------------------------------');
    }

    // 3️⃣ Now remove them
    _buffer.removeWhere((f) => f.timestamp < cutoff);
  }

  bool getStableWristState() {
    final current = _calculateOnWrist();

    if (_stableState != current) {
      _confidenceCount++;
    } else {
      _confidenceCount = 0;
    }

    // Require 3 consecutive confirmations
    if (_confidenceCount >= 3) {
      _stableState = current;
      _confidenceCount = 0;
    }

    return _stableState;
  }

  bool _calculateOnWrist() {
    if (_buffer.length < 10) return true;

    int validHr = 0;
    int motion = 0;
    int validSpo2 = 0;
    double tempSum = 0;

    for (final f in _buffer) {
      if (f.heartRate >= 45 && f.heartRate <= 180) validHr++;
      if (f.stepDelta > 0) motion++;
      if (f.spo2 >= 85) validSpo2++;
      tempSum += f.temperature;
    }

    final avgTemp = tempSum / _buffer.length;

    double score = 0;
    if (validHr / _buffer.length > 0.6) score += 0.35;
    if (avgTemp >= 30.5) score += 0.25;
    if (motion >= 2) score += 0.2;
    if (validSpo2 / _buffer.length > 0.3) score += 0.2;

    return score >= 0.6;
  }
}
