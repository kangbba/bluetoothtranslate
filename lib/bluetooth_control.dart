

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/helper/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_ask_dialog2.dart';
import 'package:bluetoothtranslate/helper/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'language_datas.dart';

class BluetoothControl extends ChangeNotifier
{
  StreamSubscription? _timerSubscription;


  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = false;

  StreamSubscription<List<ScanResult>>?  _scanSubscription;
  List<ScanResult> recentScanResult = [];
  List<BluetoothDevice> _recentBluetoothDevices = [];
  List<BluetoothDevice> _recentBondedDevices = [];
  BluetoothDevice? get recentBluetoothDevice
  {
    return _recentBluetoothDevices.isNotEmpty ? _recentBluetoothDevices[0] : null;
  }
  void initializeBluetoothControl() {
  }

  void onDisposeBluetoothControl()
  {
  }
  Future<bool> isBluetoothTurnOn() async
  {
    BluetoothState bluetoothState = await flutterBlue.state.first;
    return bluetoothState == BluetoothState.on;
  }
  Future<bool> bluetoothTurnOnDialog(BuildContext context) async
  {
    bool? bluetoothResponse = await simpleAskDialog2(context, "Bluetooth 기능이 필요합니다.", "허용", "거부");
    if(bluetoothResponse != null && bluetoothResponse)
    {
      simpleLoadingDialog(context, "블루투스를 켜는중입니다");
      await flutterBlue.turnOn();
      await Future.delayed(Duration(seconds: 3)); // 2초 동안 기다립니다.
      Navigator.of(context).pop();
      return true;
    }
    else{
      return false;
    }
  }
  startScan() async {
    await stopScan();
    print("스캔을 시작합니다");
    bool isBluetoothOn = await isBluetoothTurnOn();
    if(!isBluetoothOn)
    {
      print("블루투스부터 켜시오");
      _timerSubscription?.cancel();
      _recentBluetoothDevices.clear();
      _recentBondedDevices.clear();
      recentScanResult.clear();
      notifyListeners();

      return;
    }

    if (!isScanning) {
      isScanning = true;
      _recentBluetoothDevices.clear();
      _recentBluetoothDevices = await flutterBlue.connectedDevices;
      notifyListeners();
      // Create a timer to print the device state every second if _recentBluetoothDevices is not empty
      if (_recentBluetoothDevices.isNotEmpty) {
        if(_timerSubscription != null)
        {
          _timerSubscription?.cancel();
        }
        _timerSubscription =
            Stream.periodic(Duration(seconds: 1)).listen((_) async {
              if(_recentBluetoothDevices.isEmpty)
              {
                print("새로운 스캔으로 인해 현재연결 _recentBluetoothDevices 없어짐");
                _timerSubscription?.cancel();
                startScan();
              }
              final state = await _recentBluetoothDevices[0].state.first;
              print(state.toString());
              if (state == BluetoothDeviceState.disconnected) {
                print("현재 연결되었던 디바이스가 끊겼습니다");
                recentBluetoothDevice!.disconnect();
                _timerSubscription?.cancel();
                notifyListeners();
                startScan();
              }
            });
      }
      _recentBondedDevices.clear();
      _recentBondedDevices = await flutterBlue.bondedDevices;
      notifyListeners();
      flutterBlue.startScan(timeout: Duration(seconds: 3)).then((value) {
        stopScan();
        notifyListeners();
      });
      _scanSubscription = flutterBlue.scanResults.listen((results) {
        // Create a set of currently discovered devices
        // Add the new results to the list
        recentScanResult.clear();
        for(int i = 0 ; i < results.length ; i++)
        {
            if(results[i].device.name.isNotEmpty) {
              recentScanResult.add(results[i]);
            }
            else if(recentScanResult.length < 5)
            {
              recentScanResult.add(results[i]);
            }
            notifyListeners();
        }
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
      });
    } else {
      print("ALREADY SCANNING");
    }
    notifyListeners();
  }


  stopScan() async{
    if (isScanning) {
      print("스캔을 멈춥니다");
      isScanning = false;
      flutterBlue.stopScan();
      _scanSubscription?.cancel();
      notifyListeners();
    }
    else{
      print("스캔이 이미 멈춰있으므로 생략");
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
        try{
          BluetoothCharacteristic bluetoothCharacteristic = await findCharacteristicByDevice(device, "4fafc201-1fb5-459e-8fcc-c5c9c331914b", "beb5483e-36e1-4688-b7f5-ea07361b26a8");
          await writeCharacteristic(bluetoothCharacteristic, msg);
          print("devlog 메세지 전송 성공");
          success = true;
        }
        catch(e)
        {
          print("devlog 메세지 전송 실패 $e");
          success = false;
        }
      }
      else if (state == BluetoothDeviceState.disconnected) {
        print("devlog 메세지 전송 실패");
        success = false;
      }
    });
    return success;
  }

  Future<bool> checkIfRecentDeviceReadyToSend() async
  {
    if(recentBluetoothDevice == null)
    {
      return false;
    }
    BluetoothDeviceState bluetoothDeviceState = await recentBluetoothDevice!.state.first;
    bool isReadyToSend = bluetoothDeviceState == BluetoothDeviceState.connected;
    return isReadyToSend;
  }

  sendMessageToSelectedDevice(String fullMsgToSend) async{
    try {
      BluetoothDevice? connectedDevice = recentBluetoothDevice;
      if(connectedDevice != null) {
        await sendMessage(connectedDevice, fullMsgToSend);
      }
    } catch (e) {
      throw Exception("메세지 전송 실패 이유 : $e");
    }
  }
  String getFullMsg(LanguageItem targetLanguageItemToUse, String translatedMsg)
  {
    int arduinoUniqueId = targetLanguageItemToUse.langCodeArduino!;
    String fullMsgToSend = '$arduinoUniqueId:$translatedMsg;';
    return fullMsgToSend;
  }
}