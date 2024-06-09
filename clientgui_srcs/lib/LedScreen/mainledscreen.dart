import 'package:client_flutter_basic/Providers/bledevicesinfos.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key, required this.isDark});
  final bool isDark;

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  late Color screenPickerColor; // Color for picker shown in Card on the screen.
  late Color ledColor; // Color for picker in dialog using onChanged
  late Color dialogSelectColor; // Color for picker using color select dialog.
  late double ledBrightness = 255;
  late String currentEndpoint = "PLAIN";
  List<bool> isModeSelected = [false, false];

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(const Color(0xFFFF0000)): 'Red',
    ColorTools.createPrimarySwatch(const Color(0xFF00FF00)): 'Green',
    ColorTools.createAccentSwatch(const Color(0xFF0000FF)): 'Blue',
    ColorTools.createAccentSwatch(const Color(0xFFFFFFFF)): 'White',
    ColorTools.createPrimarySwatch(const Color(0xFFFFFF00)): 'Yellow',
    ColorTools.createPrimarySwatch(const Color(0xFF00FFFF)): 'Cyan',
    ColorTools.createPrimarySwatch(const Color(0xFFFF00FF)): 'Magenta',
    ColorTools.createPrimarySwatch(const Color(0xFFFFA500)): 'Orange',
    ColorTools.createPrimarySwatch(const Color(0xFF800080)): 'Purple',
    ColorTools.createPrimarySwatch(Colors.black): 'Black :D',
  };

  @override
  void initState() {
    ledColor = Colors.red;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bleInfo = Provider.of<BleDevicesInfos>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.bluetooth),
            Text('Led Devices ${bleInfo.ledDevices.length}'),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ToggleButtons(
            isSelected: isModeSelected,
            onPressed: (int index) {
              setState(() {
                isModeSelected[index] = !isModeSelected[index];
              });
            },
            borderRadius: BorderRadius.circular(10),
            children: const [
              Padding(padding: EdgeInsets.all(16.0), child: Text('Strip')),
              Padding(padding: EdgeInsets.all(16.0), child: Text('Matrix')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  sendDataBLEHttp(null, "OFF");
                },
                icon: const Icon(Icons.power_settings_new),
                tooltip: 'Turn Off',
              ),
              const SizedBox(width: 50),
              Container(
                margin: const EdgeInsets.only(
                    top: 16), // Adjust the top margin as needed
                child: ColorIndicator(
                  width: 150,
                  height: 150,
                  borderRadius: 100,
                  color: ledColor,
                  onSelectFocus: false,
                  isSelected: false,
                  onSelect: () async {
                    // Wait for the picker to close; if the dialog was dismissed,
                    // then restore the color we had before it was opened.
                    if (!(await colorPickerDialog())) {
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 50),
              Column(
                children: [
                  // Brightness Icon
                  const Icon(Icons.brightness_high),
                  const SizedBox(height: 8), // Adjust spacing
                  RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: ledBrightness,
                      onChanged: (double value) {
                        setState(() {
                          ledBrightness = value;
                        });
                      },
                      onChangeEnd: (double value) {
                        sendDataBLEHttp(ledColor, currentEndpoint);
                      },
                      min: 0.0,
                      max: 255.0,
                      divisions: 100,
                      label: 'Brightness',
                    ),
                  ),

                  const SizedBox(height: 8), // Adjust spacing
                  const Icon(Icons.brightness_3),
                ],
              ),
            ],
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  sendDataBLEHttp(ledColor, "COMET");
                },
                icon: Image.asset(
                  'assets/shooting-star.png',
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Shooting Star',
              ),
              IconButton(
                onPressed: () {
                  sendDataBLEHttp(ledColor, "FIRE");
                },
                icon: Image.asset(
                  'assets/fireic.png',
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Set the LED on Fire',
              ),
              IconButton(
                onPressed: () {
                  sendDataBLEHttp(ledColor, "LASER");
                },
                icon: Image.asset(
                  'assets/laseric.png',
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Laser Beam',
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  sendDataBLEHttp(ledColor, "BALL");
                },
                icon: Image.asset(
                  'assets/bounceball.png',
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Bouncing Ball',
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<bool> sendBleData(String fulldata) async {
    final bleInfo = Provider.of<BleDevicesInfos>(context, listen: false);
    if (bleInfo.ledDevices.isEmpty) return false;
    for (BluetoothDevice device in bleInfo.ledDevices.keys) {
      if (isModeSelected[0]) {
        // Strip
        await bleInfo.ledDevices[device]!
            .sendDataToLedStripCharacteristic(fulldata);
      }
      if (isModeSelected[1]) {
        // Matrix
        await bleInfo.ledDevices[device]!
            .sendDataToLedMatrixCharacteristic(fulldata);
      }
    }
    return true;
  }

  // SEND THE DATA TO IPADDRESS with BLE || HTTP
  Future<void> sendDataBLEHttp(Color? color, String endpoint) async {
    String colorHex = color?.value.toRadixString(16).substring(2) ?? "ffffffff";
    String ip = kIsWeb ? 'desktopcontroller.local' : '192.168.2.76';
    String urlWithParams =
        "http://$ip/$endpoint?color=$colorHex&brightness=$ledBrightness";

    try {
      if (await sendBleData(urlWithParams)) return; // if BLE is connected

      debugPrint("Sending data: $urlWithParams");
      var response = await http.get(Uri.parse(urlWithParams));
      debugPrint(response.statusCode == 200
          ? "Color data sent successfully"
          : "NO Response from Server!: ${response.statusCode}");
    } catch (error) {
      debugPrint("Error sending color data: $error");
    }
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: ledColor,
      onColorChanged: (Color color) {
        setState(() => ledColor = color);
      },
      onColorChangeStart: (Color color) {},
      onColorChangeEnd: (Color color) {
        sendDataBLEHttp(color, "PLAIN");
      },
      width: 40,
      height: 45,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 230,
      columnSpacing: 20,
      wheelSquarePadding: 20,
      title: Text(
        'Pick Color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Color Accents',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodyMedium,
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      actionsPadding: const EdgeInsets.all(16),
      constraints:
          const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }
}
