import 'package:flutter/material.dart';
import 'package:vest1/deviceSettings.dart';
import 'package:vest1/main.dart'; // contains MyApp.accentColor, etc.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample state variables – in a real app these would be updated from your BLE logic.
  bool isConnected = false; // if false, no device is paired
  double batteryPercentage = 0.0; // last known battery level (0.0 to 1.0)
  final List<String> vibrationPatterns = [
    'Pattern 1',
    'Pattern 2',
    'Pattern 3',
    'Pattern 4',
    'Pattern 5',
  ];

  // Variables to store selected IDs for each category.
  String? leftRightProximityAlertID;
  String? navigationAlertID;
  String? crashDetectionAlertID;

  /// Simulate loading the last state.
  void _refreshState() {
    // In a real application, you would load the last state from persistent storage
    // or update from a connected device. Here we simulate that no device is paired.
    setState(() {
      isConnected = false; // No device is paired.
      batteryPercentage = 0.0; // No battery info.
    });
  }

  /// Navigate to DeviceSettingsPage to pair a device.
  Future<void> _pairDevice() async {
    // Navigate to your pairing page.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceSettingsPage()),
    );
    // After returning, refresh state (simulate update)
    _refreshState();
  }

  @override
  void initState() {
    super.initState();
    _refreshState(); // load last known state when the app starts.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        primary: false,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          // Connection Card
          InkWell(
            onTap: () {
              if (!isConnected) {
                // If not connected, navigate to the pairing page.
                _pairDevice();
              } else {
                // If connected, show a bottom sheet with connection details.
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Connected to Device',
                              style: TextStyle(
                                  fontSize: 20, color: MyApp.accentColor),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Device Name: MyESP32',
                              style: TextStyle(
                                  fontSize: 18, color: MyApp.accentColor),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              child: const Text('Close'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: !isConnected
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not Paired",
                      style: TextStyle(
                          color: MyApp.accentColor, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pairDevice,
                      child: const Text("Pair Device"),
                    )
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Connection",
                          style: TextStyle(
                            color: MyApp.accentColor,
                            fontSize: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.signal_cellular_alt,
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Device Name",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 18),
                        ),
                        Text(
                          "MyESP32",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 24),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          // Battery Card
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Battery Details'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Battery",
                          style: TextStyle(
                            color: MyApp.accentColor,
                            fontSize: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: Builder(builder: (context) {
                            if (batteryPercentage > .85) {
                              return const Icon(Icons.battery_full);
                            } else if (batteryPercentage > .70) {
                              return const Icon(Icons.battery_5_bar);
                            } else if (batteryPercentage > .50) {
                              return const Icon(Icons.battery_4_bar);
                            } else if (batteryPercentage > .30) {
                              return const Icon(Icons.battery_3_bar);
                            } else if (batteryPercentage > .15) {
                              return const Icon(Icons.battery_2_bar);
                            } else {
                              return const Icon(Icons.battery_1_bar);
                            }
                          }),
                        )
                      ],
                    ),
                    // Removed "Time Remaining" sample text.
                    Text(
                      "${(batteryPercentage * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                          color: MyApp.accentColor, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Vibration Pattern Card
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 350,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dropdown for Left/Right Proximity Alerts
                          Text(
                            "Left/Right Proximity Alerts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MyApp.accentColor,
                            ),
                          ),
                          DropdownButton<String>(
                            value: leftRightProximityAlertID,
                            hint: Text(
                              "Select Pattern",
                              style: TextStyle(
                                color: MyApp.accentColor,
                              ),
                            ),
                            items: vibrationPatterns.map((String pattern) {
                              return DropdownMenuItem<String>(
                                value: pattern,
                                child: Text(
                                  pattern,
                                  style: TextStyle(
                                    color: MyApp.accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                leftRightProximityAlertID = newValue;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          // Dropdown for Navigation Alerts
                          Text(
                            "Navigation Alerts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MyApp.accentColor,
                            ),
                          ),
                          DropdownButton<String>(
                            value: navigationAlertID,
                            hint: Text(
                              "Select Pattern",
                              style: TextStyle(color: MyApp.accentColor),
                            ),
                            items: vibrationPatterns.map((String pattern) {
                              return DropdownMenuItem<String>(
                                value: pattern,
                                child: Text(
                                  pattern,
                                  style: TextStyle(color: MyApp.accentColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                navigationAlertID = newValue;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          // Dropdown for Crash Detection Alerts
                          Text(
                            "Crash Detection Alerts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MyApp.accentColor,
                            ),
                          ),
                          DropdownButton<String>(
                            value: crashDetectionAlertID,
                            hint: Text(
                              "Select Pattern",
                              style: TextStyle(color: MyApp.accentColor),
                            ),
                            items: vibrationPatterns.map((String pattern) {
                              return DropdownMenuItem<String>(
                                value: pattern,
                                child: Text(
                                  pattern,
                                  style: TextStyle(color: MyApp.accentColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                crashDetectionAlertID = newValue;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vibration\n Pattern",
                          style: TextStyle(
                            color: MyApp.accentColor,
                            fontSize: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.vibration),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Left/Right Proximity Alert: ${leftRightProximityAlertID ?? "Not Set"}",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 12),
                        ),
                        Text(
                          "Navigation Alert: ${navigationAlertID ?? "Not Set"}",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 12),
                        ),
                        Text(
                          "Crash Detection Alert: ${crashDetectionAlertID ?? "Not Set"}",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Updates Card
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Updates Details'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Updates",
                          style: TextStyle(
                            color: MyApp.accentColor,
                            fontSize: 24,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: MyApp.secondaryColor),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.notifications_active),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 18),
                        ),
                        Text(
                          "0",
                          style: TextStyle(
                              color: MyApp.accentColor, fontSize: 24),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
