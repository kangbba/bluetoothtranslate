

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_ask_dialog2.dart';
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
  List<BluetoothDevice> _recentBluetoothDevices = [];
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
      simpleLoadingDialog(context, "블루투스를 켜는중");
      await flutterBlue.turnOn();
      await Future.delayed(Duration(seconds: 3)); // 2초 동안 기다립니다.
      Navigator.of(context).pop();
      return true;
    }
    else{
      return false;
    }
  }
  void startScan() async {
    await stopScan();
    print("스캔을 시작합니다");


    if (!isScanning) {
      isScanning = true;
      _recentBluetoothDevices = await flutterBlue.connectedDevices;
      notifyListeners();


      flutterBlue.startScan(timeout: Duration(seconds: 3)).then((value) {

        stopScan();

      });
      _scanSubscription = flutterBlue.scanResults.listen((results) {
        // Create a set of currently discovered devices
        // Add the new results to the list
        recentScanResult.clear();
        recentScanResult.addAll(results);

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
  Stream<BluetoothDeviceState>? deviceStateStream;
  var _currentDeviceStateSubscription;
  //
  void startMonitoringConnection() {
    const Duration checkInterval = Duration(seconds: 1);
      _currentDeviceStateSubscription = Stream.periodic(checkInterval).listen((_) async {
      print("recentBluetoothDevice가 null이 아닌가? :  ${recentBluetoothDevice != null}");
      if(recentBluetoothDevice != null)
      {
        BluetoothDeviceState state = await recentBluetoothDevice!.state.first;
        print("recentBluetoothDevice의.state:  $state");

        // 연결 상태 변경 이벤트를 모니터링합니다.
        Stream<BluetoothDeviceState> deviceStateStream = recentBluetoothDevice!.state;
        deviceStateStream.listen((state) {
          if (state == BluetoothDeviceState.disconnected) {
            print('Device disconnected: ${recentBluetoothDevice!.name}');
            // 연결이 끊어졌을 때 수행할 작업을 여기에 추가하세요.
            startScan();
          }
        });
      }
      bool readyToSend = await checkIfRecentDeviceReadyToSend();
      print("recentBluetoothDevice 로인한 readyToSend는 ? :  $readyToSend");
    });


    //
    // _currentDeviceStateSubscription = Stream.periodic(checkInterval).listen((_) async {
    //   if(_selectedDeviceForm != null)
    //   {
    //     print("startMonitoringConnection... not null");
    //     final currentState = await _selectedDeviceForm!.device.state.first;
    //     if (currentState == BluetoothDeviceState.disconnected) {
    //       print("remote disconnected");
    //       _nominatedDeviceForm = _selectedDeviceForm;
    //       _selectedDeviceForm!.setDeviceStatus(DeviceStatus.disconnectedDevice);
    //       _selectedDeviceForm = null;
    //       notifyListeners();
    //     }
    //     else{
    //   //   print("successfully connected");
    //     }
    //   }
    //   else{
    //     if(_nominatedDeviceForm != null && selectedDeviceForm == null)
    //     {
    //       try {
    //         print("startMonitoringConnection... trying nominated device form trying");
    //      //   await connectDevice(_nominatedDeviceForm!, 5);
    //       }
    //       catch(e)
    //       {
    //         print("startMonitoringConnection... trying nominated device form fail");
    //       }
    //     }
    //     else{
    //       print("startMonitoringConnection... null");
    //     }
    //   }
    // });
  }

}