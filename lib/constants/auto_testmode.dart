enum AutoTestMode {
  autoHrv(0x01),
  autoHeartRate(0x02),
  autoSpo2(0x03);

  final int value;
  const AutoTestMode(this.value);
}
