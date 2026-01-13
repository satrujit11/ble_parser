import 'dart:typed_data';
import 'package:ble_parser/constants/ble_const.dart';
import 'package:ble_parser/constants/device_constant.dart';
import 'package:ble_parser/constants/device_key.dart';
import 'package:ble_parser/models/week.dart';
import 'package:ble_parser/utils/extensions.dart';

class ResolveUtil {
  static Map<String, Object> mcuReset() {
    return {
      DeviceKey.dataType: BleConst.cmdMcuReset,
      DeviceKey.data: <String, Object>{},
      DeviceKey.end: true,
    };
  }

  static Map<String, dynamic> getDeviceTime(Uint8List data) {
    final h = (int i) => data[i].toHexString();
    final b = (int i) => data[i].shiftedBy(0).toString();

    return {
      DeviceKey.dataType: BleConst.getDeviceTime,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.deviceTime:
            "20${h(1)}-${h(2)}-${h(3)} ${h(4)}:${h(5)}:${h(6)}",
        DeviceKey.week: b(7),
        DeviceKey.mtuLength: b(8),
        DeviceKey.gpsTime: "${h(9)}.${h(10)}.${h(11)}",
      },
    };
  }

  static Map<String, dynamic> setDeviceTimeSuccessful(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.setDeviceTime,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.mtuLength: value[1].shiftedBy(0).toString(),
      },
    };
  }

  static Map<String, dynamic> getDeviceBattery(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.getDeviceBatteryLevel,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.batteryLevel: value[1].shiftedBy(0).toString(),
        DeviceKey.chargingstate: value[2].shiftedBy(0).toString(),
        DeviceKey.voltageValue:
            (value[3].shiftedBy(0) + value[4].shiftedBy(1)).toString(),
      },
    };
  }

  static Map<String, dynamic> getUserInfo(Uint8List value) {
    // Extract gender, age, height, weight, stride
    final gender = value[1].shiftedBy(0).toString();
    final age = value[2].shiftedBy(0).toString();
    final height = value[3].shiftedBy(0).toString();
    final weight = value[4].shiftedBy(0).toString();
    final stride = value[5].shiftedBy(0).toString();

    // Extract device ID (bytes 6 to 11 as ASCII chars)
    final StringBuffer deviceId = StringBuffer();
    for (int i = 6; i < 12; i++) {
      final byte = value[i];
      if (byte == 0) continue;
      deviceId.writeCharCode(byte & 0xFF); // same as Java (char) byte
    }

    return {
      DeviceKey.dataType: BleConst.getPersonalInfo,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.gender: gender,
        DeviceKey.age: age,
        DeviceKey.height: height,
        DeviceKey.weight: weight,
        DeviceKey.stride: stride,
        DeviceKey.kUserDeviceId: deviceId.toString(),
      }
    };
  }

  static Map<String, dynamic> getBasicParametersOfEquipment(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.getBasicParametersOfEquipment,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.isTheSportsModeFlashing:
            value[5].shiftedBy(0).toString() == "0" ? "0" : "1",
        DeviceKey.isTheLightFlashingWhenTheHeartRateIsTooHighInSportsMode:
            value[6].shiftedBy(0).toString() == "0" ? "0" : "1",
      },
    };
  }

  static Map<String, dynamic> getActivityData(Uint8List value) {
    int step = 0;
    int time = 0;
    int exerciseTime = 0;
    int heartRate = 0;
    int spo2 = 0;

    double calories = 0;
    double distance = 0;

    /// Steps (bytes 1–4)
    for (int i = 1; i < 5; i++) {
      step += value[i].shiftedBy(i - 1);
    }

    /// Calories (bytes 5–8)
    for (int i = 5; i < 9; i++) {
      calories += value[i].shiftedBy(i - 5);
    }

    /// Distance (bytes 9–12)
    for (int i = 9; i < 13; i++) {
      distance += value[i].shiftedBy(i - 9);
    }

    /// Exercise time (bytes 13–16) → seconds
    for (int i = 13; i < 17; i++) {
      time += value[i].shiftedBy(i - 13);
    }

    /// Active minutes (bytes 17–20)
    for (int i = 17; i < 21; i++) {
      exerciseTime += value[i].shiftedBy(i - 17);
    }

    /// Heart rate (byte 21)
    heartRate = value[21].shiftedBy(0);

    /// Temperature (bytes 22–23)
    final tempRaw = value[22].shiftedBy(0) + value[23].shiftedBy(1);
    final temperature = (tempRaw * 0.1).toStringAsFixed(1);

    /// Blood oxygen (byte 24)
    spo2 = value[24].shiftedBy(0);

    return {
      DeviceKey.dataType: BleConst.realTimeStep,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.step: step.toString(),
        DeviceKey.calories: (calories / 100).toStringAsFixed(1),
        DeviceKey.distance: (distance / 100).toStringAsFixed(2),
        DeviceKey.exerciseMinutes: (time ~/ 60).toString(),
        DeviceKey.heartRate: heartRate.toString(),
        DeviceKey.activeMinutes: exerciseTime.toString(),
        DeviceKey.tempData: temperature,
        DeviceKey.bloodOxygen: spo2.toString(),
      }
    };
  }

  static Map<String, dynamic> getAutoHeart(Uint8List value) {
    final h = (int i) => value[i].toHexString();
    final b = (int i) => value[i].shiftedBy(0).toString();
    return {
      DeviceKey.dataType: BleConst.getAutomatic,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.workMode: b(1),
        DeviceKey.startTime: h(2),
        DeviceKey.kHeartStartMinter: h(3),
        DeviceKey.endTime: h(4),
        DeviceKey.kHeartEndMinter: h(5),
        DeviceKey.weeks: WeekConfig.fromByte(value[6]),
        DeviceKey.intervalTime:
            (value[7].shiftedBy(0) + value[8].shiftedBy(1)).toString(),
      }
    };
  }

  static Map<String, dynamic> doubleClickAction(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.doubleClick,
      DeviceKey.end: true,
    };
  }

  static Map<String, dynamic> longPressAction(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.longPress,
      DeviceKey.end: true,
    };
  }

  static Map<String, dynamic> getDeviceInfo(Uint8List value) {
    return {
      DeviceKey.dataType: BleConst.getDeviceInfo,
      DeviceKey.end: true,
      DeviceKey.data: {
        DeviceKey.distanceUnit: value[1].shiftedBy(0).toString(),
        DeviceKey.timeUnit: value[2].shiftedBy(0).toString(),
        DeviceKey.wristOn: value[3].shiftedBy(0).toString(),
        DeviceKey.tempUnit: value[4].shiftedBy(0).toString(),
        DeviceKey.nightMode: value[5].shiftedBy(0).toString(),
        DeviceKey.kBaseHeart: value[9].shiftedBy(0).toString(),
        DeviceKey.screenBrightness: value[11].shiftedBy(0).toString(),
        DeviceKey.dialinterface: value[12].shiftedBy(0).toString(),
        DeviceKey.socialDistancedwitch: value[13].shiftedBy(0).toString(),
        DeviceKey.lauage: value[14].shiftedBy(0).toString(),
      }
    };
  }

  static Map<String, dynamic> deleteData(String dataType) {
    return {
      DeviceKey.dataType: dataType,
      DeviceKey.end: true,
      DeviceKey.data: {},
    };
  }

  static Map<String, dynamic> getTotalStepData(Uint8List value) {
    final Map<String, dynamic> result = {};
    result[DeviceKey.dataType] = BleConst.getTotalActivityData;
    result[DeviceKey.end] = false;
    final h = (int i) => value[i].toHexString();

    final List<Map<String, String>> list = [];
    result[DeviceKey.data] = list;

    final int count = value.stepCount;
    final int length = value.length;
    final int size = length ~/ count;

    // No records
    if (size == 0) {
      result[DeviceKey.end] = true;
      return result;
    }

    for (int i = 0; i < size; i++) {
      // ---------- END FLAG CHECK ----------
      final int flagIndex = 1 + (i + 1) * count;
      if (flagIndex < length && value[flagIndex] == 0xFF) {
        result[DeviceKey.end] = true;
      }

      // ---------- DATE ----------
      final String date = '20${h(2 + i * count)}.'
          '${h(3 + i * count)}.'
          '${h(4 + i * count)}';

      int step = 0;
      int time = 0;
      int distance = 0;
      int calories = 0;

      // ---------- STEP ----------
      for (int j = 0; j < 4; j++) {
        step += value[5 + j + i * count].shiftedBy(j);
      }

      // ---------- EXERCISE MINUTES ----------
      for (int j = 0; j < 4; j++) {
        time += value[9 + j + i * count].shiftedBy(j);
      }

      // ---------- DISTANCE ----------
      for (int j = 0; j < 4; j++) {
        distance += value[13 + j + i * count].shiftedBy(j);
      }

      // ---------- CALORIES ----------
      for (int j = 0; j < 4; j++) {
        calories += value[17 + j + i * count].shiftedBy(j);
      }

      // ---------- GOAL ----------
      final int goal = count == 26
          ? value[21 + i * count].shiftedBy(0)
          : value[21 + i * count].shiftedBy(0) +
              value[22 + i * count].shiftedBy(1);

      // ---------- MAP ----------
      final Map<String, String> item = {
        DeviceKey.date: date,
        DeviceKey.step: step.toString(),
        DeviceKey.exerciseMinutes: time.toString(),
        DeviceKey.calories: (calories / 100).toStringAsFixed(2),
        DeviceKey.distance: (distance / 100).toStringAsFixed(2),
        DeviceKey.goal: goal.toString(),
      };

      list.add(item);
    }

    return result;
  }

  static Map<String, dynamic> getSleepData(Uint8List value) {
    final Map<String, dynamic> result = {};
    result[DeviceKey.dataType] = BleConst.getDetailSleepData;
    result[DeviceKey.end] = false;

    final List<Map<String, String>> list = [];
    result[DeviceKey.data] = list;

    final bool end = value[value.length - 1] == 0xff &&
        value[value.length - 2] == DeviceConst.CMD_GET_SLEEP_DATA;
    final int length = value.length;
    if (end) {
      result[DeviceKey.end] = true;
    }

    if (length == 130 || (end && (length == 132))) {
      final Map<String, String> hashMap = {};

      String date =
          "20${value[3].bcdToString}-${value[4].bcdToString}-${value[5].bcdToString} ${value[6].bcdToString}:${value[7].bcdToString}:${value[8].bcdToString}";
      hashMap[DeviceKey.date] = date;

      final int sleepLength = value[9].shiftedBy(0);
      final StringBuffer stringBuffer = StringBuffer();

      for (int j = 0; j < sleepLength; j++) {
        stringBuffer.write(value[10 + j].shiftedBy(0));
        if (j != sleepLength - 1) {
          stringBuffer.write(' ');
        }
      }

      hashMap[DeviceKey.arraySleep] = stringBuffer.toString();
      hashMap[DeviceKey.sleepUnitLength] = "1";

      list.add(hashMap);
    } else {
      int count = 34;
      int size = length ~/ count;
      if (size == 0) {
        result[DeviceKey.data] = list;
        result[DeviceKey.end] = true;
        return result;
      }

      for (int i = 0; i < size; i++) {
        Map<String, String> hashMap = {};

        String date =
            "20${value[3 + i * count].bcdToString}-${value[4 + i * count].bcdToString}-${value[5 + i * count].bcdToString} "
            "${value[6 + i * count].bcdToString}:${value[7 + i * count].bcdToString}:${value[8 + i * count].bcdToString}";
        hashMap[DeviceKey.date] = date;

        final int sleepLength = value[9 + i * count].shiftedBy(0);
        final StringBuffer stringBuffer = StringBuffer();

        for (int j = 0; j < sleepLength; j++) {
          stringBuffer.write(value[10 + j + i * count].shiftedBy(0));
          if (j != sleepLength - 1) {
            stringBuffer.write(' ');
          }
        }

        hashMap[DeviceKey.arraySleep] = stringBuffer.toString();
        hashMap[DeviceKey.sleepUnitLength] = "5";

        list.add(hashMap);
      }
    }
    return result;
  }

  static Map<String, dynamic> getMeasurementCallback(Uint8List value, String dataType) {
    return {
      DeviceKey.dataType: dataType,
      DeviceKey.end: true,
      DeviceKey.data: {
         DeviceKey.type: value[1].shiftedBy(0).toString(),
         DeviceKey.heartRate: value[2].shiftedBy(0).toString(),
         DeviceKey.bloodOxygen: value[3].shiftedBy(0).toString(),
         DeviceKey.hrv: value[4].shiftedBy(0).toString(),
         DeviceKey.stress: value[5].shiftedBy(0).toString(),
         DeviceKey.highPressure: value[6].shiftedBy(0).toString(),
         DeviceKey.lowPressure: value[7].shiftedBy(0).toString(),
      }
    };
  }
}
