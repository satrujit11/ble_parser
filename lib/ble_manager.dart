import 'dart:async';
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
    List<int> data, {
    bool withoutResponse = false, // ← default to safe!
  }) async {
    final String id = device.remoteId.toString();
    final c = _writeCharacteristics[id]?[charUuid.toString()];
    if (c == null) {
      debugPrint("Write failed: characteristic not found");
      return false;
    }

    try {
      await c.write(data.bytes, withoutResponse: withoutResponse);
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
        final event = NotificationEvent(device, data.bytes);
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
  final Uint8List bytes;

  NotificationEvent(this.device, this.bytes);
}
