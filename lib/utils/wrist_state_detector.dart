import 'dart:math';
import 'package:ble_parser/models/activity_frame.dart';
import 'package:flutter/foundation.dart';

class WristStateDetector {
  final int windowSizeSeconds;
  final List<ActivityFrame> _buffer = [];

  /// Stable output (fail-safe default = ON wrist)
  bool _stableState = true;
  int _confidenceCount = 0;

  /// User-specific entropy baseline
  double? _learnedEntropyBaseline;
  int _baselineSamples = 0;
  int lastSteps = 0;

  WristStateDetector({this.windowSizeSeconds = 30});

  // =============================
  // Public API
  // =============================

  void addFrame(ActivityFrame frame) {
    _buffer.add(frame);

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - windowSizeSeconds * 1000;

    final expired = _buffer.where((f) => f.timestamp < cutoff).toList();
    if (expired.isNotEmpty) {
      debugPrint('--- Evicting ${expired.length} frames ---');
      for (final f in expired) {
        debugPrint(
          'ts=${DateTime.fromMillisecondsSinceEpoch(f.timestamp)} | '
          'HR=${f.heartRate} | Temp=${f.temperature} | '
          'SpO2=${f.spo2} | Steps=${f.steps} | Δ=${f.stepDelta}',
        );
      }
      debugPrint('------------------------------');
    }

    _buffer.removeWhere((f) => f.timestamp < cutoff);
  }

  bool getStableWristState() {
    final current = _calculateOnWrist();

    if (_stableState != current) {
      _confidenceCount++;
    } else {
      _confidenceCount = 0;
    }

    // Require stronger confirmation to flip OFF wrist
    final requiredConfirmations = current ? 2 : 4;

    if (_confidenceCount >= requiredConfirmations) {
      _stableState = current;
      _confidenceCount = 0;
    }

    return _stableState;
  }

  // =============================
  // Core Logic
  // =============================

  bool _calculateOnWrist() {
    // Cold start protection
    if (_buffer.length < 10) return true;

    final hrValues = <int>[];
    int motionCount = 0;
    int validSpo2 = 0;
    double tempSum = 0;

    for (final f in _buffer) {
      if (f.heartRate >= 45 && f.heartRate <= 180) {
        hrValues.add(f.heartRate);
      }
      if (f.stepDelta > 0) motionCount++;
      if (f.spo2 >= 85) validSpo2++;
      tempSum += f.temperature;
    }

    if (hrValues.length < 5) return true;

    final avgTemp = tempSum / _buffer.length;
    final hrEntropy = _entropy(hrValues);
    final hrVariance = _variance(hrValues);

    _autoTuneEntropy(hrEntropy);

    final entropyThreshold = _learnedEntropyBaseline != null
        ? max(1.0, _learnedEntropyBaseline! * 0.65)
        : 1.2;

    double score = 0;

    // HR authenticity (entropy OR variance)
    if ((hrEntropy >= entropyThreshold || hrVariance >= 1.5)) {
      score += 0.35;
    }

    // Skin temperature
    if (avgTemp >= 30.5) score += 0.25;

    // Motion
    if (motionCount >= 2) score += 0.2;

    // SpO2 presence
    if (validSpo2 / _buffer.length > 0.3) score += 0.2;

    return score >= 0.6;
  }

  // =============================
  // Auto-tuning logic
  // =============================

  void _autoTuneEntropy(double entropy) {
    // Only learn when confidently ON wrist
    if (!_stableState) return;

    // Ignore garbage entropy
    if (entropy < 1.0 || entropy > 4.5) return;

    _baselineSamples++;
    _learnedEntropyBaseline ??= entropy;

    // Exponential moving average
    _learnedEntropyBaseline =
        (_learnedEntropyBaseline! * 0.9) + (entropy * 0.1);

    if (_baselineSamples % 20 == 0) {
      debugPrint(
        'Entropy baseline tuned: ${_learnedEntropyBaseline!.toStringAsFixed(2)}',
      );
    }
  }

  // =============================
  // Math helpers
  // =============================

  double _entropy(List<int> values) {
    final Map<int, int> freq = {};
    for (final v in values) {
      freq[v] = (freq[v] ?? 0) + 1;
    }

    final total = values.length;
    double entropy = 0;

    for (final count in freq.values) {
      final p = count / total;
      entropy -= p * (log(p) / ln2);
    }

    return entropy;
  }

  double _variance(List<int> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    double sum = 0;
    for (final v in values) {
      sum += pow(v - mean, 2).toDouble();
    }
    return sum / values.length;
  }
}
