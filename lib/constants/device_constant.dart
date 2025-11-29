/// Device command constants for BLE communication.
class DeviceConst {
  static const int CMD_SET_TIME = 0x01;
  static const int CMD_GET_TIME = 0x41;
  static const int CMD_SET_USE_INFO = 0x02;
  static const int CMD_GET_USERINFO = 0x42;
  static const int CMD_SET_DEVICE_ID = 0x05;
  static const int CMD_ENABLE_ACTIVITY = 0x09;
  static const int CMD_GET_BATTERY_LEVEL = 0x13;
  static const int CMD_GET_ADDRESS = 0x22;
  static const int CMD_GET_VERSION = 0x27;
  static const int CMD_RESET = 0x12;
  static const int CMD_MCU_RESET = 0x2E;
  static const int CMD_SET_AUTO = 0x2A;
  static const int CMD_GET_AUTO = 0x2B;
  static const int CMD_GET_TOTAL_DATA = 0x51;
  static const int CMD_GET_DETAIL_DATA = 0x52;
  static const int CMD_GET_SLEEP_DATA = 0x53;
  static const int CMD_GET_HEART_DATA = 0x54;
  static const int CMD_GET_ONCE_HEART_DATA = 0x55;
  static const int CMD_GET_HRV_TEST_DATA = 0x56;
  static const int READ_TEMP_HISTORY = 0x62;
  static const int OXYGEN_DATA = 0x66;

  static const int MEASUREMENT_WITH_TYPE = 0x28;
  static const int CMD_START_EXERCISE = 0x19;
  static const int CMD_HEART_PACKAGE = 0x17;
  static const int CMD_HEART_PACKAGE_FROM_DEVICE = 0x18;
  static const int CMD_SET_NAME = 0x3D;
  static const int CMD_GET_NAME = 0x3E;

  static const int CMD_GET_SPORT_DATA = 0x5C;

  static const int CMD_GET_BLOODSUGAR = 0x78;
  static const int BLOODSUGAR_DATA = 0x3A; // 血糖数据
  static const int OBTAIN_DETAILED_SLEEP_DATA = 0x6B;
  static const int TEMPERATURE_3NTC = 0x14;
  static const int SET_BASIC_PARAMETERS_OF_EQUIPMENT = 0x03;
  static const int GET_BASIC_PARAMETERS_OF_EQUIPMENT = 0x04;

  static final Map<int, String> _commandNames = {
    CMD_SET_TIME: "CMD_SET_TIME",
    CMD_GET_TIME: "CMD_GET_TIME",
    CMD_SET_USE_INFO: "CMD_SET_USE_INFO",
    CMD_GET_USERINFO: "CMD_GET_USERINFO",
    CMD_SET_DEVICE_ID: "CMD_SET_DEVICE_ID",
    CMD_ENABLE_ACTIVITY: "CMD_ENABLE_ACTIVITY",
    CMD_GET_BATTERY_LEVEL: "CMD_GET_BATTERY_LEVEL",
    CMD_GET_ADDRESS: "CMD_GET_ADDRESS",
    CMD_GET_VERSION: "CMD_GET_VERSION",
    CMD_RESET: "CMD_RESET",
    CMD_MCU_RESET: "CMD_MCU_RESET",
    CMD_SET_AUTO: "CMD_SET_AUTO",
    CMD_GET_AUTO: "CMD_GET_AUTO",
    CMD_GET_TOTAL_DATA: "CMD_GET_TOTAL_DATA",
    CMD_GET_DETAIL_DATA: "CMD_GET_DETAIL_DATA",
    CMD_GET_SLEEP_DATA: "CMD_GET_SLEEP_DATA",
    CMD_GET_HEART_DATA: "CMD_GET_HEART_DATA",
    CMD_GET_ONCE_HEART_DATA: "CMD_GET_ONCE_HEART_DATA",
    CMD_GET_HRV_TEST_DATA: "CMD_GET_HRV_TEST_DATA",
    READ_TEMP_HISTORY: "READ_TEMP_HISTORY",
    OXYGEN_DATA: "OXYGEN_DATA",
    MEASUREMENT_WITH_TYPE: "MEASUREMENT_WITH_TYPE",
    CMD_START_EXERCISE: "CMD_START_EXERCISE",
    CMD_HEART_PACKAGE: "CMD_HEART_PACKAGE",
    CMD_HEART_PACKAGE_FROM_DEVICE: "CMD_HEART_PACKAGE_FROM_DEVICE",
    CMD_SET_NAME: "CMD_SET_NAME",
    CMD_GET_NAME: "CMD_GET_NAME",
    CMD_GET_SPORT_DATA: "CMD_GET_SPORT_DATA",
    CMD_GET_BLOODSUGAR: "CMD_GET_BLOODSUGAR",
    BLOODSUGAR_DATA: "BLOODSUGAR_DATA",
    OBTAIN_DETAILED_SLEEP_DATA: "OBTAIN_DETAILED_SLEEP_DATA",
    TEMPERATURE_3NTC: "TEMPERATURE_3NTC",
    SET_BASIC_PARAMETERS_OF_EQUIPMENT: "SET_BASIC_PARAMETERS_OF_EQUIPMENT",
    GET_BASIC_PARAMETERS_OF_EQUIPMENT: "GET_BASIC_PARAMETERS_OF_EQUIPMENT",
  };

  static String getCommandName(int value) {
    return _commandNames[value] ??
        "UNKNOWN_CMD_0x${value.toRadixString(16).toUpperCase().padLeft(2, '0')}";
  }

  /// Optional: Pretty version for logs/UI
  static String getPrettyName(int value) {
    final name = _commandNames[value];
    if (name == null) return "Unknown(0x${value.toRadixString(16)})";
    return name.replaceFirst("CMD_", "").replaceAll("_", " ");
  }
}

extension BleCommandExt on int {
  String get cmdName => DeviceConst.getCommandName(this);
  String get prettyCmd => DeviceConst.getPrettyName(this);
}
