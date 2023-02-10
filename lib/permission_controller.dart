

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  static Future<bool> checkIfBluetoothPermissionsGranted() async {
    Map<Permission, PermissionStatus> statuses;
    if(Platform.isIOS)
    {
      statuses = await [
        Permission.location, // 옛날폰 android에 필요
        Permission.bluetooth, // 옛날폰 android에 필요
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
      ].request();
    }
    else{
      statuses = await [
        Permission.location, // 옛날폰 android에 필요
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
      ].request();
    }

    bool permitted = true;
    statuses.forEach((permission, permissionStatus) {
      if (!permissionStatus.isGranted) {
        permitted = false;
      }
    });
    return permitted;
  }
  static Future<bool> checkIfVoiceRecognitionPermisionGranted() async
  {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.speech,
    ].request();
    bool permitted = true;
    statuses.forEach((permission, permissionStatus){
      if(!permissionStatus.isGranted){
        permitted = false;
      }
    });
    return permitted;
  }
  static void showNoPermissionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('권한이 허용되지 않으니 참고'),
      action: SnackBarAction(
        label: '설정창으로 이동',
        onPressed: () => openAppSettings(),
      ),
    ));
  }
}