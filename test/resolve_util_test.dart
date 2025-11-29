import 'dart:typed_data';
import 'package:ble_parser/constants/ble_const.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ble_parser/utils/resolve_util.dart';
import 'package:ble_parser/constants/device_key.dart';

void main() {
  test('getDeviceTime parses correctly', () {
    // Sample data: assuming some bytes
    Uint8List value =
        Uint8List.fromList([0, 20, 1, 1, 12, 0, 0, 1, 0, 22, 1, 1]);
    var result = ResolveUtil.getDeviceTime(value);
    expect(result[DeviceKey.dataType], BleConst.getDeviceTime);
    expect(result[DeviceKey.end], true);
    // Add more assertions based on expected output
  });

  test('getValue helper works', () {
    expect(ResolveUtil.getValue(1, 0), 1);
    expect(ResolveUtil.getValue(1, 1), 256);
  });
}
