

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
  // BluetoothDevice? _recentBluetoothDevice;
  // BluetoothDevice? get recentBluetoothDevice => _recentBluetoothDevice;
  // set recentBluetoothDevice(BluetoothDevice? value) {
  //   _recentBluetoothDevice = value;
  //   notifyListeners();
  // }

  List<BluetoothDevice> _connectedDevices = [];

  BluetoothDevice? get connectedDevice
  {
    return _connectedDevice;
  }
  BluetoothDevice? _connectedDevice;

  void initializeBluetoothControl() {
  }


  void startScan() async{
    await stopScan();


    if (!isScanning) {
      isScanning = true;
      flutterBlue.startScan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 4)).then((value) {
        stopScan();
      });
      _scanResults.clear();
      notifyListeners();
      var subscription = flutterBlue.scanResults.listen((results) {
        results.sort((a, b) {
          if (a.device.name.isNotEmpty && b.device.name.isNotEmpty) {
            return b.device.name.compareTo(a.device.name);
          } else if (a.device.name.isNotEmpty) {
            return -1;
          } else if (b.device.name.isNotEmpty) {
            return 1;
          } else {
            return 0;
          }
        });
        _scanResults = results;
        notifyListeners();
      });
      notifyListeners();
    }
    else{
      print("ALREADY SCANNING");
    }
  }

  stopScan() async{
    if (isScanning) {
      isScanning = false;
      await flutterBlue.stopScan();
    }
    else{
      print("ALREADY SCAN IS STOPPED");
    }
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

  Future<bool> connectDevice(BluetoothDevice device, int timeout) async {
    if(_connectedDevice != null && _connectedDevice == device)
    {
      print("같은 기기입니다");
      return false;
    }
    else {
      if (_connectedDevice != null) // 기존기기가 있을경우 미리 끊어주는 작업 선행
          {
        try {
          print("연결된 디바이스 연결해제 시도합니다.");
          await _connectedDevice!.disconnect(); // 연결해제
          _connectedDevice = null;
          print("연결된 디바이스 연결해제 성공");
          notifyListeners();
        }
        catch (e) {
          print("이미 연결된 디바이스 연결해제 실패. $e");
          return false;
        }
      }
      // 새로운 기기 연결
      try {
        await device.connect(timeout: Duration(seconds: timeout));
        print("새로운 디바이스에 연결 성공");
        _connectedDevice = device; // 연결성공시 할당.
        notifyListeners();
        return true;
      }
      catch (e) {
        print("새로운 디바이스에 연결 실패 $e");
        return false;
      }
    }
  }

  sendMessage(BluetoothDevice device, String msg) async{
    print("${device?.name}");
    bool success = false;
    device.state.listen((state) async {
      if (state == BluetoothDeviceState.connected) {
        BluetoothCharacteristic bluetoothCharacteristic = await findCharacteristicByDevice(device, "4fafc201-1fb5-459e-8fcc-c5c9c331914b", "beb5483e-36e1-4688-b7f5-ea07361b26a8");
        await writeCharacteristic(bluetoothCharacteristic, msg);
        print("devlog 메세지 전송 성공");
        success = true;
      } else if (state == BluetoothDeviceState.disconnected) {
        print("devlog 메세지 전송 실패");
        success = false;
      }
    });
    return success;
  }

}