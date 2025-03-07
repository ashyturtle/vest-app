import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vest1/bleManager.dart';
class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({Key? key}) : super(key: key);

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final bleManager = BleManager();
  bool _pairSwitchValue = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    if (await FlutterBluePlus.isSupported) {
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on && _pairSwitchValue) {
          _connect();
        } else if (state != BluetoothAdapterState.on) {
          setState(() {
            bleManager.isConnected = false;
          });
        }
      });
    }
  }

  Future<void> _connect() async {
    setState(() {
      bleManager.isConnected = false; // Reset state
    });
    await bleManager.connect();
    setState(() {});
  }

  Future<void> _disconnect() async {
    await bleManager.disconnect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _disconnect();
              if (_pairSwitchValue) await _connect();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Pair Device"),
              subtitle: const Text("Enable to connect to the device"),
              value: _pairSwitchValue,
              onChanged: (bool value) async {
                setState(() {
                  _pairSwitchValue = value;
                });
                if (value) {
                  await _connect();
                } else {
                  await _disconnect();
                }
              },
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      bleManager.isConnected ? "Connected" : "Not Connected",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Battery: ${bleManager.batteryLevel}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    bleManager.isConnected
                        ? const Icon(Icons.bluetooth_connected, color: Colors.green, size: 40)
                        : const Icon(Icons.bluetooth_disabled, color: Colors.red, size: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}