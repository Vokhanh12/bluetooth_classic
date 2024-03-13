import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  late BluetoothState _bluetoothState;
  late List<BluetoothDiscoveryResult> _devices = [];
  late FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _getBluetoothState();
  }

  Future<void> _getBluetoothState() async {
    _bluetoothState = await _bluetooth.state;
    if (_bluetoothState == BluetoothState.STATE_ON) {
      _startDiscovery();
    }
    setState(() {});
  }

  Future<void> _startDiscovery() async {
    if (!_isDiscovering) {
      _isDiscovering = true;
      _bluetooth.startDiscovery().listen((r) {
        setState(() {
          _devices.add(r);
        });
      }).onDone(() {
        setState(() {
          _isDiscovering = false;
        });
      });
    }
  }

  void _showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(title),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _connectToDevice(BluetoothDiscoveryResult device) async {
    if (!_isDiscovering) {
      try {
        BluetoothConnection connection =
            await BluetoothConnection.toAddress(device.device.address);
        _showSnackBar("Kết nối thành công");

        // Thực hiện nhận dữ liệu từ thiết bị
        connection.input!.listen((Uint8List data) {
          String receivedData = String.fromCharCodes(data);
          print("Received data: $receivedData");
          // Xử lý dữ liệu nhận được ở đây
        });

      } catch (e) {
        _showSnackBar("Kết nối không thành công");
        print('Không thể kết nối vào thiết bị: $e');
      }
    } else {
      _showSnackBar("Vui lòng chờ quét kết thúc trước khi kết nối.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Bluetooth State: $_bluetoothState'),
              ElevatedButton(
                onPressed: () {
                  _bluetooth.openSettings();
                },
                child: Text('Open Bluetooth Settings'),
              ),
              ElevatedButton(
                onPressed: () {
                  _startDiscovery();
                },
                child: Text('Scan Again'),
              ),
              SizedBox(height: 20),
              Text('Available Devices:'),
              Column(
                children: _devices.map((device) {
                  return ListTile(
                    title: Text(device.device.name ?? ''),
                    subtitle: Text(device.device.address),
                    onTap: () {
                      _connectToDevice(device);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}