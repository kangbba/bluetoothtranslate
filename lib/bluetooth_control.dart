

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothControl extends ChangeNotifier
{
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> _scanResults = [];
  List<ScanResult> get scanResults => _scanResults;
  bool isScanning = false;

  StreamSubscription<List<ScanResult>>? subscription;
  BluetoothDevice? _recentBluetoothDevice;
  BluetoothDevice? get recentBluetoothDevice => _recentBluetoothDevice;
  set recentBluetoothDevice(BluetoothDevice? value) {
    _recentBluetoothDevice = value;
    notifyListeners();
  }

  void initializeBluetoothControl() {
  }


  void startScan() async{
    await stopScan();
    if (!isScanning) {
      isScanning = true;
      flutterBlue.startScan();

      subscription = flutterBlue.scanResults.listen((results) {
        results.sort((a, b) => b.device.name.compareTo(a.device.name));
        _scanResults = results;
        notifyListeners();
      });

      // subscription!.onDone(() {
      //   flutterBlue.stopScan();
      // });
    }
    else{
      print("ALREADY SCANNING");
    }
  }

  stopScan() async{
    if (isScanning) {
      isScanning = false;
      subscription?.cancel();
      await flutterBlue.stopScan();
    }
    else{
      print("ALREADY SCAN IS STOPPED");
    }
    notifyListeners();
  }


  Future<BluetoothService>? findService(BluetoothDevice device, String serviceUUID) async {
    List<BluetoothService> services = await device.discoverServices();
    return services.firstWhere((service) => service.uuid.toString() == serviceUUID);
  }
  BluetoothCharacteristic? findCharacteristic(BluetoothService service, String characteristicUUID) {
    return service.characteristics.firstWhere((characteristic) => characteristic.uuid.toString() == characteristicUUID);
  }
  Future<void> writeCharacteristic(BluetoothCharacteristic characteristic, String msg) async {
    List<int> bytes = utf8.encode(msg);
    return characteristic.write(bytes);
  }

  Future<BluetoothCharacteristic> findCharacteristicByDevice(
      BluetoothDevice device, String serviceUUID, String characteristicUUID) async {
    BluetoothService? targetService = await findService(device, serviceUUID);
    if (targetService == null) {
      print('Service not found');
      throw Exception('Service not found');
    }
    try {
      BluetoothCharacteristic targetCharacteristic =
      targetService.characteristics.firstWhere(
              (element) => element.uuid.toString() == characteristicUUID);
      return targetCharacteristic;
    } catch (e) {
      print('Characteristic not found');
      throw Exception('Characteristic not found');
    }
  }

  Future<bool> connectDevice(BluetoothDevice device) async {
    if(device == _recentBluetoothDevice)
    {
      print("이미 그 Device");
      return false;
    }
    try {
      await device.connect();
      if(_recentBluetoothDevice != null) {
        print("기존 연결 ${_recentBluetoothDevice!.name} Disconnect");
        await _recentBluetoothDevice!.disconnect();
        notifyListeners();
      }
      _recentBluetoothDevice = device;
      notifyListeners();
      return true;
    } catch (error) {
      // Handle the error
      print("연결실패");
      return false;
    }
  }

  sendMessage(String msg) async{
    BluetoothDevice? device = recentBluetoothDevice;
    print("${device?.name}");
    bool success = false;
    if (device != null) {
      device.state.listen((state) async {
        if (state == BluetoothDeviceState.connected) {
          BluetoothCharacteristic bluetoothCharacteristic = await findCharacteristicByDevice(device, "4fafc201-1fb5-459e-8fcc-c5c9c331914b", "beb5483e-36e1-4688-b7f5-ea07361b26a8");
          await writeCharacteristic(bluetoothCharacteristic, msg);
          print("devlog 메세지 전송 성공");
          success = true;
        } else if (state == BluetoothDeviceState.disconnected) {
          print("devlog 메세지 전송 실패");
          await connectDevice(device);
        }
      });
    }
    return success;
  }

}