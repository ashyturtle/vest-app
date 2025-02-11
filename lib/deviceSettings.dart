import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({Key? key}) : super(key: key);

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  // Instance of FlutterBluePlus.
  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  // Change this to match your device's advertised name.
  final String targetDeviceName = "MyESP32";

  // Nordic UART Service UUID and its TX characteristic (notify) UUID.
  final Guid uartServiceUUID = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid uartTxCharacteristicUUID =
  Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? txCharacteristic;

  String connectionStatus = "Not Connected";
  String batteryLevel = "--";
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  /// Starts scanning for the target device.
  void _startScan() {
    setState(() {
      isScanning = true;
      connectionStatus = "Scanning for device...";
    });

    flutterBlue.(timeout: const Duration(seconds: 5)).listen(
          (ScanResult scanResult) {
        // Check if the scanned device matches the target device name.
        if (scanResult.device.name == targetDeviceName ||
            scanResult.advertisementData.localName == targetDeviceName) {
          // Device found; stop scanning.
          flutterBlue.stopScan();
          setState(() {
            targetDevice = scanResult.device;
            connectionStatus = "Device found. Connecting...";
          });
          _connectToDevice();
        }
      },
      onDone: () {
        setState(() {
          isScanning = false;
        });
        if (targetDevice == null) {
          setState(() {
            connectionStatus =
            "Device not found. Please press the button to pair.";
          });
        }
      },
    );
  }

  /// Connects to the found device and then discovers its services.
  Future<void> _connectToDevice() async {
    if (targetDevice == null) return;
    try {
      await targetDevice!.connect();
    } catch (e) {
      // The device might already be connected.
      debugPrint("Connection error: $e");
    }
    setState(() {
      connectionStatus = "Connected";
    });
    _discoverServices();
  }

  /// Discovers services on the connected device and sets up notifications
  /// on the TX characteristic (assumed to send battery info).
  Future<void> _discoverServices() async {
    if (targetDevice == null) return;
    List<BluetoothService> services = await targetDevice!.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid == uartServiceUUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid == uartTxCharacteristicUUID) {
            txCharacteristic = characteristic;
            // Enable notifications to listen for incoming data.
            await txCharacteristic!.setNotifyValue(true);
            txCharacteristic!.value.listen((value) {
              // Assuming the device sends UTF-8 encoded text.
              String received = utf8.decode(value);
              debugPrint("Received: $received");
              if (received.startsWith("Battery:")) {
                // For example, if the string is "Battery: 85%"
                setState(() {
                  batteryLevel =
                      received.replaceAll("Battery:", "").trim();
                });
              }
            });
          }
        }
      }
    }
  }

  /// Disconnects from the device.
  Future<void> _disconnectFromDevice() async {
    if (targetDevice == null) return;
    try {
      await targetDevice!.disconnect();
    } catch (e) {
      debugPrint("Disconnect error: $e");
    }
    setState(() {
      connectionStatus = "Disconnected";
      batteryLevel = "--";
      targetDevice = null;
      txCharacteristic = null;
    });
  }

  @override
  void dispose() {
    _disconnectFromDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Settings"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                connectionStatus,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                "Battery: $batteryLevel",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 40),
              // If not connected and not scanning, show a "Pair Device" button.
              if (targetDevice == null && !isScanning)
                ElevatedButton(
                  onPressed: _startScan,
                  child: const Text("Pair Device"),
                ),
              // Show a progress indicator while scanning.
              if (isScanning) const CircularProgressIndicator(),
              // If connected, show a disconnect button.
              if (targetDevice != null)
                ElevatedButton(
                  onPressed: _disconnectFromDevice,
                  child: const Text("Disconnect"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
