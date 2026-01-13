import 'package:ble_parser/ble_parser.dart';
import 'package:ble_parser/constants/auto_testmode.dart';
import 'package:ble_parser/constants/device_constant.dart';
import 'package:ble_parser/models/automatic_hr_monitoring.dart';
import 'package:ble_parser/models/ble_command_state.dart';
import 'package:ble_parser/models/personal_info.model.dart';
import 'package:ble_parser/utils/extensions.dart';
import 'package:ble_parser/src/resolve_util.dart';
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

  static Future<Uint8List> setPersonalInfo(PersonalInfo info) async {
    return (Uint8List(16)
          ..[0] = DeviceConst.CMD_SET_USER_INFO
          ..[1] = info.sex.byte
          ..[2] = info.age.byte
          ..[3] = info.height.byte
          ..[4] = info.weight.byte
          ..[5] = info.getStepLenth.byte)
        .withCrc();
  }

  static Future<Uint8List> mcuReset() async {
    return (Uint8List(16)..[0] = DeviceConst.CMD_MCU_RESET).withCrc();
  }


  static Future<Uint8List> getPersonalInfo() async {
    return (Uint8List(16)..[0] = DeviceConst.CMD_GET_USER_INFO).withCrc();
  }

  static Future<Uint8List> getDeviceTime() async {
    return (Uint8List(16)..[0] = DeviceConst.CMD_GET_TIME).withCrc();
  }

  static Future<Uint8List> getDeviceBattery() async {
    return (Uint8List(16)..[0] = DeviceConst.CMD_GET_BATTERY_LEVEL).withCrc();
  }


  static Future<Uint8List> setDeviceMeasurementWithType(
      AutoTestMode dataType, int second, bool open) async {
    assert(
      !open || second >= 30,
      'Measurement interval must be greater than or equal to 30 seconds when enabled',
    );
    return (Uint8List(16)
          ..[0] = DeviceConst.MEASUREMENT_WITH_TYPE
          ..[1] = dataType.value
          ..[2] = (open ? 0x01 : 0x00)
          ..[4] = second.byteAt(0)
          ..[5] = second.byteAt(1))
        .withCrc();
  }

  static Future<Uint8List> getBasicParamtersOfEquipment() async {
    return (Uint8List(16)..[0] = DeviceConst.GET_BASIC_PARAMETERS_OF_EQUIPMENT)
        .withCrc();
  }

  /// this is alternative to RealTimeStep in previous sdk
  static Future<Uint8List> enableActivity(bool enable, bool tempEnable) async {
    return (Uint8List(16)
          ..[0] = DeviceConst.CMD_ENABLE_ACTIVITY
          ..[1] = (enable ? 0x01 : 0x00)
          ..[2] = (tempEnable ? 0x01 : 0x00))
        .withCrc();
  }

  static Future<Uint8List> setAutommaticHRMonitoring(
      AutoHRMonitoring autoHeart, AutoMode? type) async {
    return (Uint8List(16)
          ..[0] = DeviceConst.CMD_SET_AUTO
          ..[1] = autoHeart.open
          ..[2] = autoHeart.startHour.hexTimeValue
          ..[3] = autoHeart.startMinute.hexTimeValue
          ..[4] = autoHeart.endHour.hexTimeValue
          ..[5] = autoHeart.endMinute.hexTimeValue
          ..[6] = autoHeart.week
          ..[7] = autoHeart.intervalMinutes.byteAt(0)
          ..[8] = autoHeart.intervalMinutes.byteAt(1)
          ..[9] = type?.value ?? 0x01)
        .withCrc();
  }

  static Future<Uint8List> getAutommaticHRMonitoring(AutoMode? type) async {
    return (Uint8List(16)
          ..[0] = DeviceConst.CMD_GET_AUTO
          ..[1] = type?.value ?? 0x01)
        .withCrc();
  }

  static Future<Uint8List> getTotalActivityDataWithMode(
      DataReadingMode mode, DateTime? dateOfLastData) async {
    BleCommandState.deleteTotalActivityDataWithMode =
        mode == DataReadingMode.deleteData;
    final value = Uint8List(16)
      ..[0] = DeviceConst.CMD_GET_TOTAL_DATA
      ..[1] = mode.value;

    // Insert date only if provided (matches Java behavior)
    if (dateOfLastData != null) {
      value[4] = dateOfLastData.year.bleTimeValue;
      value[5] = dateOfLastData.month.bleTimeValue;
      value[6] = dateOfLastData.day.bleTimeValue;
      value[7] = dateOfLastData.hour.bleTimeValue;
      value[8] = dateOfLastData.minute.bleTimeValue;
      value[9] = dateOfLastData.second.bleTimeValue;
    }
    return value.withCrc();
  }

  static Future<Uint8List> getDetailSleepDataWithMode(
      DataReadingMode mode, DateTime? dateOfLastData) async {
    BleCommandState.deleteGetDetailsSleepData =
        mode == DataReadingMode.deleteData;
    final value = Uint8List(16)
      ..[0] = DeviceConst.CMD_GET_SLEEP_DATA
      ..[1] = mode.value;

    // Insert date only if provided (matches Java behavior)
    if (dateOfLastData != null) {
      value[4] = dateOfLastData.year.bleTimeValue;
      value[5] = dateOfLastData.month.bleTimeValue;
      value[6] = dateOfLastData.day.bleTimeValue;
      value[7] = dateOfLastData.hour.bleTimeValue;
      value[8] = dateOfLastData.minute.bleTimeValue;
      value[9] = dateOfLastData.second.bleTimeValue;
    }
    return value.withCrc();
  }

  // This is set to parse upcoming data, it meant to used inside [BleManager.notify] to parse streamed data
  static void dataParsing(
    BluetoothDevice device,
    List<int> data, {
    void Function(BluetoothDevice device, int deviceConstant, List<int> data,
            Map<String, dynamic>? parsedData)?
        onParsed,
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

    debugPrint("[LOG] Device Constant type: ${data[0]}");

    switch (data[0]) {
      case DeviceConst.CMD_GET_TIME:
        parsedData = ResolveUtil.getDeviceTime(bytes);
        break;
      case DeviceConst.CMD_SET_TIME:
        parsedData = ResolveUtil.setDeviceTimeSuccessful(bytes);
        break;
      case DeviceConst.CMD_GET_BATTERY_LEVEL:
        parsedData = ResolveUtil.getDeviceBattery(bytes);
        break;

      case DeviceConst.CMD_GET_USER_INFO:
        parsedData = ResolveUtil.getUserInfo(bytes);
        break;

      case DeviceConst.GET_BASIC_PARAMETERS_OF_EQUIPMENT:
        parsedData = ResolveUtil.getBasicParametersOfEquipment(bytes);
        break;

      case DeviceConst.CMD_ENABLE_ACTIVITY:
        parsedData = ResolveUtil.getActivityData(bytes);
        break;

      case DeviceConst.CMD_GET_AUTO:
        parsedData = ResolveUtil.getAutoHeart(bytes);
        break;

      case DeviceConst.CMD_GET_TOTAL_DATA:
        if (BleCommandState.deleteTotalActivityDataWithMode) {
          parsedData =
              ResolveUtil.deleteData(BleConst.deleteGetTotalActivityData);
          BleCommandState.deleteTotalActivityDataWithMode = false;
        } else {
          parsedData = ResolveUtil.getTotalStepData(bytes);
        }
        break;

      case DeviceConst.CMD_GET_SLEEP_DATA:
        if (BleCommandState.deleteTotalActivityDataWithMode) {
          parsedData =
              ResolveUtil.deleteData(BleConst.deleteGetDetailSleepData);
          BleCommandState.deleteGetDetailsSleepData = false;
        } else {
          parsedData = ResolveUtil.getSleepData(bytes);
        }
        break;

      /// It is clicking two times the button
      case DeviceConst.CMD_START_EXERCISE:
        parsedData = ResolveUtil.doubleClickAction(bytes);
        break;

      case DeviceConst.CMD_LONG_PRESS_ACTION_BUTTON:
        parsedData = ResolveUtil.longPressAction(bytes);
        break;

      case DeviceConst.CMD_MCU_RESET:
        parsedData = ResolveUtil.mcuReset();
        break;

      case DeviceConst.MEASUREMENT_WITH_TYPE:
        debugPrint("[INFO] Measurement with type ${bytes[1]}");
        switch (bytes[1]) {
          case 0x01:
            debugPrint(
                "[INFO - ${DateTime.now().millisecondsSinceEpoch} ] Heart rate");
            parsedData = ResolveUtil.getMeasurementCallback(bytes, BleConst.measurementHrvCallback);
            break;
          case 0x02:
            debugPrint(
                "[INFO - ${DateTime.now().millisecondsSinceEpoch} ] HRV");
            parsedData = ResolveUtil.getMeasurementCallback(bytes, BleConst.measurementHeartCallback);
            break;
          case 0x03:
            debugPrint(
                "[INFO - ${DateTime.now().millisecondsSinceEpoch} ] SpO2");
            parsedData = ResolveUtil.getMeasurementCallback(bytes, BleConst.measurementOxygenCallback);
            break;
        }
        break;
      default:
        // Unknown command → do nothing
        break;
    }

    debugPrint("Parsed: $parsedData");
    // Only call if someone is listening
    onParsed?.call(device, data[0], data, parsedData);
  }
}
