

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

  void initializeBluetoothControl() {
  }

  bool isScanning = false;

  void startScan() {
    if (!isScanning) {
      isScanning = true;
      flutterBlue.startScan(timeout: Duration(seconds: 4));

      var subscription = flutterBlue.scanResults.listen((results) {
        results.sort((a, b) => b.device.name.compareTo(a.device.name));
        _scanResults = results;
        notifyListeners();
      });

      subscription.onDone(() {
        isScanning = false;
        flutterBlue.stopScan();
      });
    }
  }

  void stopScan() {
    if (isScanning) {
      isScanning = false;
      flutterBlue.stopScan();
    }
  }

}