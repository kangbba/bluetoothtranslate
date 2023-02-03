

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
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
    if (recentBluetoothDevice != null) {
      devices.sort((device1, device2) {
        if (device1.name == recentBluetoothDevice!.name) {
          return -1;
        }
        return 1;
      });
    }
    var connection;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("디바이스 선택"),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices.map((device) {
                return ListTile(
                  title: Text((device.name! != null) ? device.name! : ''),
                  onTap: () async {
                    bool? confirmed = await simpleAskDialog(context, "디바이스명 :\n${device.name}", "연결하시겠습니까?");
                    if(confirmed != null)
                    {
                      if(confirmed)
                      {
                        bool connectinSuccess = false;
                        simpleLoadingDialog(context, "연결중입니다. 잠시만 기다려 주세요.");
                        try {
                          BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
                          print('Connected to the device');
                          connectinSuccess = true;

                          recentBluetoothDevice = device;
                          recentBluetoothConnection = connection;
                          connection.input?.listen((Uint8List data) {
                            print('Data incoming: ${ascii.decode(data)}');
                            connection.output.add(data); // Sending data

                            if (ascii.decode(data).contains('!')) {
                              connection.finish(); // Closing connection
                              print('Disconnecting by local host');
                              connectinSuccess = false;
                            }
                          }).onDone(() {
                            print('Disconnected by remote request');
                            connectinSuccess = false;
                          });
                        }
                        catch (exception) {
                          print('Cannot connect, exception occured');
                          connectinSuccess = false;
                        }
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        await simpleConfirmDialog(context, '연결에 ${connectinSuccess ? '성공' : '실패'} 했습니다.', "");
                        notifyListeners();
                      }
                      else{
                        print("연결 시도 거절");
                      }
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
      print("여긴 언제작동하는가? ");
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