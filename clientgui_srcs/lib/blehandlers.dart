import 'dart:async';
import 'package:client_flutter_basic/Providers/bledevicesinfos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

// ENUM FOR SERVICES IN BLE STACK
enum BluetoothServiceType {
  ledService,
  anotherService,
  none,
}

class MainController {
  late BleUUIDManager bleUUIDManager;
  late BluetoothDevice device;
  String ledType; // Field to store the LED type

  MainController(this.ledType) {
    bleUUIDManager = BleUUIDManager(device);
  }

  // Method to discover and save characteristics
  Future<BluetoothServiceType> discoverAndSaveCharacteristics() async {
    return await bleUUIDManager.discoverAndSaveCharacteristics();
  }

  // Method to send data to LED strip
  Future<void> sendDataToLedStrip(String data) async {
    await bleUUIDManager.sendDataToLedStripCharacteristic(data);
  }

  // Method to send data to LED matrix
  Future<void> sendDataToLedMatrix(String data) async {
    await bleUUIDManager.sendDataToLedMatrixCharacteristic(data);
  }

  // Add more methods as needed to interact with BleUUIDManager

  // Method to update the LED type
  void setLedType(String newLedType) {
    ledType = newLedType;
    // Additional logic can be added here if needed when LED type changes
  }
}

///Class to handle BLE Led service
class BleUUIDManager {
  final BluetoothDevice _device;

  // LED Service UUID's
  String ledServiceUUID = "fce02801-f817-46a4-ad85-7448f54ee154";
  String ledStripCharUUID = "7de6d78a-6acb-4f06-b0c4-196c463e7696";
  String ledMatrixCharUUID = "a0433a8f-46a3-4921-99bd-6f311d39b22e";

  BluetoothService? _ledService;
  BluetoothCharacteristic? _ledStripCharacteristics;
  BluetoothCharacteristic? _ledMatrixCharacteristics;

  BleUUIDManager(this._device);

  // FINDS THE SERVICE & ITS CHARACTERISTICS & SAVES THEM IN THE CLASS
  Future<BluetoothServiceType> discoverAndSaveCharacteristics() async {
    final services = await _device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == ledServiceUUID) {
        _ledService = service;
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == ledStripCharUUID) {
            _ledStripCharacteristics = characteristic;
          } else if (characteristic.uuid.toString() == ledMatrixCharUUID) {
            _ledMatrixCharacteristics = characteristic;
          }
        }
        debugPrint(
            "Led Service found Added $_ledService $_ledMatrixCharacteristics $_ledStripCharacteristics");
        return BluetoothServiceType.ledService;
      }
      // Add more conditions for different services
      // if (service.uuid.toString() == anotherServiceUUID) {
      //   // Process and return another service type
      //   return BluetoothServiceType.anotherService;
      // }
    }
    return BluetoothServiceType.none; // No specific service found
  }

  Future<void> sendDataToLedStripCharacteristic(String data) async {
    await sendDataToCharacteristic(_ledStripCharacteristics, data);
  }

  Future<void> sendDataToLedMatrixCharacteristic(String data) async {
    await sendDataToCharacteristic(_ledMatrixCharacteristics, data);
  }

  BluetoothDevice? getDevice() {
    return _device;
  }

  Future<void> sendDataToCharacteristic(
    BluetoothCharacteristic? characteristic,
    String data,
  ) async {
    if (characteristic != null) {
      // CHECK FOR WRITE PROPERTY
      final isWrite = characteristic.properties.write;
      if (isWrite) {
        debugPrint("Sending data to ${characteristic.device.platformName}");
        await characteristic.write(data.codeUnits);
      } else {
        debugPrint("Characteristic does not have write property");
      }
    } else {
      debugPrint("Characteristic is null");
    }
  }
}

// SCANNER AND BUTTONS FOR CONNECTIONS
class BleManualScanner extends StatefulWidget {
  const BleManualScanner({super.key});

  @override
  _BleManualScannerState createState() => _BleManualScannerState();
}

class _BleManualScannerState extends State<BleManualScanner> {
  bool isScanning = false;
  List<BluetoothDevice> allDevices = [];

