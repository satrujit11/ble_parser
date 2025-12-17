import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

extension BCD on int {
  /// 0–99 → BCD byte (e.g. 45 → 0x45)
  int get bcd {
    final v = this.abs() % 100; // safe
    return ((v ~/ 10) << 4) | (v % 10);
  }

  /// BCD byte → normal number (e.g. 0x59 → 59)
  static int fromBcd(int bcd) => ((bcd >> 4) * 10) + (bcd & 0x0F);
}

extension HexParseExt on int {
  /// Converts this integer to a string and parses it as a hex value.
  ///
  /// Example:
  ///  - 10 → "10" (hex) → 16
  ///  - 25 → "25" (hex) → 37
  ///
  /// This replicates the behavior of the Java method:
  /// public static byte getTimeValue(int value)
  int get hexParsed {
    final hexString = toString(); // same: value + ""
    return int.parse(hexString, radix: 16); // Integer.parseInt(str, 16)
  }
}

/// ---------------------------------------------------------------------------
/// 1. Hex String → Integer (Java: Integer.parseInt(value, 16))
/// ---------------------------------------------------------------------------

/// Converts a hexadecimal string (e.g., `"1A"`) into an integer.
///
/// This replicates the Java method:
/// ```java
/// Integer.parseInt(value, 16);
/// ```
///
/// ### Example
/// ```dart
/// "1A".hexToInt == 26;
/// "25".hexToInt == 37;      // same as Java
/// ```
extension HexStringToInt on String {
  /// Parses this string as a hexadecimal number.
  int get hexToInt => int.parse(this, radix: 16);
}

/// ---------------------------------------------------------------------------
/// CRC-8 Calculation Extension for Uint8List
/// ---------------------------------------------------------------------------
/// Provides a method to compute a simple additive CRC (checksum) for a
/// `Uint8List` and returns a **new buffer** with the CRC applied to the
/// last byte. This mimics the behavior of the Java method:
///
/// ```java
/// byte crc = 0;
/// for (int i = 0; i < value.length - 1; i++) {
///     crc += value[i];
/// }
/// value[value.length - 1] = (byte)(crc & 0xff);
/// ```
///
/// ### How It Works
/// - Sums all bytes in the buffer **except the last one**.
/// - The sum is masked with `0xFF` to keep it within byte range.
/// - Returns a **new `Uint8List`** with the last byte replaced by the CRC.
/// - The original buffer remains unchanged.
///
/// ### Example Usage
/// ```dart
/// final original = Uint8List.fromList([0x01, 0x02, 0x03, 0x00]);
/// final withCrc = original.withCrc();
/// print(withCrc); // [1, 2, 3, 6]  (1 + 2 + 3 = 6)
/// print(original); // [1, 2, 3, 0] remains unchanged
/// ```
///
/// This is especially useful for BLE protocols or embedded device
/// communications where the last byte is reserved for checksum.
extension CrcExt on Uint8List {
  /// Returns a new Uint8List with CRC applied to the last byte.
  Uint8List withCrc() {
    // Copy original buffer
    final Uint8List copy = Uint8List.fromList(this);

    int crc = 0;
    for (int i = 0; i < copy.length - 1; i++) {
      crc = (crc + copy[i]) & 0xFF;
    }

    copy[copy.length - 1] = crc;
    return copy;
  }
}

/// ---------------------------------------------------------------------------
/// 3. Java getTimeValue(int value)
/// ---------------------------------------------------------------------------

/// Converts a decimal integer into a value by parsing its string form as hex.
///
/// Java equivalent:
/// ```java
/// public static byte getTimeValue(int value) {
///     return Byte.valueOf(String.valueOf(value)); // parsed as hex
/// }
/// ```
///
/// ⚠ This is **NOT BCD**.
/// It treats the number as a **hex string**, not decimal.
///
/// ### Example
/// ```dart
/// 25.hexTimeValue == 0x25 == 37;
/// 12.hexTimeValue == 0x12 == 18;
/// ```
extension TimeValueHex on int {
  /// Parses this integer's string representation as a hex value.
  int get hexTimeValue => int.parse(toString(), radix: 16);
}

/// ---------------------------------------------------------------------------
/// 4. Java bcd2String(byte)
/// ---------------------------------------------------------------------------

