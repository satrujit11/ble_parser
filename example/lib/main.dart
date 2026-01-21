import 'dart:async';
import 'package:ble_parser/ble_parser.dart';
import 'package:ble_parser/constants/auto_testmode.dart';
import 'package:ble_parser/models/automatic_hr_monitoring.dart';
import 'package:ble_parser/models/ble_command_state.dart';
import 'package:ble_parser/models/personal_info.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final BleManager bleManager = BleManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

  // Global notification listener
  bleManager.notificationStream.listen((event) {
    BleSDK.dataParsing(
      event.device,
      event.bytes,
      onParsed: (device, deviceConst, rawData, parsedData) {
        // switch parsedData["DataType"] {
        //   case BleConst.getPersonalInfo : _saveTime(parsedData["Data"])
        //   case BleConst.getDeviceBatteryLevel: _saveBattery(parsedData["Data"])
        // }
        // Do whatever you want with the parsed result
        // debugPrint("[LOG] Device Name: ${device.name}");
        debugPrint("[LOG] Device Constant type: ${deviceConst.cmdName}");
        // debugPrint("[LOG] Raw data: $rawData");
        // debugPrint("Parsed time: ${parsedData['deviceTime']}");
        // Do database operations here prefereably
      },
    );
  });

  runApp(const MyApp());
}