  @override
  void initState() {
    super.initState();
    startScanning();
    isScanning = true;
  }

  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      try {
        if (mounted) {
          for (ScanResult result in results) {
            if (!allDevices.contains(result.device)) {
              setState(() {
                allDevices.add(result.device);
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error in stream subscription: $e');
      }
    });
  }

  Future<void> connectToDevice(
      BluetoothDevice device, BleDevicesInfos bleConnectionState) async {
    try {
      debugPrint("Connecting to ${device.platformName}");
      await device.connect(
          autoConnect: false, timeout: const Duration(seconds: 5));

      device.connectionState.listen((event) {
        if (event == BluetoothConnectionState.disconnected) {
          bleConnectionState.removeConnectedDevice(device);
        }
      });
      bleConnectionState.addToConnectedDevices(device);
    } catch (e) {
      debugPrint("Error connecting to ${device.platformName}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleConnectionState = Provider.of<BleDevicesInfos>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
      ),
      body: ListView.builder(
        itemCount: allDevices.length,
        itemBuilder: (context, index) {
          final device = allDevices[index];
          final isConnected =
              bleConnectionState.connectedDevices.contains(device);
          return ListTile(
            title: Text(device.platformName),
            subtitle: Text(device.remoteId.toString()),
            trailing: ElevatedButton(
              onPressed: () async {
                if (!isConnected) {
                  if (isScanning) {
                    FlutterBluePlus.stopScan();
                    isScanning = false;
                  }
                  await connectToDevice(device, bleConnectionState);
                } else {
                  device.disconnect();
                }
              },
              child: Text(isConnected ? "Disconnect" : "Connect"),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    isScanning = false;
    super.dispose();
  }
}
/* AUTOMATIC SCAN AND CONNECT WITH ONE BUTTON PRESS
 NOT NEEDED YET AUTOMATIC CONNECTION WITH BLE MY OLD CODE
class BleAutoScanConnect {
  bool isScanning = false;
  List<BluetoothDevice> connectedDevices = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;
  reactive_ble.FlutterReactiveBle? flutterReactiveBle;
  bool rightMirrorSent = false;
  bool leftMirrorSent = false;

  Future<void> startScanConnect(BuildContext context, String carPlate) async {
    final bleConnectionState =
        Provider.of<BleConnectionState>(context, listen: false);
    if (isScanning) {
      return;
    }
    // SCAN AND CONNECT AUTOMATICALLY TO THE SELECTED PLATE
    await FlutterBluePlus.startScan();
    isScanning = true;
    bleConnectionState.setConnectionState(
        CarConnectionState.scanning, carPlate);
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      if (results.isNotEmpty) {
        ScanResult r = results.last;
        debugPrint(
            '${r.device.remoteId}: "${r.advertisementData.advName}" found scan!');
        if (r.device.platformName.contains(carPlate) && !r.device.isConnected) {
          String deviceName = r.device.platformName.toLowerCase();
          debugPrint("Connecting to ! --> ${r.device}");
          await r.device.connect(
              autoConnect: false, timeout: const Duration(seconds: 10));
          await flutterReactiveBle?.requestConnectionPriority(
              deviceId: r.device.remoteId.toString(),
              priority: reactive_ble.ConnectionPriority.highPerformance);
          await flutterReactiveBle?.deinitialize();
          await r.device.requestMtu(100);
          connectedDevices.add(r.device);
          connectionSubscription = r.device.connectionState
              .listen((BluetoothConnectionState state) async {
            if (state == BluetoothConnectionState.disconnected) {
              if (deviceName.contains('left')) {
                leftMirrorSent = false;
                debugPrint("DISCONNECTED LEFT!");
              } else if (deviceName.contains('right')) {
                rightMirrorSent = false;
              }
              connectedDevices.remove(r.device);
              connectionSubscription?.cancel();
              debugPrint("${r.device.disconnectReason}");
            } else if (state == BluetoothConnectionState.connected) {
              bleConnectionState.setConnectionState(
                  CarConnectionState.connected, r.device.platformName);
              debugPrint("Connected to $r.device state connected !");
              if (!leftMirrorSent && deviceName.contains('left')) {
                leftMirrorSent = true;
                await sendMirrorValues(bleConnectionState, r.device);
                connectionSubscription?.cancel();
              }
              if (!rightMirrorSent && deviceName.contains('right')) {
                rightMirrorSent = true;
                await sendMirrorValues(bleConnectionState, r.device);
                connectionSubscription?.cancel();
              }
            }
          });
        }
      }
    }, onError: (e) => debugPrint(e));
  }

  // Sends Both saved mirror positions after connecting
  Future<void> sendMirrorValues(
    BleConnectionState bleConnectionState,
    BluetoothDevice device,
  ) async {
    String sliderCharacteristics = "9b553092-16bc-49fa-ac6b-3000f4c68ef8";
    String deviceName = device.platformName.toLowerCase();

    await bleConnectionState.fetchMirrorValues();
    debugPrint("Found From Firebase --> ${bleConnectionState.mirrorValues}");
    if (deviceName.contains('left') &&
        bleConnectionState.leftDeviceValues.isNotEmpty) {
      sendDataBle(device, 'H-${bleConnectionState.leftDeviceValues['H-']!}',
          sliderCharacteristics);
      await Future.delayed(const Duration(seconds: 4));
      sendDataBle(device, 'V-${bleConnectionState.leftDeviceValues['V-']!}',
          sliderCharacteristics);
    } else if (deviceName.contains('right') &&
        bleConnectionState.rightDeviceValues.isNotEmpty) {
      sendDataBle(device, 'H-${bleConnectionState.rightDeviceValues['H-']!}',
          sliderCharacteristics);
      await Future.delayed(const Duration(seconds: 4));
      sendDataBle(device, 'V-${bleConnectionState.rightDeviceValues['V-']!}',
          sliderCharacteristics);
    }
  }

  Future<void> disconnectDevicesWithPlate(String plate) async {
    stopListening();
    List<BluetoothDevice> connectedDevices = await getConnectedDevices();
    List<BluetoothDevice> devicesToDisconnect = connectedDevices
        .where((device) => device.platformName.contains(plate))
        .toList();
    stopScanning();
    for (var device in devicesToDisconnect) {
      debugPrint('Disconnecting from device: ${device.platformName}');
      await device.disconnect();
      connectedDevices.remove(device);
    }
  }

  // Function to stop listening for connection state changes
  void stopListening() {
    scanSubscription?.cancel();
    scanSubscription = null;
    connectionSubscription?.cancel();
    connectionSubscription = null;
  }

  void stopScanning() {
    if (isScanning) {
      FlutterBluePlus.stopScan();
      isScanning = false;
    }
  }
}*/
