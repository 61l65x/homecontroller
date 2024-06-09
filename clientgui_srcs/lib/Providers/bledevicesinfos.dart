import 'package:client_flutter_basic/blehandlers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDevicesInfos extends ChangeNotifier {
  List<BluetoothDevice> connectedDevices = [];
  Map<BluetoothDevice, BleUUIDManager> ledDevices = {};

  // Check the devices services and characteristics and assign them
  Future<void> checkAndAssignManagers() async {
    for (BluetoothDevice device in connectedDevices) {
      if (!ledDevices.containsKey(device)) {
        final manager = BleUUIDManager(device);
        final serviceType = await manager.discoverAndSaveCharacteristics();
        if (serviceType == BluetoothServiceType.ledService) {
          ledDevices[device] = manager;
        }
      }
    }
    notifyListeners();
  }

  void addToConnectedDevices(BluetoothDevice device) {
    if (!connectedDevices.contains(device)) {
      connectedDevices.add(device);
      checkAndAssignManagers();
    }
    notifyListeners();
  }

  void removeConnectedDevice(BluetoothDevice device) {
    if (connectedDevices.contains(device)) {
      connectedDevices.remove(device);
      ledDevices.remove(device);
    }
    notifyListeners();
  }

  void disconnectAllDevices() {
    for (BluetoothDevice device in connectedDevices) {
      device.disconnect();
    }
    connectedDevices.clear();
    ledDevices.clear();
    notifyListeners();
  }
}
