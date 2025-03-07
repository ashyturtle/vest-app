import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  static final BleManager _instance = BleManager._internal();
  factory BleManager() => _instance;
  BleManager._internal();

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? txCharacteristic; // For receiving notifications
  BluetoothCharacteristic? rxCharacteristic; // For sending commands
  bool isConnected = false;
  String batteryLevel = "--";

  final String targetDeviceName = "MyESP32";
  final Guid uartServiceUUID = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid uartRxCharacteristicUUID = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // Write
  final Guid uartTxCharacteristicUUID = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // Notify

  Future<void> connect() async {
    if (targetDevice != null && isConnected) return;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    await for (var scanResult in FlutterBluePlus.scanResults) {
      for (var result in scanResult) {
        if (result.device.name == targetDeviceName || result.advertisementData.localName == targetDeviceName) {
          targetDevice = result.device;
          FlutterBluePlus.stopScan();
          break;
        }
      }
      if (targetDevice != null) break;
    }

    if (targetDevice == null) {
      print("Device not found");
      return;
    }

    await targetDevice!.connect(autoConnect: false);
    List<BluetoothService> services = await targetDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid == uartServiceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == uartRxCharacteristicUUID) {
            rxCharacteristic = characteristic;
          }
          if (characteristic.uuid == uartTxCharacteristicUUID) {
            txCharacteristic = characteristic;
            await txCharacteristic!.setNotifyValue(true);
            txCharacteristic!.value.listen((value) {
              String data = utf8.decode(value);
              print("Received from ESP: $data");
              if (data.startsWith("Battery:")) {
                batteryLevel = data.replaceAll("Battery:", "").trim();
              }
            });
          }
        }
      }
    }
    isConnected = true;
    print("Connected to ESP via BLE");
  }

  Future<void> sendCommand(String command) async {
    if (isConnected && rxCharacteristic != null) {
      await rxCharacteristic!.write(utf8.encode(command));
      print("Sent to ESP: $command");
    } else {
      print("Not connected or RX characteristic not found");
    }
  }

  Future<void> disconnect() async {
    if (targetDevice != null) {
      await targetDevice!.disconnect();
      targetDevice = null;
      rxCharacteristic = null;
      txCharacteristic = null;
      isConnected = false;
      batteryLevel = "--";
      print("Disconnected from ESP");
    }
  }
}