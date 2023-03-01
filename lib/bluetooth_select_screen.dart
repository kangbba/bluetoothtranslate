
import 'dart:async';

import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/helper/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_separator.dart';
import 'package:bluetoothtranslate/statics/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'language_select_control.dart';

enum StateCategory{
  connectedDevices,
  recentConnectedDevices,
  etcDevices
}

class BluetoothSelectScreen extends StatefulWidget {

  final BluetoothControl bluetoothControl;

  const BluetoothSelectScreen({
    required this.bluetoothControl,
    Key? key,
  }) : super(key: key);


  @override
  State<BluetoothSelectScreen> createState() => _BluetoothSelectScreenState();
}

class _BluetoothSelectScreenState extends State<BluetoothSelectScreen> {
  // TODO: 기본함수
  // void makeLanguageDatas() {
  //   for (var languageItem in languageDataList) {
  //     languageMenuItems.add(languageDropdownMenuItem(languageItem!));
  //   }
  // }

  Widget connectedIcon =  Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 30);
  Widget disconnectedIcon = Image.asset('assets/icon_disconnected.png', color: Colors.grey, width: 20, height: 20,);
  bool isFirstExcuted = true;
  @override
  initState() {
    // TODO: implement initState

    print("위젯시작");
    if(isFirstExcuted)
    {
      print("최초실행");
      isFirstExcuted = false;
    }
    startScan(true);
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    print("위젯닫음");
    startScan(false);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70,
          child: Align(alignment : Alignment.center,
              child: Text("디바이스를 선택해주세요",
                style: TextStyle(fontSize: 15, color: Colors.teal[900], fontWeight: FontWeight.w600),
              )),),
        Expanded(
          child: Column(
            children: [
              Align(alignment : Alignment.centerLeft,
                  child: Text("최근",
                    style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  )),
              FutureBuilder<BluetoothDevice?>(
                  future: widget.bluetoothControl.getValidDevice(null),
                  builder: (context, snapshotDevice) {
                    return snapshotDevice.hasData ? Column(
                      children: [
                        StreamBuilder<BluetoothDeviceState>(
                            stream: snapshotDevice.data!.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (context, snapshotState) {
                              bool isConnected = snapshotState.hasData && snapshotState.data! == BluetoothDeviceState.connected;
                              return deviceListTile(snapshotDevice.data!, isConnected ? connectedIcon : disconnectedIcon);
                            }
                        ),
                      ],
                    ) : Container();
                  }
              ),
              const SimpleSeparator(color: Colors.grey, height: 0, top: 0, bottom: 10),
              // Align(alignment : Alignment.centerLeft,
              //     child: Text("bonded",
              //       style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
              //       textAlign: TextAlign.left,
              //     )),
              // FutureBuilder<List<BluetoothDevice>>(
              //     future: widget.bluetoothControl.flutterBlue.bondedDevices,
              //     builder: (context, snapshotDevice) {
              //       return ListView.builder(
              //           shrinkWrap: true,
              //           itemCount: snapshotDevice.hasData ? snapshotDevice.data!.length : 0,
              //           itemBuilder: (context, i) {
              //             return snapshotDevice.hasData ?
              //             StreamBuilder<BluetoothDeviceState>(
              //                 stream: snapshotDevice.data![i].state,
              //                 builder: (context, snapshotState) {
              //                   BluetoothDevice device = snapshotDevice.data![i];
              //                   bool isConnected = snapshotState.hasData && snapshotState.data! == BluetoothDeviceState.connected;
              //                   return deviceListTile(device, isConnected ? connectedIcon : disconnectedIcon);
              //                 }
              //             ) : Container();
              //           });
              //     }
              // ),
              // const SimpleSeparator(color: Colors.grey, height: 0, top: 0, bottom: 10),

              StreamBuilder<List<ScanResult>>(
                stream: widget.bluetoothControl.flutterBlue.scanResults,
                initialData: const [],
                builder: (context, snapshot) {
                  return Align(alignment : Alignment.centerLeft,
                      child: SizedBox(
                        height: 17,
                        child: Text("전체 (${snapshot.hasData ? snapshot.data!.length : 0})",
                            style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left
                        ),
                      ));
                }
              ),
              Expanded(
                child: StreamBuilder<List<ScanResult>>(
                    stream: widget.bluetoothControl.flutterBlue.scanResults,
                    initialData: const [],
                    builder: (context, snapshotScanResult) {
                      if (!snapshotScanResult.hasData) {
                        return Container();
                      }
                      // List<ScanResult> filteredList = snapshotScanResult.data!.where((result) =>
                      // result.rssi > -60).toList();
                      List<ScanResult> filteredList = snapshotScanResult.data!.toList();
                      filteredList.sort((a, b) {
                        if (a.device.name.isNotEmpty && b.device.name.isEmpty) {
                          return -1;
                        } else if (a.device.name.isEmpty && b.device.name.isNotEmpty) {
                          return 1;
                        } else {
                          return b.rssi.compareTo(a.rssi);
                        }
                      });
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          itemBuilder: (context, i) {
                            return deviceListTile(filteredList[i].device, getRssiIcon(filteredList[i].rssi));
                          }
                      );
                    }
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15,),
        Align(alignment: Alignment.center, child: refreshBtn()),
        SizedBox(height: 20,)
      ],
    );
  }
  Widget getRssiIcon(int rssi) {
    if (rssi >= - 50) {
      return Icon(Icons.signal_cellular_alt_sharp);
    }
    else if (rssi >= -70) {
      return Icon(Icons.signal_cellular_alt_2_bar_sharp);
    }
    else if (rssi >= -90) {
      return Icon(Icons.signal_cellular_alt_1_bar_sharp);
    }
    else {
      return Icon(Icons.signal_cellular_no_sim_outlined, size: 15,);
    }
  }
  Widget deviceListTile(BluetoothDevice device, Widget trailingWidget)
  {
    return InkWell(
      onTap: () async {
        bool bluetoothOn = await widget.bluetoothControl.flutterBlue.isOn;
        if(!bluetoothOn){
          bool resp = await widget.bluetoothControl.checkIfBluetoothOn(context);
          return;
        }
        await onSelectedDeviceListTile(device);
      },
      child: Column(
        children: [
          ListTile(
            title: Text(device.name.isNotEmpty ? device.name! : "no name", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),
            trailing: trailingWidget,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SimpleSeparator(color: Colors.black, height: 0.3, top: 0, bottom: 0),
          )
        ],
      )
    );
  }

  onSelectedDeviceListTile(BluetoothDevice device) async{
    bool bluetoothOn = await widget.bluetoothControl.flutterBlue.isOn;
    if(!bluetoothOn){
      bool resp = await widget.bluetoothControl.checkIfBluetoothOn(context);
      return;
    }

    print("DEVICE NAME ${device.name}");
    startScan(false);
    
    BluetoothDeviceState state = await device.state.first;
    print("////////연결상태 : $state");
    if(state == BluetoothDeviceState.connected)
    {
      Navigator.of(context).pop();
    }
    else if(state == BluetoothDeviceState.disconnected) {
      print("////////연결시도중");

      simpleLoadingDialog(context, "기기에 연결중입니다.");
      bool responseDisconnect = await widget.bluetoothControl.disconnectTry(device, 3000);
      bool success = await  widget.bluetoothControl.connectTry(device, 4500);
      if(!success) {
        ScanResult? scanResultToConnect = await widget.bluetoothControl
            .getScanResult(device.name);

        BluetoothDevice? foundDevice = scanResultToConnect != null
            ? scanResultToConnect!.device
            : null;

        bool responseDisconnect = foundDevice != null ? await widget
            .bluetoothControl.disconnectTry(foundDevice, 3000) : false;
        success = foundDevice != null ? await widget.bluetoothControl.connectTry(foundDevice, 4500) : false;
      }
      else {
      }
      Navigator.of(context).pop();  // 기기에 연결중 로딩 없애기.

      if (success) { // 기기연결 성공시
      }
      else {
        await simpleConfirmDialog(context, "기기연결에 실패했습니다", "디바이스 전원을 확인하세요", "OK");
      }
      startScan(true);
      setState(() {

      });
    }
    else{
      print("/////무언가하는중");
    }
  }

  Widget refreshBtn(){
    return StreamBuilder<bool>(
      stream: widget.bluetoothControl.flutterBlue.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        if (snapshot.data!) {
          return Container(height: 40,);
        } else {
          return InkWell(
              child: const Icon(CupertinoIcons.refresh_circled_solid, size: 45, color: Colors.blueGrey,),
              onTap: () async{
                bool bluetoothOn = await widget.bluetoothControl.flutterBlue.isOn;
                if(!bluetoothOn){
                  bool resp = await widget.bluetoothControl.checkIfBluetoothOn(context);
                  return;
                }
                startScan(false);
                startScan(true);
              }
          );
        }
      },
    );
  }

  startScan(bool b){
    if(b){
      widget.bluetoothControl.flutterBlue
          .startScan(timeout: const Duration(seconds: 4));
    }else{
      widget.bluetoothControl.flutterBlue.stopScan();
    }
  }

}
