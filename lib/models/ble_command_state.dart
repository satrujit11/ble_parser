class BleCommandState {
  static bool deleteGetDetailsSleepData = false;
  static bool deleteTotalActivityDataWithMode = false;
}

enum DataReadingMode {
  startReading(0x00),
  continueReading(0x02),
  deleteData(0x99);

  final int value;
  const DataReadingMode(this.value);
}
