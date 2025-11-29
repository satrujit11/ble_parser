import 'package:ble_parser/constants/device_constant.dart';
import 'package:ble_parser/utils/extensions.dart';
import 'package:ble_parser/utils/resolve_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE SDK utilities for encoding time into the device-specific format.
class BleSDK {
  /// Builds a BLE command packet that sets the device's internal clock.
  ///
  /// The packet follows the protocol:
  /// ```
  /// Byte[0]  → Command ID (CMD_SET_TIME)
  /// Byte[1]  → Year  in BCD (ex: 2025 → 25 → 0x25)
  /// Byte[2]  → Month in BCD
  /// Byte[3]  → Day   in BCD
  /// Byte[4]  → Hour  in BCD
  /// Byte[5]  → Minute in BCD
  /// Byte[6]  → Second in BCD
  /// Byte[8]  → Encoded timezone (device-specific format)
  /// ```
  ///
  /// ### Timezone Encoding
  /// Same rule as the original Java implementation:
  ///
  /// - **Negative offset** (e.g., GMT−8) → raw value
  ///   Example: `-8 → 0x08`
  ///
  /// - **Positive offset** (e.g., GMT+5) → value + `0x80`
  ///   Example: `+5 → 0x85`
  ///
  /// Flutter provides the raw hour offset via:
  /// ```dart
  /// DateTime.now().timeZoneOffset.inHours;
  /// ```
  ///
  /// This method converts it to the exact device firmware format.
  ///
  /// ### Returns
  /// A 16-byte `Uint8List` ready to be sent to the BLE device.
  static Future<Uint8List> setDeviceTime() async {
    final now = DateTime.now();

    // Convert timezone to firmware-specific byte encoding
    final int offset = now.timeZoneOffset.inHours;
    final int zoneValue = offset < 0
        ? offset.abs() // negative → raw value
        : offset + 0x80; // positive → high bit set

    // Construct BLE command buffer
    return (Uint8List(16)
          ..[0] = DeviceConst.CMD_SET_TIME
          ..[1] = now.year.hexTimeValue
          ..[2] = now.month.hexTimeValue
          ..[3] = now.day.hexTimeValue
          ..[4] = now.hour.hexTimeValue
          ..[5] = now.minute.hexTimeValue
          ..[6] = now.second.hexTimeValue
          ..[8] = zoneValue)
        .withCrc();
  }

  static Future<Uint8List> getDeviceTime() async {
    return (Uint8List(16)..[0] = DeviceConst.CMD_GET_TIME).withCrc();
  }

  // This is set to parse upcoming data, it meant to used inside [BleManager.notify] to parse streamed data
  static void dataParsing(
    BluetoothDevice device,
    List<int> data, {
    void Function(BluetoothDevice device, int deviceConstant, List<int> data, Map<String, dynamic> parsedData)? onParsed,
  }) {
    if (kDebugMode) {
      print("Received data: ${data.bytes.toHexString()}");
    }

    if (data.length == 0) {
      debugPrint("No data received");
      return;
    }

    Map<String, dynamic>? parsedData;

    Uint8List bytes = data.bytes;

    switch (data[0]) {
      case DeviceConst.CMD_GET_TIME:
        parsedData = ResolveUtil.getDeviceTime(bytes);
        break;
      case DeviceConst.CMD_SET_TIME:
        parsedData = ResolveUtil.setDeviceTimeSuccessful(bytes);
        break;
      default:
        // Unknown command → do nothing
        return;
    }

    debugPrint("Parsed: $parsedData");
    // Only call if someone is listening
    onParsed?.call(device, data[0], data, parsedData);
  }
}