/// Converts a BCD-encoded byte into a two-digit decimal string.
///
/// Java equivalent:
/// ```java
/// temp.append((bytes & 0xf0) >>> 4);
/// temp.append((bytes & 0x0f));
/// ```
///
/// ### Example
/// ```dart
/// 0x25.bcdToString == "25"
/// 0x09.bcdToString == "09"
/// 0x41.bcdToString == "41"
/// ```
extension BcdToString on int {
  /// Converts a BCD-encoded byte into a string like `"25"` or `"09"`.
  String get bcdToString {
    final high = (this & 0xF0) >> 4;
    final low = this & 0x0F;
    return "$high$low";
  }
}

extension ByteExt on int {
  /// Converts a byte value (0–255) to a 2-digit lowercase hex string.
  /// Example: 255 -> "ff", 10 -> "0a", 0 -> "00"
  String toHexString() {
    return (this & 0xFF).toRadixString(16).padLeft(2, '0');
  }

  /// Replacement of getValue in [ResolveUtil]
  /// Returns this byte shifted left by (count * 8) bits → equivalent to byte * 256^count
  int shiftedBy(int count) => (this & 0xFF) << (count * 8);

  int get asByte => shiftedBy(0);

  int get byte => this & 0xFF;

  int byteAt(int index) => (this >> (index * 8)) & 0xFF;

  /// Same as [toHexString] but returns uppercase letters (FF, 0A, etc.)
  String toHexStringUpper() {
    return (this & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase();
  }

}

extension Uint8ListHex on Uint8List {
  /// Converts entire byte array to space-separated hex string
  /// Example: [0x1A, 0xFF, 0x0B] → "1a ff 0b"
  String toHexString() => map((b) => b.toHexString()).join(' ');

  /// Without spaces: "1aff0b"
  String toHexStringCompact() => map((b) => b.toHexString()).join();

  /// With 0x prefix: "0x1a 0xff 0x0b"
  String toHexStringPrefixed() => map((b) => '0x${b.toHexString()}').join(' ');
}

extension ListIntToBytes on List<int> {
  /// Safely convert any List<int> (0–255) → Uint8List
  Uint8List toUint8List() {
    // Fast path: already a Uint8List
    if (this is Uint8List) return this as Uint8List;

    // Safe path: ensure values are bytes
    return Uint8List.fromList(map((b) => b & 0xFF).toList());
  }

  /// Alias – super readable
  Uint8List get bytes => toUint8List();

  /// For logging
  String get hex =>
      map((b) => (b & 0xFF).toRadixString(16).padLeft(2, '0')).join(' ');
}

extension Uint8ListExtensions on Uint8List {
  /// Just for consistency – already is Uint8List
  Uint8List get bytes => this;

  /// Fast conversion to List<int> (rarely needed)
  List<int> get toListInt => List<int>.from(this);

  /// Alias – super readable
  List<int> get asList => toListInt;

  /// Beautiful hex dump
  String get hex => map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  String get hexSpaced =>
      map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  String get hexDebug => '[${hexSpaced}]';
}

extension GuidBle on Guid {
  /// Safely converts any BLE UUID (short or full) → 16-bit int
  /// "fff7"                    → 0xFFF7
  /// "0000fff7-..."            → 0xFFF7
  /// "0000FFF7-0000-1000..."   → 0xFFF7
  int get toInt16 {
    final str = toString().replaceAll('-', '').toLowerCase();

    // Case 1: Short UUID like "fff7"
    if (str.length == 4) {
      return int.parse(str, radix: 16);
    }

    // Case 2: Full 128-bit UUID → extract middle 16 bits
    if (str.length == 32 &&
        str.startsWith('0000') &&
        str.endsWith('00001000800000805f9b34fb')) {
      return int.parse(str.substring(4, 8), radix: 16);
    }

    // Fallback: try to parse last 4 hex chars (works for most custom short UUIDs)
    final last4 = str.length >= 4 ? str.substring(str.length - 4) : str;
    return int.parse(last4, radix: 16);
  }

  String get hex16 =>
      "0x${toInt16.toRadixString(16).toUpperCase().padLeft(4, '0')}";
  String get short => toInt16.toRadixString(16).toLowerCase().padLeft(4, '0');
}
