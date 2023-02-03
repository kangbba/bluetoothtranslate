

import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothControl extends ChangeNotifier
{
  late FlutterBluetoothSerial flutterBluetoothSerial;
  BluetoothDevice? recentBluetoothDevice;
  BluetoothConnection? recentBluetoothConnection;
  initializeBluetoothControl()
  {
    flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  }
  scanningDevices(BuildContext context) async {
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
                  title: Text((device.name! != null) ? device.name! : ''),
                  onTap: () async {
                    bool? confirmed = await simpleConfirmDialog(context, "Connect to ${device.name}?");
                    if (confirmed == true) {
                      print("브루투스 연결시도!");
                      simpleLoadingDialog(context, "Connecting..");
                      connection = await BluetoothConnection.toAddress(device.address);
                      Navigator.of(context).pop();
                      recentBluetoothDevice = device;
                      recentBluetoothConnection = connection;
                      print("${device.name} 가 연결 아마 되었을겁니다. 연결상태는 ${device.isConnected}");
                      notifyListeners();
                      Navigator.of(context).pop();
                    } else {
                      print("연결실패!");
                      Navigator.of(context).pop();
                    }
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
  Future<bool> sendDataOverBluetooth(String inputStr) async {
    if(recentBluetoothConnection == null)
    {
      return false;
    }
    recentBluetoothConnection!.output.add(Uint8List.fromList(utf8.encode(inputStr)));
    await recentBluetoothConnection!.output.allSent;
    return true;
  }
}