import 'package:client_flutter_basic/HomeScreen/homescreen.dart';
import 'package:client_flutter_basic/HouseCamScreen/maincamscreen.dart';
import 'package:client_flutter_basic/LedScreen/mainledscreen.dart';
import 'package:client_flutter_basic/Providers/bledevicesinfos.dart';
import 'package:client_flutter_basic/colorpickerdemo/utils/app_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleDevicesInfos()),
      ],
      child: const MainStateClass(),
    );
  }
}

class MainStateClass extends StatefulWidget {
  const MainStateClass({super.key});

  @override
  State<MainStateClass> createState() => _MainStateClassState();
}

class _MainStateClassState extends State<MainStateClass> {
  late ThemeMode themeMode;
  bool isDarkMode = false; // Boolean to track theme mode

  @override
  void initState() {
    super.initState();
    themeMode = ThemeMode.dark;
    isDarkMode = themeMode == ThemeMode.dark;
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      isDarkMode = isDark;
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      title: 'ColorPicker',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HomeScreen'),
          actions: [
            Row(
              children: [
                Icon(isDarkMode ? Icons.brightness_4 : Icons.brightness_7),
                Switch(
                  value: isDarkMode,
                  onChanged: _toggleTheme,
                ),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          child: Builder(
            builder: (BuildContext context) {
              return ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('HouseStripper'),
                        Image.asset(
                          'assets/smart-home.png',
                          width: 60,
                          height: 60,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Led Stripper'),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fluorescent_sharp, color: Colors.red),
                        Icon(Icons.fluorescent_sharp, color: Colors.green),
                        Icon(Icons.fluorescent_sharp, color: Colors.blue),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ColorPickerPage(isDark: isDarkMode),
                        ),
                      );
                    },
                  ),
                  // New Tile: House Camera
                  ListTile(
                    title: const Text('House Camera'),
                    trailing: const Icon(Icons.videocam),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoCamPage(isDark: isDarkMode),
                        ),
                      );
                    },
                  ),
                  // Other drawer items...
                ],
              );
            },
          ),
        ),
        body: HomeScreen(isDarkMode: isDarkMode),
      ),
    );
  }
}
