// This is for pasring week configuration from byte (Java getByteString)

class WeekConfig {
  final bool mon, tue, wed, thu, fri, sat, sun;

  const WeekConfig({
    required this.mon,
    required this.tue,
    required this.wed,
    required this.thu,
    required this.fri,
    required this.sat,
    required this.sun,
  });

  factory WeekConfig.fromByte(int b) {
    return WeekConfig(
      mon: ((b >> 0) & 1) == 1,
      tue: ((b >> 1) & 1) == 1,
      wed: ((b >> 2) & 1) == 1,
      thu: ((b >> 3) & 1) == 1,
      fri: ((b >> 4) & 1) == 1,
      sat: ((b >> 5) & 1) == 1,
      sun: ((b >> 6) & 1) == 1,
    );
  }

  @override
  String toString() {
    return 'WeekConfig('
        'mon=$mon, '
        'tue=$tue, '
        'wed=$wed, '
        'thu=$thu, '
        'fri=$fri, '
        'sat=$sat, '
        'sun=$sun'
        ')';
  }
}
