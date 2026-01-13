class DeviceKey {
  static const String dataType = "DataType";
  static const String end = "End";
  static const String data = "Data";
  static const String deviceTime = "DeviceTime";
  static const String week = "Week";
  static const String mtuLength = "MTUlength";
  static const String gpsTime = "GPSTime";
  static const String gender = "Gender";
  static const String age = "Age";
  static const String height = "Height";
  static const String weight = "Weight";
  static const String stride = "Stride";
  static const String kUserDeviceId = "KUserDeviceId";
  static const String tempData = "TempData";
  static const String distanceUnit = "DistanceUnit";
  static const String timeUnit = "TimeUnit";
  static const String wristOn = "WristOn";
  static const String tempUnit = "TempUnit";
  static const String nightMode = "NightMode";
  static const String kBaseHeart = "KBaseHeart";
  static const String screenBrightness = "ScreenBrightness";
  static const String dialinterface = "Dialinterface";
  static const String socialDistancedwitch = "SocialDistancedwitch";
  static const String lauage = "Lauage";
  static const String step = "Step";
  static const String calories = "Calories";
  static const String distance = "Distance";
  static const String exerciseMinutes = "ExerciseMinutes";
  static const String heartRate = "HeartRate";
  static const String activeMinutes = "ActiveMinutes";
  static const String bloodOxygen = "BloodOxygen";
  static const String arrayX = "arrayX";
  static const String type = "type";
  static const String arrayY = "arrayY";
  static const String arrayZ = "arrayZ";
  static const String dataTypePpgRawData = "arrayPpgRawData";
  static const String stepGoal = "StepGoal";
  static const String batteryLevel = "BatteryLevel";
  static const String chargingstate = "Chargingstate";
  static const String voltageValue = "VoltageValue";
  static const String macAddress = "MacAddress";
  static const String deviceVersion = "DeviceVersion";
  static const String deviceName = "DeviceName";
  static const String isTheSportsModeFlashing = "Is_the_sports_mode_flashing";
  static const String isTheLightFlashingWhenTheHeartRateIsTooHighInSportsMode =
      "Is_the_light_flashing_when_the_Heart_Rate_is_too_high_in_sports_mode";
  static const String workMode = "WorkMode";
  static const String startTime = "StartTime";
  static const String kHeartStartMinter = "KHeartStartMinter";
  static const String endTime = "EndTime";
  static const String kHeartEndMinter = "HeartEndMinter";
  static const String weeks = "Weeks";
  static const String intervalTime = "IntervalTime";
  static const String date = "Date";
  static const String startTimeHour = "StartTimeHour";
  static const String startTimeMin = "StartTimeMin";
  static const String endTimeHour = "EndTimeHour";
  static const String endTimeMin = "EndTimeMin";
  static const String leastSteps = "LeastSteps";
  static const String goal = "Goal";
  static const String kDetailMinterStep = "KDetailMinterStep";
  static const String arraySteps = "ArraySteps";
  static const String arraySleep = "ArraySleep";
  static const String sleepUnitLength = "sleepUnitLength";
  static const String arrayDynamicHR = "ArrayDynamicHR";
  static const String staticHR = "StaticHR";
  static const String ecgValue = "ECGValue";
  static const String hrv = "HRV";
  static const String vascularAging = "VascularAging";
  static const String stress = "Stress";
  static const String highBP = "highBP";
  static const String lowBP = "lowBP";
  static const String ecgMoodValue = "ECGMoodValue";
  static const String ecgBreathValue = "ECGBreathValue";
  static const String sleepLevel = "Sleep_level";
  static const String activityData = "ActivityData";
  static const String kSleepLength = "KSleepLength";
  static const String kAlarmId = "KAlarmId";
  static const String openOrClose = "OpenOrClose";
  static const String clockType = "ClockType";
  static const String clockTime = "ClockTime";
  static const String kAlarmMinter = "KAlarmMinter";
  static const String kAlarmContent = "KAlarmContent";
  static const String kAlarmLength = "KAlarmLength";
  static const String kDataID = "KDataID";
  static const String latitude = "Latitude";
  static const String longitude = "Longitude";
  static const String activityMode = "ActivityMode";
  static const String pace = "Pace";
  static const String kActivityLocationTime = "KActivityLocationTime";
  static const String kActivityLocationLatitude = "KActivityLocationLatitude";
  static const String kActivityLocationLongitude = "KActivityLocationLongitude";
  static const String kActivityLocationCount = "KActivityLocationCount";
  static const String axillaryTemperature = "axillaryTemperature";
  static const String temperature = "temperature";
  static const String ecgStatus = "EcgStatus";
  static const String ecgResultValue = "ECGResultValue";
  static const String ecgHrvValue = "ECGHrvValue";
  static const String ecgAvBlockValue = "ECGAvBlockValue";
  static const String ecgHrValue = "ECGHrValue";
  static const String ecgStreesValue = "ECGStreesValue";
  static const String ecgHighBpValue = "ECGhighBpValue";
  static const String ecgLowBpValue = "ECGLowBpValue";
  static const String ecgMoodValue2 = "ECGMoodValue";
  static const String ecgBreathValue2 = "ECGBreathValue";
  static const String khrvBloodLowPressure = "KHrvBloodLowPressure";
  static const String kHrvBloodHighPressure = "KHrvBloodHighPressure";
  static const String temperatureCorrectionValue = "TemperatureCorrectionValue";
  static const String month = "Month";
  static const String day = "Day";
  static const String menstrualPeriodLenth = "MenstrualPeriod_Lenth";
  static const String menstrualPeriodPeriod = "MenstrualPeriod_Period";
  static const String year = "Year";
  static const String kClockLast = "KClockLast";
  static const String fatiguedegree = "Fatiguedegree";
  static const String highPressure = "HighPressure";
  static const String lowPressure = "LowPressure";
  static const String ecgResult = "ECGResult";
  static const String enterEcg = "ENTERECG";
  static const String exerciseToggle = "ExerciseToggle";
  static const String longPress = "LongPress";
}

extension DeviceDataMapExt on Map<String, dynamic>? {
  /// Equivalent to Java getDataType()
  String get dataType {
    if (this == null) return "";
    return this![DeviceKey.dataType] as String? ?? "";
  }

  /// Equivalent to Java getEnd()
  bool get isEnd {
    if (this == null) return true;
    return this![DeviceKey.end] as bool? ?? true;
  }

  /// Equivalent to Java getData() — returns the actual payload
  Map<String, dynamic> get data {
    if (this == null) return {};
    final raw = this![DeviceKey.data];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return {};
  }
}
