import 'package:permission_handler/permission_handler.dart';

// Combined function to request all necessary permissions
Future<bool> requestAllPermissions() async {
  bool bluetoothPermissionGranted = await requestBluetoothPermissions();
  bool locationPermissionGranted = await requestLocationPermission();
  return bluetoothPermissionGranted && locationPermissionGranted;
}

// Function to request Bluetooth permissions
Future<bool> requestBluetoothPermissions() async {
  PermissionStatus bluetoothScanStatus = await Permission.bluetoothScan.status;
  PermissionStatus bluetoothConnectStatus =
      await Permission.bluetoothConnect.status;

  if (bluetoothScanStatus.isDenied || bluetoothConnectStatus.isDenied) {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.bluetoothScan, Permission.bluetoothConnect].request();
    return statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted;
  } else {
    return true;
  }
}

// Function to request Location permission
Future<bool> requestLocationPermission() async {
  final status = await Permission.location.request();
  return status.isGranted;
}
