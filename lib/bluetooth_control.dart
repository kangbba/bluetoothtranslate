

import 'dart:async';
import 'dart:convert';

import 'package:bluetoothtranslate/helper/simple_ask_dialog2.dart';
import 'package:bluetoothtranslate/helper/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/statics/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'language_select_control.dart';
import 'language_select_screen.dart';

class BluetoothControl extends ChangeNotifier
{


  bool _isScanning = false;
  Timer? _timer;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _validDevice;

  BluetoothDevice? get validDevice{
    return _validDevice;
  }
  set validDevice(BluetoothDevice? device)
  {
    _validDevice = device;
    notifyListeners();
  }

  Future<BluetoothDevice?> getValidDevice () async{
    bool isBluetoothOn = await flutterBlue.isOn;
    if(!isBluetoothOn){
      print("블루투스 꺼져있습니다.");
      return null;
    }
    List<BluetoothDevice> bondedDevices = await flutterBlue.connectedDevices;

    for(int i = 0 ; i < bondedDevices.length ; i++)
    {
  //    bondedDevices[i].id.toString() == SERVICE_UUID
      if(true)
      {
        BluetoothDeviceState state = await bondedDevices[i].state.first;
        if(state == BluetoothDeviceState.connected) {
          return bondedDevices[i];
        }
      }
    }
    return null;
  }
  void initializeBluetoothControl() {
    startTimer();
  }

  void onDisposeBluetoothControl()
  {
  }

  //
  scanRestart() async{
    bool isBluetoothOn = await flutterBlue.isOn;
    if(!isBluetoothOn){
      print("블루투스 꺼져있음");
      return null;
    }
    _isScanning = true;
    await scanStop();
    try{
      await flutterBlue.startScan();
    }
    catch(e){
      print("/////스캔도중 에러 $e");
    }
    finally{
      _isScanning = false;
    }
  }
  scanStop() async{
    bool isBluetoothOn = await flutterBlue.isOn;
    if(!isBluetoothOn){
      print("블루투스 꺼져있음");
      return null;
    }
    if(!_isScanning){
      return;
    }
    await flutterBlue.stopScan();
    _isScanning = false;
  }
  // scanRestart() async{
  //   if(_isScanning){
  //     print("이미 스캔중");
  //     return;
  //   }
  //   _isScanning = true;
  //   bool isBluetoothOn = await flutterBlue.isOn;
  //   if(!isBluetoothOn){
  //     print("블루투스 꺼져있음");
  //     return null;
  //   }
  //   // 스캔 시작
  //   flutterBlue.scan(timeout: Duration(seconds: 5)).listen((scanResult) {
  //     // 장치를 찾았을 때 실행할 코드
  //     print('Found device ${scanResult.device.name} (${scanResult.device.id})');
  //     notifyListeners();
  //   }, onDone: () {
  //     _isScanning = false;
  //     print('Scan completed.');
  //   });
  // }
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
      try {
        await flutterBlue.turnOn();
      } on PlatformException catch (e) {
        print("Bluetooth could not be turned on: ${e.toString()}");
        return false;
        // handle error
      }
      await Future.delayed(Duration(seconds: 3)); // 2초 동안 기다립니다.
      Navigator.of(context).pop();
      return true;
    }
    else{
      return false;
    }
  }
  Future<BluetoothService>? findService(BluetoothDevice device, String serviceUUID) async {
    List<BluetoothService> services = await device.discoverServices();
    return services.firstWhere((service) => service.uuid.toString() == serviceUUID);
  }
  BluetoothCharacteristic? findCharacteristic(BluetoothService service, String characteristicUUID) {
    return service.characteristics.firstWhere((characteristic) => characteristic.uuid.toString() == characteristicUUID);
  }
  // Future<BluetoothCharacteristic?> findCharacteristicInAllServices(BluetoothDevice device, String characteristicUUID) async{
  //   List<BluetoothService> services = await device.discoverServices();
  //   for(int i = 0 ; i < services.length ; i++)
  //   {
  //     BluetoothService service = services[i];
  //     for(int j = 0 ; j < service.characteristics.length ; j++)
  //     {
  //       String uuid =  service.characteristics[j].uuid.toString();
  //       if(uuid == characteristicUUID ){
  //         return service.characteristics[j];
  //       }
  //     }
  //   }
  //   return null;
  // }
  Future<void> writeCharacteristic(BluetoothCharacteristic characteristic, String msg) async {
    List<int> bytes = utf8.encode(msg);
    return characteristic.write(bytes);
  }

  Future<BluetoothCharacteristic> findCharacteristicByDevice(BluetoothDevice device, String serviceUUID, String characteristicUUID) async {
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


  sendMessageToSelectedDevice(BluetoothDevice device, String fullMsgToSend) async{
    try {
      await sendMessage(device, fullMsgToSend);

    } catch (e) {
      throw Exception("메세지 전송 실패 이유 : $e");
    }
  }

  Future<bool> sendMessage(BluetoothDevice device, String msg) async{
    print("${device?.name}");
    bool success = false;
    device.state.listen((state) async {
      if (state == BluetoothDeviceState.connected) {
        try{
          BluetoothCharacteristic bluetoothCharacteristic = await findCharacteristicByDevice(device, SERVICE_UUID, CHARACTERISTIC_UUID);
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

  String getFullMsg(LanguageItem targetLanguageItemToUse, String translatedMsg)
  {
    int arduinoUniqueId = targetLanguageItemToUse.langCodeArduino!;
    String fullMsgToSend = '$arduinoUniqueId:$translatedMsg;';
    return fullMsgToSend;
  }


  void startTimer() {
    // 만약 타이머가 이미 실행 중이면 중복 호출을 막습니다.
    if (_timer != null && _timer!.isActive) {
      return;
    }

    // 1초마다 callback 함수를 호출하는 타이머를 생성하고 시작합니다.
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      //widget.bluetoothControl.validDevice가 없으면 connect상태인 device를 찾아서 넣는다.
      //이미있으면 ,
      BluetoothDevice? device = await getValidDevice();
      if(validDevice == null && device != null){
        print("새로운 valideDevice 등록시키겠음");
      }
      else if(validDevice != null && device == null)
      {
        print("기존 validDevice 해제하겠음");
      }
      validDevice = device;
    });
  }


  void stopTimer() {
    // 타이머가 실행 중이면 중지합니다.
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }
}