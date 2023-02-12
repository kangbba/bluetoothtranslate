

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceStatus{
  connectedDevice,
  scannedDevice
}
class DeviceForm extends ChangeNotifier
{
  late DeviceStatus _deviceStatus;
  late BluetoothDevice _device;
  late int? _rssi;

  DeviceStatus get deviceStatus => _deviceStatus;
  BluetoothDevice get device => _device;
  int? get rssi => _rssi;

  DeviceForm(DeviceStatus deviceStatus, BluetoothDevice device, int? rssi)
  {
    _deviceStatus = deviceStatus;
    _device = device;
    _rssi = rssi;
    notifyListeners();
  }

  void setDeviceStatus(DeviceStatus deviceStatus)
  {
    _deviceStatus = deviceStatus;
    notifyListeners();
  }
}
class BluetoothControl extends ChangeNotifier
{
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = false;
  // BluetoothDevice? _recentBluetoothDevice;
  // BluetoothDevice? get recentBluetoothDevice => _recentBluetoothDevice;
  // set recentBluetoothDevice(BluetoothDevice? value) {
  //   _recentBluetoothDevice = value;
  //   notifyListeners();
  // }
  List<DeviceForm> _deviceForms = [];

  List<DeviceForm> get deviceForms
  {
    return _deviceForms;
  }

  DeviceForm? get selectedDeviceForm
  {
    return _selectedDeviceForm;
  }
  DeviceForm? _selectedDeviceForm;

  void initializeBluetoothControl() {
  }


  void startScan() async{
    await stopScan();


    if (!isScanning) {
      isScanning = true;
      flutterBlue.startScan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 4)).then((value) {
        stopScan();
      });
      _deviceForms.clear();
      List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
      for(int i = 0 ; i < connectedDevices.length ; i++)
      {
        if(connectedDevices[i] != _selectedDeviceForm?.device)
          _deviceForms.add(DeviceForm(DeviceStatus.connectedDevice, connectedDevices[i], null));
      }
      notifyListeners();
      var subscription = flutterBlue.scanResults.listen((results) {
          for (var i = 0; i < results.length; i++) {
            var alreadyConnected = false;
            for (var j = 0; j < _deviceForms.length; j++) {
              if (_deviceForms[j]._device.id == results[i].device.id) {
                alreadyConnected = true;
                break;
              }
            }
            if (!alreadyConnected) {
              _deviceForms.add(DeviceForm(DeviceStatus.scannedDevice, results[i].device, results[i].rssi));
              _deviceForms.sort((a, b) => a.device.name.isNotEmpty ? -1 : 1);
              notifyListeners();
            }
          }
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

  Future<bool> connectDevice(DeviceForm deviceForm, int timeout) async {
    BluetoothDevice device = deviceForm.device;
    if(deviceForm.deviceStatus == DeviceStatus.connectedDevice)
    {
      _selectedDeviceForm = deviceForm;
      notifyListeners();
      return true;
    }
    else
    {
      if(_selectedDeviceForm != null && _selectedDeviceForm!.device == device)
      {
        print("같은 기기입니다");
        return false;
      }
      else {
        if (_selectedDeviceForm != null) // 기존기기가 있을경우 미리 끊어주는 작업 선행
            {
          try {
            print("연결된 디바이스 연결해제 시도합니다.");
            await _selectedDeviceForm!.device.disconnect(); // 연결해제
            _selectedDeviceForm!.setDeviceStatus(DeviceStatus.scannedDevice);
            _selectedDeviceForm = null;
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
          _selectedDeviceForm = deviceForm; // 연결성공시 할당.
          _selectedDeviceForm!.setDeviceStatus(DeviceStatus.connectedDevice);
          notifyListeners();
          return true;
        }
        catch (e) {
          print("새로운 디바이스에 연결 실패 $e");
          return false;
        }
      }
    }

  }

  Future<bool> sendMessage(BluetoothDevice device, String msg) async{
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