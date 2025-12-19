/// Configuration for automatic health monitoring on the device.
///
/// This controls **when**, **how often**, and **on which days**
/// the device automatically measures health data such as:
/// - Heart Rate
/// - SpO₂
/// - Temperature
/// - HRV
///
/// ⚠️ This configuration runs on the DEVICE (not the phone).
/// ⚠️ Values may be 0 if measurement is disabled or outside the time window.
class AutoHRMonitoring {
  /// Measurement mode:
  /// 0 → Disabled
  /// 1 → Continuous measurement during the entire time window (battery heavy)
  /// 2 → Periodic measurement within the time window (recommended)
  final int open;

  /// Start hour of the monitoring window (0–23)
  final int startHour;

  /// Start minute of the monitoring window (0–59)
  final int startMinute;

  /// End hour of the monitoring window (0–23)
  final int endHour;

  /// End minute of the monitoring window (0–59)
  final int endMinute;

  /// Days of week bitmask (Monday → Sunday)
  ///
  /// Example:
  /// - 31  → Monday–Friday
  /// - 64  → Sunday only
  /// - 127 → Every day
  final int week;

  /// Measurement interval in minutes.
  ///
  /// Only used when [open] == 2.
  /// Recommended: ≥ 5 minutes
  final int intervalMinutes;

  const AutoHRMonitoring({
    required this.open,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.week,
    required this.intervalMinutes,
  });

  @override
  String toString() {
    return 'AutomaticHealthMonitoring('
        'open=$open, '
        'start=$startHour:$startMinute, '
        'end=$endHour:$endMinute, '
        'week=$week, '
        'interval=$intervalMinutes min'
        ')';
  }
}

enum AutoMode { AutoHeartRate, AutoSpo2, AutoTemp, AutoHrv }

extension AutoModeValue on AutoMode {
  /// BLE protocol value for automatic measurement type.
  ///
  /// Matches device firmware mapping:
  /// - Heart Rate → 0x01
  /// - SpO₂       → 0x02
  /// - Temperature→ 0x03
  /// - HRV        → 0x04
  int get value {
    switch (this) {
      case AutoMode.AutoHeartRate:
        return 0x01;
      case AutoMode.AutoSpo2:
        return 0x02;
      case AutoMode.AutoTemp:
        return 0x03;
      case AutoMode.AutoHrv:
        return 0x04;
      default:
        return 0x01;
    }
  }
}
