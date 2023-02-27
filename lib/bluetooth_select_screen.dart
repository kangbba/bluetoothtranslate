
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

  bool isFirstExcuted = true;
  @override
  void initState() {
    // TODO: implement initState

    print("위젯시작");
    if(isFirstExcuted)
    {
      print("최초실행");
      widget.bluetoothControl.scanRestart();
      isFirstExcuted = false;
    }
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    print("위젯닫음");
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
        Align(alignment : Alignment.centerLeft,
            child: Text("최근",
              style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            )),
        FutureBuilder<List<BluetoothDevice>>(
            future: widget.bluetoothControl.flutterBlue.bondedDevices,
            builder: (context, snapshotDevice) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshotDevice.hasData ? snapshotDevice.data!.length : 0,
                  itemBuilder: (context, i) {
                    return snapshotDevice.hasData ?
                    StreamBuilder<BluetoothDeviceState>(
                        stream: snapshotDevice.data![i].state,
                        builder: (context, snapshotState) {
                          BluetoothDevice device = snapshotDevice.data![i];
                          bool isConnected = snapshotState.hasData && snapshotState.data! == BluetoothDeviceState.connected;
                          Widget connectedIcon =  Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 30);
                          Widget disconnectedIcon = Image.asset('assets/icon_disconnected.png', color: Colors.grey, width: 20, height: 20,);
                          return deviceListTile(device, isConnected ? connectedIcon : disconnectedIcon);
                        }
                    ) : Container();
                  });
            }
        ),
        const SimpleSeparator(color: Colors.grey, height: 0, top: 0, bottom: 10),

        Align(alignment : Alignment.centerLeft,
            child: SizedBox(
              height: 17,
              child: Text("전체",
                  style: TextStyle(fontSize: 14, color: Colors.teal[900], fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left
              ),
            )),
        Expanded(
          child: StreamBuilder<List<ScanResult>>(
              stream: widget.bluetoothControl.flutterBlue.scanResults,
              builder: (context, snapshotScanResult) {
                if (!snapshotScanResult.hasData) {
                  return Container();
                }
                List<ScanResult> filteredList = snapshotScanResult.data!.where((result) =>
                result.rssi > -60).toList();

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
        SizedBox(
          height: 100,
          child: InkWell(
            onTap : () async
            {
              widget.bluetoothControl.scanRestart();
            },
            child: Icon(CupertinoIcons.refresh_thick, size: 30,)),
        )
      ],
    );
  }
  Widget getRssiIcon(int rssi) {
    if (rssi >= - 30) {
      return Icon(Icons.signal_cellular_alt_sharp);
    }
    else if (rssi >= -45) {
      return Icon(Icons.signal_cellular_alt_2_bar_sharp);
    }
    else if (rssi >= -60) {
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
        await onSelectedDeviceListTile(device);
      },
      child: Column(
        children: [
          ListTile(
            title: Text(device.name.isNotEmpty ? device.name! : "no name", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),
            trailing: trailingWidget,
          ),
          SimpleSeparator(color: Colors.black, height: 0.3, top: 0, bottom: 0)
        ],
      )
    );
  }
  connectTry(BluetoothDevice device, int timeOutMilliSec) async
  {
    try{
      await device.connect(timeout: Duration(milliseconds: timeOutMilliSec));
      return true;
    }
    catch(e){
      print("////////에러발생 $e");
      return false;
    }
    finally{
    }
  }
  disconnectTry(BluetoothDevice device, int timeOutMilliSec) async {
    try {
      await device.disconnect().timeout(Duration(milliseconds: timeOutMilliSec));
      return true;
    } catch(e) {
      print("////////에러발생 $e");
      return false;
    }
  }

  onSelectedDeviceListTile(BluetoothDevice device) async{
    BluetoothDeviceState state = await device.state.first;
    print("////////연결상태 : $state");
    if(state == BluetoothDeviceState.connected)
    {
      Navigator.of(context).pop();
    }
    else if(state == BluetoothDeviceState.disconnected)
    {
      print("////////연결시도중");

      simpleLoadingDialog(context, "기기에 연결중입니다.");
      
      print("////기존연결 해제중");
      bool responseDisconnect = await disconnectTry(device, 3000);
      print("////기존연결 해제 성공 $responseDisconnect");
      bool response = await connectTry(device, 3000);
      if(response)
      {
        Navigator.of(context).pop();
      }
      else{
        Navigator.of(context).pop();
        await simpleConfirmDialog(context, "기기연결에 실패했습니다", "OK");
      }
      widget.bluetoothControl.scanRestart();
      setState(() {

      });
    }
    else{
      print("/////무언가하는중");
    }
  }


}
