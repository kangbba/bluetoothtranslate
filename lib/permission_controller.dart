import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  static final List<Permission> bluetoothPermissions = Platform.isIOS
      ? [
    Permission.location, // 옛날폰 android에 필요
    Permission.bluetooth, // 옛날폰 android에 필요
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
  ]
      : [
    Permission.location, // 옛날폰 android에 필요
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
  ];

  static final List<Permission> voiceRecognitionPermissions = [
    Permission.microphone,
    Permission.speech,
  ];

  static Future<bool> checkIfPermissionsGranted(List<Permission> permissions) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool permitted = true;
    statuses.forEach((permission, permissionStatus) {
      print("현재 $permission 허용상태 : ${permissionStatus.isGranted}");
      if (!permissionStatus.isGranted) {
        permitted = false;
      }
    });
    return permitted;
  }



  static Future<bool> checkIfBluetoothPermissionsGranted() async {
    return checkIfPermissionsGranted(bluetoothPermissions);
  }

  static Future<bool> checkIfVoiceRecognitionPermissionGranted() async {
    return checkIfPermissionsGranted(voiceRecognitionPermissions);
  }

  static void showNoPermissionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('권한이 허용되지 않았습니다. 설정 - 어플리케이션 - 권한을 확인하세요'),
      action: SnackBarAction(
        label: '설정창으로 이동',
        onPressed: () => openAppSettings(),
      ),
    ));
  }
}
