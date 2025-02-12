import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({Key? key}) : super(key: key);

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  // Change this to match your device's advertised name.
  final String targetDeviceName = "MyESP32";

  // UUIDs for the Nordic UART Service and its TX characteristic.
  final Guid uartServiceUUID =
  Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid uartTxCharacteristicUUID =
  Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? txCharacteristic;

  String connectionStatus = "Not Connected";
  String batteryLevel = "--";
  bool isScanning = false;

  // This variable controls the Pair Device switch.
  bool _pairSwitchValue = false;

  // Subscriptions for scan results and adapter state.
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<BluetoothAdapterState>? adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetoothAndScan();
  }

  /// Initialize Bluetooth: check support, listen for adapter state changes,
  /// and (on Android) try to turn Bluetooth on.
  Future<void> _initBluetoothAndScan() async {
    // Check if Bluetooth is supported.
    bool supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      setState(() {
        connectionStatus = "Bluetooth not supported on this device.";
      });
      return;
    }

    // Listen for adapter state changes.
    adapterStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
          debugPrint("Bluetooth adapter state: $state");
          if (state == BluetoothAdapterState.on) {
            // If Bluetooth is on and the pair switch is enabled, start scanning.
            if (_pairSwitchValue && !isScanning && targetDevice == null) {
              _startScan();
            }
          } else {
            setState(() {
              connectionStatus = "Bluetooth is off. Please enable it.";
            });
          }
        });

    // For Android (not web), attempt to turn on Bluetooth.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint("Error turning on Bluetooth: $e");
      }
    }
  }

  /// Starts scanning for BLE devices.
  Future<void> _startScan() async {
    setState(() {
      isScanning = true;
      connectionStatus = "Scanning for device...";
    });

    // Start scanning with a 5-second timeout.
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to scan results.
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        // Check if the device's name or advertised local name matches.
        if (result.device.name == targetDeviceName ||
            result.advertisementData.localName == targetDeviceName) {
          // Found the target device. Stop scanning.
          FlutterBluePlus.stopScan();
          scanSubscription?.cancel();
          setState(() {
            targetDevice = result.device;
            connectionStatus = "Device found. Connecting...";
          });
          _connectToDevice();
          break;
        }
      }
    });

    // After the timeout, if no device was found, update the UI.
    Future.delayed(const Duration(seconds: 5), () {
      if (targetDevice == null) {
        setState(() {
          isScanning = false;
          connectionStatus =
          "Device not found. Please try pairing again.";
          _pairSwitchValue = false;
        });
      }
    });
  }

  /// Connects to the discovered device.
  Future<void> _connectToDevice() async {
    if (targetDevice == null) return;
    try {
      // Connect explicitly (using autoConnect: false).
      await targetDevice!.connect(autoConnect: false);
      setState(() {
        connectionStatus = "Connected";
      });
      _discoverServices();
    } catch (e) {
      setState(() {
        connectionStatus = "Connection failed";
      });
      debugPrint("Error connecting to device: $e");
    }
  }

  /// Discovers services on the device and subscribes to notifications
  /// on the UART TX characteristic.
  Future<void> _discoverServices() async {
    if (targetDevice == null) return;
    List<BluetoothService> services = await targetDevice!.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid == uartServiceUUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid == uartTxCharacteristicUUID) {
            txCharacteristic = characteristic;
            // Enable notifications for incoming data.
            await txCharacteristic!.setNotifyValue(true);
            txCharacteristic!.value.listen((value) {
              // Assuming UTF-8 encoded strings are sent.
              String data = utf8.decode(value);
              debugPrint("Received: $data");
              if (data.startsWith("Battery:")) {
                setState(() {
                  batteryLevel = data.replaceAll("Battery:", "").trim();
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
      debugPrint("Error disconnecting: $e");
    }
    setState(() {
      connectionStatus = "Disconnected";
      batteryLevel = "--";
      targetDevice = null;
      txCharacteristic = null;
      _pairSwitchValue = false;
    });
  }

  /// Refreshes the device connection by disconnecting (if connected)
  /// and then scanning again (if the switch is enabled).
  Future<void> _refreshDevice() async {
    if (isScanning) return;
    await _disconnectFromDevice();
    if (_pairSwitchValue) {
      _startScan();
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    adapterStateSubscription?.cancel();
    _disconnectFromDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevice,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pair Device switch beneath the AppBar.
            SwitchListTile(
              title: const Text("Pair Device"),
              subtitle: const Text("Enable to connect to the device"),
              value: _pairSwitchValue,
              onChanged: (bool value) {
                setState(() {
                  _pairSwitchValue = value;
                });
                if (value) {
                  _startScan();
                } else {
                  _disconnectFromDevice();
                }
              },
            ),
            const SizedBox(height: 20),
            // Card displaying connection status and battery level.
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
                      connectionStatus,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Battery: $batteryLevel",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    if (isScanning)
                      const CircularProgressIndicator()
                    else if (targetDevice != null)
                      const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                        size: 40,
                      )
                    else
                      const Icon(
                        Icons.bluetooth_disabled,
                        color: Colors.red,
                        size: 40,
                      ),
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
