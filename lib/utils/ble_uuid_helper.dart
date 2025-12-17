class BleHelper {
  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  static String getUUID(int shortHex) {
    final hexStr = shortHex.toRadixString(16).padLeft(4, '0');
    return "0000$hexStr-0000-1000-8000-00805f9b34fb";
  }
}
