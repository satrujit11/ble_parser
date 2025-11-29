import 'dart:math' as math;
import 'dart:typed_data';
import 'package:ble_parser/constants/ble_const.dart';
import 'package:ble_parser/constants/device_key.dart';
import 'package:intl/intl.dart';

class ResolveUtil {
  static int getValue(int byte, int count) {
    return (byte & 0xff) * math.pow(256, count).toInt();
  }

  static String byteToHexString(int byte) {
    String s = byte.toRadixString(16);
    if (s.length == 1) {
      s = '0$s';
    }
    return s;
  }

  static String bcd2String(int bytes) {
    StringBuffer temp = StringBuffer();
    temp.write((bytes & 0xf0) >>> 4);
    temp.write(bytes & 0x0f);
    return temp.toString();
  }

  static double getFloat(Uint8List arr, int index) {
    ByteData byteData = ByteData.view(arr.buffer);
    return byteData.getFloat32(index, Endian.little);
  }

  static int getInt(Uint8List arr, int index) {
    ByteData byteData = ByteData.view(arr.buffer);
    return byteData.getInt32(index, Endian.little);
  }

  static NumberFormat getNumberFormat(int max) {
    NumberFormat numberFormat = NumberFormat();
    numberFormat.maximumFractionDigits = max;
    numberFormat.minimumFractionDigits = 0;
    return numberFormat;
  }

  static String byte2Hex(Uint8List data) {
    if (data.isNotEmpty) {
      StringBuffer sb = StringBuffer();
      for (int tmp in data) {
        sb.write(tmp.toRadixString(16).padLeft(2, '0').toUpperCase());
        sb.write('-');
      }
      return sb.toString();
    }
    return 'no data';
  }

  static String getByteString(int b) {
    List<int> array = List.filled(8, 0);
    StringBuffer stringBuffer = StringBuffer();
    for (int i = 0; i <= 6; i++) {
      array[i] = b & 1;
      b = b >> 1;
      stringBuffer.write(array[i]);
      if (i != 6) stringBuffer.write('-');
    }
    return stringBuffer.toString();
  }

  static String getByteArray(int b) {
    List<int> array = List.filled(8, 0);
    StringBuffer stringBuffer = StringBuffer();
    for (int i = 0; i <= 7; i++) {
      array[i] = b & 1;
      b = b >> 1;
      stringBuffer.write(array[i]);
    }
    return stringBuffer.toString();
  }

  static int getData(int length, int start, Uint8List value) {
    int data = 0;
    for (int j = 0; j < length; j++) {
      data += getValue(value[j + start], j);
    }
    return data;
  }

  static Map<String, Object> MCUReset() {
    return {
      DeviceKey.dataType: BleConst.cmdMcuReset,
      DeviceKey.data: <String, Object>{},
      DeviceKey.end: true,
    };
  }

  static Map<String, dynamic> getDeviceTime(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getDeviceTime;
    maps[DeviceKey.end] = true;

    Map<String, String> mapData = {};
    String date =
        "20${byteToHexString(value[1])}-${byteToHexString(value[2])}-${byteToHexString(value[3])} ${byteToHexString(value[4])}:${byteToHexString(value[5])}:${byteToHexString(value[6])}";
    int week = getValue(value[7], 0);
    int mtu = getValue(value[8], 0);

    String gpsDate =
        "${byteToHexString(value[9])}.${byteToHexString(value[10])}.${byteToHexString(value[11])}";
    mapData[DeviceKey.deviceTime] = date;
    mapData[DeviceKey.week] = week.toString();
    mapData[DeviceKey.mtuLength] = mtu.toString();
    mapData[DeviceKey.gpsTime] = gpsDate;
    maps[DeviceKey.data] = mapData;
    return maps;
  }

  static Map<String, dynamic> getUserInfo(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getPersonalInfo;
    maps[DeviceKey.end] = true;
    Map<String, String> mapData = {};
    maps[DeviceKey.data] = mapData;
    List<String> userInfo = List.filled(6, '');
    for (int i = 0; i < 5; i++) {
      userInfo[i] = getValue(value[i + 1], 0).toString();
    }
    String deviceId = '';
    for (int i = 6; i < 12; i++) {
      if (value[i] == 0) continue;
      deviceId += String.fromCharCode(getValue(value[i], 0));
    }
    userInfo[5] = deviceId;
    mapData[DeviceKey.gender] = userInfo[0];
    mapData[DeviceKey.age] = userInfo[1];
    mapData[DeviceKey.height] = userInfo[2];
    mapData[DeviceKey.weight] = userInfo[3];
    mapData[DeviceKey.stride] = userInfo[4];
    mapData[DeviceKey.kUserDeviceId] = userInfo[5];
    return maps;
  }

