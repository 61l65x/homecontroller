import 'package:client_flutter_basic/Providers/bledevicesinfos.dart';
import 'package:client_flutter_basic/Providers/permissionhandlers.dart';
import 'package:client_flutter_basic/blehandlers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  const HomeScreen({super.key, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isBluetooth = false; // Assuming WiFi is the default mode

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const [
          if (!kIsWeb) // Show the bluetooth only in mobile
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 500,
                  child: BluetoothContainer(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BluetoothContainer extends StatefulWidget {
  const BluetoothContainer({
    super.key,
  });

  @override
  _BluetoothContainerState createState() => _BluetoothContainerState();
}

class _BluetoothContainerState extends State<BluetoothContainer> {
  bool isBluetooth = false;
  bool blePermissionsGranted = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleBlePermissions() async {
    try {
      if (!(await FlutterBluePlus.isSupported)) {
        debugPrint("Bluetooth not supported by this device");
      } else {
        await FlutterBluePlus.turnOn();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          blePermissionsGranted = await requestAllPermissions();
          if (!blePermissionsGranted) {
            debugPrint("Not all permissions were granted.");
          }
        });
      }
    } catch (e) {
      debugPrint("Error in Bluetooth or permissions handling: $e");
    }
  }

  Future<bool> showBluetoothInfoDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth, color: Colors.blue),
                  SizedBox(width: 10), // Spacing between icon and text
                  Expanded(
                    child: Text(
                      'Bluetooth Permissions',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'To use Bluetooth, this app requires access to Bluetooth and location services. Please enable these permissions to connect to your device.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> handleBleSwitch(bool value) async {
    setState(() {
      isBluetooth = value;
    });
    if (isBluetooth && !blePermissionsGranted) {
      if (await showBluetoothInfoDialog() == false) {
        setState(() {
          isBluetooth = false;
        });
        return;
      }
      await handleBlePermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => handleBleSwitch(!isBluetooth),
                borderRadius: BorderRadius.circular(100),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isBluetooth
                          ? Icons.bluetooth_audio
                          : Icons.bluetooth_disabled,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isBluetooth)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const BleManualScanner(),
                    ));
                  },
                  child: const Text('Scan / Connect'),
                ),
            ],
          ),
          if (isBluetooth) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Connected Devices',
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_downward),
                ],
              ),
            ),
            Consumer<BleDevicesInfos>(
              builder: (context, provider, child) {
                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: provider.connectedDevices.length,
                    itemBuilder: (context, index) {
                      BluetoothDevice device = provider.connectedDevices[index];
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            device.platformName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    device.disconnect();
                                  },
                                  child: const Text('Disconnect'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    // Add your info logic here
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
