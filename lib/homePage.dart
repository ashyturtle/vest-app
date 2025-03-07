import 'package:flutter/material.dart';
import 'package:vest1/bleManager.dart';
import 'package:vest1/deviceSettings.dart';
import 'package:vest1/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bleManager = BleManager();
  final List<String> vibrationPatterns = ['Pattern 1', 'Pattern 2', 'Pattern 3', 'Pattern 4', 'Pattern 5'];
  String? leftRightProximityAlertID;
  String? navigationAlertID;
  String? crashDetectionAlertID;

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    setState(() {
      // Update from BleManager
    });
  }

  Future<void> _pairDevice() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceSettingsPage()),
    );
    _refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          InkWell(
            onTap: () {
              if (!bleManager.isConnected) {
                _pairDevice();
              } else {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Connected to ${bleManager.targetDeviceName}', style: TextStyle(fontSize: 20, color: MyApp.accentColor)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: !bleManager.isConnected
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not Paired", style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _pairDevice, child: const Text("Pair Device")),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Connection", style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.signal_cellular_alt),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Device Name", style: TextStyle(color: MyApp.accentColor, fontSize: 18)),
                        Text(bleManager.targetDeviceName, style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) => SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Battery Details'),
                        Text("Level: ${bleManager.batteryLevel}"),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          child: const Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Battery", style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: Builder(builder: (context) {
                            double batt = double.tryParse(bleManager.batteryLevel.replaceAll("%", "")) ?? 0.0;
                            batt /= 100;
                            if (batt > 0.85) return const Icon(Icons.battery_full);
                            if (batt > 0.70) return const Icon(Icons.battery_5_bar);
                            if (batt > 0.50) return const Icon(Icons.battery_4_bar);
                            if (batt > 0.30) return const Icon(Icons.battery_3_bar);
                            if (batt > 0.15) return const Icon(Icons.battery_2_bar);
                            return const Icon(Icons.battery_1_bar);
                          }),
                        ),
                      ],
                    ),
                    Text("${bleManager.batteryLevel}", style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) => SizedBox(
                  height: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Left/Right Proximity Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyApp.accentColor)),
                        DropdownButton<String>(
                          value: leftRightProximityAlertID,
                          hint: Text("Select Pattern", style: TextStyle(color: MyApp.accentColor)),
                          items: vibrationPatterns.map((pattern) => DropdownMenuItem(value: pattern, child: Text(pattern, style: TextStyle(color: MyApp.accentColor)))).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              leftRightProximityAlertID = newValue;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        Text("Navigation Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyApp.accentColor)),
                        DropdownButton<String>(
                          value: navigationAlertID,
                          hint: Text("Select Pattern", style: TextStyle(color: MyApp.accentColor)),
                          items: vibrationPatterns.map((pattern) => DropdownMenuItem(value: pattern, child: Text(pattern, style: TextStyle(color: MyApp.accentColor)))).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              navigationAlertID = newValue;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        Text("Crash Detection Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyApp.accentColor)),
                        DropdownButton<String>(
                          value: crashDetectionAlertID,
                          hint: Text("Select Pattern", style: TextStyle(color: MyApp.accentColor)),
                          items: vibrationPatterns.map((pattern) => DropdownMenuItem(value: pattern, child: Text(pattern, style: TextStyle(color: MyApp.accentColor)))).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              crashDetectionAlertID = newValue;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Vibration\n Pattern", style: TextStyle(color: MyApp.accentColor, fontSize: 24)),
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.vibration),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Left/Right Proximity Alert: ${leftRightProximityAlertID ?? "Not Set"}", style: TextStyle(color: MyApp.accentColor, fontSize: 12)),
                        Text("Navigation Alert: ${navigationAlertID ?? "Not Set"}", style: TextStyle(color: MyApp.accentColor, fontSize: 12)),
                        Text("Crash Detection Alert: ${crashDetectionAlertID ?? "Not Set"}", style: TextStyle(color: MyApp.accentColor, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ... Updates Card (unchanged) ...
        ],
      ),
    );
  }
}