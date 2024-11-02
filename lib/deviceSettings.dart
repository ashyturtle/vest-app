import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vest1/main.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({Key? key}) : super(key: key);

  @override
  _DeviceSettingsPageState createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool devicePaired = false;
  bool isLoading = false;
  String? deviceId;

  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeviceIdFromPrefs();
  }

  Future<void> _loadDeviceIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedDeviceId = prefs.getString('deviceID');

    if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
      setState(() {
        deviceId = cachedDeviceId;
        devicePaired = true;
      });
    } else {
      // If no cached ID, check Firestore
      await _checkDevicePairing();
    }
  }

  Future<void> _checkDevicePairing() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      if (data.containsKey('deviceID')) {
        setState(() {
          deviceId = data['deviceID'];
          devicePaired = deviceId!.isNotEmpty;
        });
        // Cache the device ID locally
        _saveDeviceIdToPrefs(deviceId!);
      }
    }
  }

  Future<void> _saveDeviceIdToPrefs(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', deviceId);
  }

  Future<void> pairDevice() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'deviceID': _deviceIdController.text,
      });

      // Cache the device ID locally
      await _saveDeviceIdToPrefs(_deviceIdController.text);

      setState(() {
        devicePaired = true;
        deviceId = _deviceIdController.text;
      });
    } catch (e) {
      print('Failed to update device ID: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pair device. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> unpairDevice() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'deviceID': FieldValue.delete(),
      });

      // Remove the device ID from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('deviceID');

      setState(() {
        devicePaired = false;
        deviceId = null;
        _deviceIdController.clear();
      });
    } catch (e) {
      print('Failed to unpair device: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unpair device. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: devicePaired ? _buildPairedView() : _buildPairingView(),
      ),
    );
  }

  Widget _buildPairedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 100),
        SizedBox(height: 20),
        Text(
          'Your device has been added successfully!',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          'Device ID: $deviceId',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: isLoading ? null : unpairDevice,
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Unpair Device'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyApp.secondaryColor,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPairingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Please enter your Device ID to pair:',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        TextField(
          controller: _deviceIdController,
          decoration: InputDecoration(
            labelText: 'Device ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : pairDevice,
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Pair Device'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyApp.secondaryColor,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}