  static Map<String, dynamic> getActivityData(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.realTimeStep;
    maps[DeviceKey.end] = true;
    Map<String, String> mapData = {};
    maps[DeviceKey.data] = mapData;
    List<String> activityData = List.filled(6, '');
    int step = 0;
    double cal = 0;
    double distance = 0;
    int time = 0;
    int heart = 0;
    int exerciseTime = 0;
    for (int i = 1; i < 5; i++) {
      step += getValue(value[i], i - 1);
    }
    for (int i = 5; i < 9; i++) {
      cal += getValue(value[i], i - 5);
    }
    for (int i = 9; i < 13; i++) {
      distance += getValue(value[i], i - 9);
    }
    for (int i = 13; i < 17; i++) {
      time += getValue(value[i], i - 13);
    }
    for (int i = 17; i < 21; i++) {
      exerciseTime += getValue(value[i], i - 17);
    }
    heart = getValue(value[21], 0);
    int temp = getValue(value[22], 0) + getValue(value[23], 1);
    NumberFormat numberFormat = getNumberFormat(1);
    numberFormat.minimumFractionDigits = 1;
    double calValue = cal / 100;
    activityData[0] = step.toString();
    activityData[1] = calValue.toStringAsFixed(1);
    numberFormat.minimumFractionDigits = 2;
    activityData[2] = numberFormat.format(distance / 100);
    activityData[3] = (time ~/ 60).toString();
    activityData[4] = heart.toString();
    activityData[5] = exerciseTime.toString();
    mapData[DeviceKey.step] = activityData[0];
    mapData[DeviceKey.calories] = activityData[1];
    mapData[DeviceKey.distance] = activityData[2];
    mapData[DeviceKey.exerciseMinutes] = activityData[3];
    mapData[DeviceKey.heartRate] = activityData[4];
    mapData[DeviceKey.activeMinutes] = activityData[5];
    numberFormat.minimumFractionDigits = 1;
    mapData[DeviceKey.tempData] = numberFormat.format(temp * 0.1);
    mapData[DeviceKey.bloodOxygen] = getValue(value[24], 0).toString();
    return maps;
  }

  static Map<String, dynamic> getDeviceInfo(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getDeviceInfo;
    maps[DeviceKey.end] = true;
    Map<String, String> mapData = {};
    maps[DeviceKey.data] = mapData;
    mapData[DeviceKey.distanceUnit] = getValue(value[1], 0).toString();
    mapData[DeviceKey.timeUnit] = getValue(value[2], 0).toString();
    mapData[DeviceKey.wristOn] = getValue(value[3], 0).toString();
    mapData[DeviceKey.tempUnit] = getValue(value[4], 0).toString();
    mapData[DeviceKey.nightMode] = getValue(value[5], 0).toString();
    mapData[DeviceKey.kBaseHeart] = getValue(value[9], 0).toString();
    mapData[DeviceKey.screenBrightness] = getValue(value[11], 0).toString();
    mapData[DeviceKey.dialinterface] = getValue(value[12], 0).toString();
    mapData[DeviceKey.socialDistancedwitch] = getValue(value[13], 0).toString();
    mapData[DeviceKey.lauage] = getValue(value[14], 0).toString();
    return maps;
  }

  static Map<String, dynamic> getGoal(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getStepGoal;
    maps[DeviceKey.end] = true;
    Map<String, String> mapData = {};
    maps[DeviceKey.data] = mapData;
    int goal = 0;
    for (int i = 0; i < 4; i++) {
      goal += getValue(value[i + 1], i);
    }
    mapData[DeviceKey.stepGoal] = goal.toString();
    return maps;
  }

  static Map<String, dynamic> getDeviceBattery(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getDeviceBatteryLevel;
    maps[DeviceKey.end] = true;
    Map<String, String> mapData = {};
    maps[DeviceKey.data] = mapData;
    int battery = getValue(value[1], 0);
    int chargingstate = getValue(value[2], 0);
    int voltageValue = getValue(value[3], 0) + getValue(value[4], 1);
    mapData[DeviceKey.batteryLevel] = battery.toString();
    mapData[DeviceKey.chargingstate] = chargingstate.toString();
    mapData[DeviceKey.voltageValue] = voltageValue.toString();
    return maps;
  }

  static Map<String, dynamic> getTempData(Uint8List value) {
    Map<String, dynamic> maps = {};
    List<Map<String, String>> list = [];
    maps[DeviceKey.dataType] = BleConst.temperatureHistory;
    maps[DeviceKey.end] = false;
    maps[DeviceKey.data] = list;
    int count = 11;
    int length = value.length;
    int size = length ~/ count;
    if (size == 0 || value[length - 1] == 0xff) {
      maps[DeviceKey.end] = true;
    }
    NumberFormat numberFormat = getNumberFormat(1);
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps[DeviceKey.end] = true;
      }
      Map<String, String> hashMap = {};
      String date =
          "20${bcd2String(value[3 + i * count])}-${bcd2String(value[4 + i * count])}-${bcd2String(value[5 + i * count])} ${bcd2String(value[6 + i * count])}:${bcd2String(value[7 + i * count])}:${bcd2String(value[8 + i * count])}";
      int tempValue = getValue(value[9 + i * count], 0) +
          getValue(value[10 + i * count], 1);
      hashMap[DeviceKey.date] = date;
      hashMap[DeviceKey.temperature] = numberFormat.format(tempValue * 0.1);
      list.add(hashMap);
    }
    return maps;
  }

  static Map<String, dynamic> getHeartData(Uint8List value) {
    Map<String, dynamic> maps = {};
    maps[DeviceKey.dataType] = BleConst.getDynamicHR;
    maps[DeviceKey.end] = false;
    List<Map<String, String>> list = [];
    maps[DeviceKey.data] = list;
    int count = 24;
    int length = value.length;
    int size = length ~/ count;
    if (size == 0) {
      maps[DeviceKey.end] = true;
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps[DeviceKey.end] = true;
      }
      Map<String, String> hashMap = {};
      String date =
          "20${byteToHexString(value[3 + i * count])}-${byteToHexString(value[4 + i * count])}-${byteToHexString(value[5 + i * count])} ${byteToHexString(value[6 + i * count])}:${byteToHexString(value[7 + i * count])}:${byteToHexString(value[8 + i * count])}";
      StringBuffer stringBuffer = StringBuffer();
      for (int j = 0; j < 15; j++) {
        stringBuffer.write(getValue(value[9 + j + i * count], 0));
        if (j != 14) stringBuffer.write(' ');
      }
      hashMap[DeviceKey.date] = date;
      hashMap[DeviceKey.arrayDynamicHR] = stringBuffer.toString();
      list.add(hashMap);
    }
    return maps;
  }
}
