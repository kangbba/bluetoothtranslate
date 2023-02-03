import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothControl
{
  late FlutterBluetoothSerial flutterBluetoothSerial;

  initializeBluetoothControl()
  {
    flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  }

  scanningDevices(BuildContext context) async
  {
    List<BluetoothDevice> devices = await flutterBluetoothSerial.getBondedDevices();
    var connection;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a device"),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices.map((device) {
                return ListTile(
                  title: Text((device.name != null)? device.name! : ''),
                  onTap: () async {
                    connection = await BluetoothConnection.toAddress(device.address);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (connection != null) {
      await connection.close();
    }
  }
}