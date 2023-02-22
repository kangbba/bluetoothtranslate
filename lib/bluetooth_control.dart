

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
  bool isScanning = false;

  StreamSubscription<List<ScanResult>>?  _scanSubscription;
  List<ScanResult> recentScanResult = [];
  void initializeBluetoothControl() {
    // startMonitoringConnection();
  }

  void onDisposeBluetoothControl()
  {
  //   stopMonitoringConnection();
  }

  Future<BluetoothDevice?> getConnectedDevice() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    //todo 나중에 내 기기의 characteristic uuid와 일치하는것을 되도록 뽑아서 반환하자.
    if(devices.isNotEmpty) {
      return devices[0];
    } else {
      return null;
    }
  }
  void startScan() async {
    await stopScan();

    if (!isScanning) {
      isScanning = true;
      flutterBlue.startScan();
      _scanSubscription = flutterBlue.scanResults.listen((results) {
        // Create a set of currently discovered devices
        final discoveredDevices = Set<ScanResult>();
        discoveredDevices.addAll(results);

        // Remove disconnected devices from the recent scan result list
        recentScanResult.removeWhere((result) => !discoveredDevices.contains(result));

        // Add the new results to the list
        recentScanResult.addAll(discoveredDevices);

        // Sort the list
        recentScanResult.sort((a, b) {
          if (a.device.name.isNotEmpty && b.device.name.isEmpty) {
            return -1;
          } else if (a.device.name.isEmpty && b.device.name.isNotEmpty) {
            return 1;
          } else {
            return 0;
          }
        });

        notifyListeners();
      });
    } else {
      print("ALREADY SCANNING");
    }
  }
  stopScan() async{
    if (isScanning) {
      isScanning = false;
      flutterBlue.stopScan();
      _scanSubscription?.cancel();
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
  //
  // Future<bool> connectDevice(DeviceForm deviceForm, int timeout) async {
  //   BluetoothDevice device = deviceForm.device;
  //   if(deviceForm.deviceStatus == DeviceStatus.connectedDevice)
  //   {
  //     _selectedDeviceForm = deviceForm;
  //     notifyListeners();
  //     return true;
  //   }
  //   else
  //   {
  //     if(_selectedDeviceForm != null && _selectedDeviceForm!.device == device)
  //     {
  //       print("같은 기기입니다");
  //       return false;
  //     }
  //     else {
  //       if (_selectedDeviceForm != null) // 기존기기가 있을경우 미리 끊어주는 작업 선행
  //           {
  //         try {
  //           print("연결된 디바이스 연결해제 시도합니다.");
  //           await _selectedDeviceForm!.device.disconnect(); // 연결해제
  //           _selectedDeviceForm!.setDeviceStatus(DeviceStatus.scannedDevice);
  //           _selectedDeviceForm = null;
  //           print("연결된 디바이스 연결해제 성공");
  //           notifyListeners();
  //         }
  //         catch (e) {
  //           print("이미 연결된 디바이스 연결해제 실패. $e");
  //           return false;
  //         }
  //       }
  //       // 새로운 기기 연결
  //       try {
  //         await device.connect(timeout: Duration(seconds: timeout));
  //         print("새로운 디바이스에 연결 성공");
  //         _selectedDeviceForm = deviceForm; // 연결성공시 할당.
  //         _selectedDeviceForm!.setDeviceStatus(DeviceStatus.connectedDevice);
  //         // 연결 상태 변화 감지
  //         notifyListeners();
  //         return true;
  //       }
  //       catch (e) {
  //         print("새로운 디바이스에 연결 실패 $e");
  //         return false;
  //       }
  //     }
  //   }
  //
  // }

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
  //
  // void startMonitoringConnection() {
  //   const Duration checkInterval = Duration(seconds: 1);
  //
  //   _currentDeviceStateSubscription = Stream.periodic(checkInterval).listen((_) async {
  //     if(_selectedDeviceForm != null)
  //     {
  //       print("startMonitoringConnection... not null");
  //       final currentState = await _selectedDeviceForm!.device.state.first;
  //       if (currentState == BluetoothDeviceState.disconnected) {
  //         print("remote disconnected");
  //         _nominatedDeviceForm = _selectedDeviceForm;
  //         _selectedDeviceForm!.setDeviceStatus(DeviceStatus.disconnectedDevice);
  //         _selectedDeviceForm = null;
  //         notifyListeners();
  //       }
  //       else{
  //     //   print("successfully connected");
  //       }
  //     }
  //     else{
  //       if(_nominatedDeviceForm != null && selectedDeviceForm == null)
  //       {
  //         try {
  //           print("startMonitoringConnection... trying nominated device form trying");
  //        //   await connectDevice(_nominatedDeviceForm!, 5);
  //         }
  //         catch(e)
  //         {
  //           print("startMonitoringConnection... trying nominated device form fail");
  //         }
  //       }
  //       else{
  //         print("startMonitoringConnection... null");
  //       }
  //     }
  //   });
  // }
  // void stopMonitoringConnection() {
  //   _currentDeviceStateSubscription?.cancel();
  // }


}