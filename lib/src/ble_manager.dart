import 'dart:async';
import 'dart:io';
import 'package:ble_parser/constants/manufacture_support.constants.dart';
import 'package:ble_parser/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  final Map<String, BluetoothDevice> _connectedDevices = {};
  final Map<String, Map<String, BluetoothCharacteristic>>
      _notifyCharacteristics = {};
  final Map<String, Map<String, BluetoothCharacteristic>>
      _writeCharacteristics = {};
  final Map<String, StreamSubscription<List<int>>> _notifySubscriptions = {};

  /// Global notification stream for all devices
  final StreamController<NotificationEvent> _notificationController =
      StreamController.broadcast();

  Stream<NotificationEvent> get notificationStream =>
      _notificationController.stream;

  Future<bool> ensureBluetoothOn({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // 1. Hardware support
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("Bluetooth not supported on this device");
      return false;
    }

    FlutterBluePlus.setOptions(
      restoreState: true,
      showPowerAlert: true,
    );

    // 2. Already ON → fast path
    if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
      debugPrint("Bluetooth already ON");
      return true;
    }

    // 3. iOS → cannot auto-enable
    if (Platform.isIOS) {
      debugPrint("iOS: Bluetooth is OFF → please enable in Settings");
      return false;
    }

    // 4. Android → request + wait for real state change
    if (Platform.isAndroid) {
      debugPrint("Android: Bluetooth OFF → requesting turn on...");

      // Fire the system dialog
      FlutterBluePlus.turnOn(); // void → ignore

      try {
        await FlutterBluePlus.adapterState
            .where((state) => state == BluetoothAdapterState.on)
            .first
            .timeout(timeout, onTimeout: () {
          throw TimeoutException(
            "User did not turn on Bluetooth within ${timeout.inSeconds}s",
          );
        });

        debugPrint("Bluetooth is now ON and ready!");
        return true;
      } on TimeoutException catch (e) {
        debugPrint("Timeout waiting for Bluetooth ON: $e");
        return false;
      } catch (e) {
        debugPrint("Unexpected error waiting for Bluetooth: $e");
        return false;
      }
    }

    return false;
  }

  /// Scan for devices by optional name filter
  Stream<ScanResult> scan({
    List<String>? nameFilter,
    List<int>? manufacturerIds,
    Duration timeout = const Duration(seconds: 10),
  }) {
    FlutterBluePlus.startScan(
        timeout: timeout,
        withMsd: manufacturerIds?.map((id) => MsdFilter(id)).toList() ?? []);
    return FlutterBluePlus.scanResults.expand((results) => results).where((r) {
      if (nameFilter == null) return true;
      return nameFilter.any((name) =>
          r.device.platformName.toLowerCase().contains(name.toLowerCase()));
    });
  }

  /// Connect to device and discover notify characteristic
  Future<void> connect(BluetoothDevice device,
      {bool autoConnect = true}) async {
    try {
      if (_connectedDevices.containsKey(device.remoteId.toString())) return;

      await device.connect(
        autoConnect: autoConnect,
        license: License.free,
        mtu: autoConnect ? null : 517,
      );

      // Wait until fully connected
      await device.connectionState
          .firstWhere((s) => s == BluetoothConnectionState.connected);

      _connectedDevices[device.remoteId.toString()] = device;

      // Now safe to discover services
      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toInt16 == ManufactureConstants.customService,
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toInt16 == ManufactureConstants.notifyCharacteristic,
      );

      _notifyCharacteristics[device.remoteId.toString()] = {
        characteristic.uuid.toInt16.toString(): characteristic
      };

      final characteristic2 = service.characteristics.firstWhere(
        (c) => c.uuid.toInt16 == ManufactureConstants.writeCharacteristic,
      );

      _writeCharacteristics[device.remoteId.toString()] = {
        characteristic2.uuid.toInt16.toString(): characteristic2
      };
    } catch (e) {
      debugPrint("Error from connect: " + e.toString());
    }
  }

  /// Disconnect device
  Future<void> disconnect(BluetoothDevice device) async {
    await _notifySubscriptions[device.remoteId.toString()]?.cancel();
    await device.disconnect();
    _connectedDevices.remove(device.remoteId.toString());
    _notifyCharacteristics.remove(device.remoteId.toString());
    _writeCharacteristics.remove(device.remoteId.toString());
    _notifySubscriptions.remove(device.remoteId.toString());
  }

  /// Write data to characteristic
  Future<bool> write(
    BluetoothDevice device,
    int charUuid,
    Uint8List data, {
    bool withoutResponse = false, // ← default to safe!
  }) async {
    final String id = device.remoteId.toString();
    final c = _writeCharacteristics[id]?[charUuid.toString()];
    if (c == null) {
      debugPrint("Write failed: characteristic not found");
      return false;
    }

    try {
      await c.write(data.toListInt, withoutResponse: withoutResponse);
      debugPrint("Write SUCCESS: ${data.hex}");
      return true;
    } catch (e) {
      debugPrint("Write FAILED: $e");
      return false;
    }
  }

  /// Subscribe to notifications and emit to global stream
  Future<Stream<List<int>>?> notify(
      BluetoothDevice device, int charUuid) async {
    try {
      // Wait until device is connected
      await device.connectionState
          .firstWhere((s) => s == BluetoothConnectionState.connected);
      debugPrint("✅ Connected to ${device.remoteId} (${charUuid}) from notify");

      // Make sure characteristic map exists
      if (!_notifyCharacteristics.containsKey(device.remoteId.toString())) {
        await connect(device); // will populate _characteristics
      }

      final c = _notifyCharacteristics[device.remoteId.toString()]
          ?[charUuid.toString()];
      if (c == null) return null;

      await c.setNotifyValue(true);
      final stream = c.lastValueStream.asBroadcastStream();

      // Keep subscription so we can cancel on disconnect
      _notifySubscriptions[device.remoteId.toString()] = stream.listen((data) {
        final event = NotificationEvent(device, data);
        _notificationController.add(event); // emit globally
      });

      return stream;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  bool isConnected(BluetoothDevice device) =>
      _connectedDevices.containsKey(device.remoteId.toString());
}

/// Model for notification event
class NotificationEvent {
  final BluetoothDevice device;
  final List<int> bytes;

  NotificationEvent(this.device, this.bytes);
}