// _saveBattery (data){
//   latestdata == data
//   updatedAt
//
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Demo',
      home: const MyHomePage(title: 'Bluetooth Connections'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController.broadcast();
  final List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isBluetoothReady = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _scanResultsController.close();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final bluetoothOk = await bleManager.ensureBluetoothOn();

    if (!mounted) return; // Always check mounted after await!

    if (bluetoothOk) {
      setState(() => _isBluetoothReady = true);
      _startScan();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please turn on Bluetooth to use this app"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 10),
          ),
        );
      }
    }
  }

  void _startScan() {
    if (_isScanning || !_isBluetoothReady) return;

    debugPrint("Starting BLE Scan...");
    setState(() => _isScanning = true);
    _scanResults.clear();

    bleManager
        .scan(manufacturerIds: ManufactureConstants.manufatureIds)
        .listen(
          (result) {
            if (!mounted) return;

            final exists = _scanResults.any(
              (r) => r.device.remoteId == result.device.remoteId,
            );
            if (exists) return;

            setState(() {
              _scanResults.add(result);
              _scanResultsController.add(List.from(_scanResults));
            });
          },
          onDone: () {
            if (mounted) {
              setState(() => _isScanning = false);
              debugPrint("Scan complete");
            }
          },
          onError: (e) {
            debugPrint("Scan error: $e");
            if (mounted) setState(() => _isScanning = false);
          },
        );
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectAndListen(BluetoothDevice device) async {
    try {
      if (!bleManager.isConnected(device)) {
        await bleManager.connect(device);
        // Wait until fully connected
        await device.connectionState.firstWhere(
          (s) => s == BluetoothConnectionState.connected,
        );
        final charUuid = ManufactureConstants.notifyCharacteristic;
        await bleManager.notify(device, charUuid);
      }
    } catch (e) {
      debugPrint("❌ BLE connect/notify error: $e");
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    await bleManager.disconnect(device);
  }

  Future<void> writeTime(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.setDeviceTime();
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getTime(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getDeviceTime();
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> startMonitoring(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;

    final activityData = await BleSDK.enableActivity(true, true);
    await bleManager.write(
      device,
      charUuid,
      activityData,
      withoutResponse: true,
    );

    final data = await BleSDK.setDeviceMeasurementWithType(
      AutoTestMode.autoHeartRate,
      30,
      true,
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);

    final data2 = await BleSDK.setDeviceMeasurementWithType(
      AutoTestMode.autoHrv,
      30,
      true,
    );
    await bleManager.write(device, charUuid, data2, withoutResponse: true);

    final data3 = await BleSDK.setDeviceMeasurementWithType(
      AutoTestMode.autoSpo2,
      30,
      true,
    );
    await bleManager.write(device, charUuid, data3, withoutResponse: true);
  }

  Future<void> setUserInfo(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.setPersonalInfo(
      PersonalInfo(sex: 1, age: 30, height: 178, weight: 90),
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getUserInfo(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getPersonalInfo();
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getBasicParameters(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getBasicParamtersOfEquipment();
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getAutoMeasureConfig(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;

    final data1 = await BleSDK.getAutommaticHRMonitoring(
      AutoMode.AutoHeartRate,
    );
    await bleManager.write(device, charUuid, data1, withoutResponse: true);

    final data2 = await BleSDK.getAutommaticHRMonitoring(AutoMode.AutoHrv);
    await bleManager.write(device, charUuid, data2, withoutResponse: true);
    //
    //
    final data3 = await BleSDK.getAutommaticHRMonitoring(AutoMode.AutoSpo2);
    await bleManager.write(device, charUuid, data3, withoutResponse: true);
    //
    //
    final data4 = await BleSDK.getAutommaticHRMonitoring(AutoMode.AutoTemp);
    await bleManager.write(device, charUuid, data4, withoutResponse: true);
  }

  Future<void> setAutoMeasureConfig(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;

    final data1 = await BleSDK.setAutommaticHRMonitoring(
      AutoHRMonitoring(
        open: 2,
        startHour: 00,
        startMinute: 00,
        endHour: 23,
        endMinute: 59,
        week: 127,
        intervalMinutes: 1,
      ),
      AutoMode.AutoHeartRate,
    );
    await bleManager.write(device, charUuid, data1, withoutResponse: true);

    final data2 = await BleSDK.setAutommaticHRMonitoring(
      AutoHRMonitoring(
        open: 2,
        startHour: 00,
        startMinute: 00,
        endHour: 23,
        endMinute: 59,
        week: 127,
        intervalMinutes: 1,
      ),
      AutoMode.AutoSpo2,
    );
    await bleManager.write(device, charUuid, data2, withoutResponse: true);

    final data3 = await BleSDK.setAutommaticHRMonitoring(
      AutoHRMonitoring(
        open: 2,
        startHour: 00,
        startMinute: 00,
        endHour: 23,
        endMinute: 59,
        week: 127,
        intervalMinutes: 1,
      ),
      AutoMode.AutoHrv,
    );
    await bleManager.write(device, charUuid, data3, withoutResponse: true);

    final data4 = await BleSDK.setAutommaticHRMonitoring(
      AutoHRMonitoring(
        open: 2,
        startHour: 00,
        startMinute: 00,
        endHour: 23,
        endMinute: 59,
        week: 127,
        intervalMinutes: 1,
      ),
      AutoMode.AutoTemp,
    );
    await bleManager.write(device, charUuid, data4, withoutResponse: true);
  }

  Future<void> getAllActivityData(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getTotalActivityDataWithMode(
      DataReadingMode.startReading,
      null,
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> deleteAllActivityData(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getTotalActivityDataWithMode(
      DataReadingMode.deleteData,
      null,
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getAllSleepData(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getDetailSleepDataWithMode(
      DataReadingMode.startReading,
      null,
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> deleteAllSleepData(BluetoothDevice device) async {
    final charUuid = ManufactureConstants.writeCharacteristic;
    final data = await BleSDK.getDetailSleepDataWithMode(
      DataReadingMode.deleteData,
      null,
    );
    await bleManager.write(device, charUuid, data, withoutResponse: true);
  }

  Future<void> getBatteryLevel(BluetoothDevice device) async {
    final data = await BleSDK.getDeviceBattery();
    await bleManager.write(
      device,
      ManufactureConstants.writeCharacteristic,
      data,
      withoutResponse: true,
    );
  }

  Future<void> getOxygenData(BluetoothDevice device) async {
    final data = await BleSDK.getOxygenData(DataReadingMode.startReading, null);
    await bleManager.write(
      device,
      ManufactureConstants.writeCharacteristic,
      data,
      withoutResponse: true,
    );
  }

  Future<void> getBloodSugarData(BluetoothDevice device) async {
    final data =
        await BleSDK.ppgWithMode();
    await bleManager.write(
      device,
      ManufactureConstants.writeCharacteristic,
      data,
      withoutResponse: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? _stopScan : _startScan,
          ),
        ],
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: _scanResultsController.stream,
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];
          if (_isScanning && results.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (results.isEmpty) {
            return const Center(child: Text("No BLE devices found"));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final device = result.device;
              final name = device.platformName.isNotEmpty
                  ? device.name
                  : "Unknown Device";

              return StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: BluetoothConnectionState.disconnected,
                builder: (context, snapshot) {
                  final connectionState = snapshot.data!;
                  String statusText = switch (connectionState) {
                    BluetoothConnectionState.connected => "Connected",
                    BluetoothConnectionState.connecting => "Connecting...",
                    BluetoothConnectionState.disconnecting =>
                      "Disconnecting...",
                    BluetoothConnectionState.disconnected => "",
                  };

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        "$name ${statusText.isNotEmpty ? '- $statusText' : ''}",
                      ),
                      subtitle: Text("RSSI: ${result.rssi} dBm"),
                      trailing:
                          connectionState == BluetoothConnectionState.connected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Optional: Disconnect button
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Disconnect",
                                  onPressed: () => _disconnectDevice(device),
                                ),
                                const SizedBox(width: 8),
                                // SET TIME BUTTON
                              ],
                            )
                          : Text("${result.rssi} dBm"),
                      onTap: () async {
                        if (connectionState ==
                            BluetoothConnectionState.connected) {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await writeTime(device),
                                        icon: const Icon(
                                          Icons.access_time,
                                          size: 18,
                                        ),
                                        label: Text("Set Time"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await startMonitoring(device),
                                        icon: const Icon(
                                          Icons.access_time,
                                          size: 18,
                                        ),
                                        label: Text("Start Monitoring"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async =>
                                                  await setUserInfo(device),
                                              label: Text("Set User Info"),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async =>
                                                  await getUserInfo(device),
                                              label: Text("Get User Info"),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await getBasicParameters(device),
                                        label: Text("Get Equipment Paramaters"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async =>
                                                  await setAutoMeasureConfig(
                                                    device,
                                                  ),
                                              label: Text(
                                                "Set Auto Measure Config",
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async =>
                                                  await getAutoMeasureConfig(
                                                    device,
                                                  ),
                                              label: Text(
                                                "Get Auto Measure Config",
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await getAllActivityData(device),
                                        label: Text("Get All Activity Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await deleteAllActivityData(device),
                                        label: Text("Delete All Activity Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await getAllSleepData(device),
                                        label: Text("Get All Sleep Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await deleteAllSleepData(device),
                                        label: Text("Delete All Sleep Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await getOxygenData(device),
                                        label: Text("Get Oxygen Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),


                                    SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async =>
                                            await getBloodSugarData(device),
                                        label: Text("Get Blood Sugar Data"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          await _stopScan();
                          await _connectAndListen(device);
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
