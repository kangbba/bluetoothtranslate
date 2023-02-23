import 'dart:async';
import 'dart:ffi';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_ask_dialog2.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_separator.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'bluetooth_control.dart';


class DeviceSelectScreen extends StatefulWidget {
  final BluetoothControl bluetoothControl;

  const DeviceSelectScreen({Key? key, required this.bluetoothControl}) : super(key: key);

  @override
  _DeviceSelectScreenState createState() => _DeviceSelectScreenState();
}

class _DeviceSelectScreenState extends State<DeviceSelectScreen> {

  late BluetoothControl _bluetoothControl = widget.bluetoothControl;

  @override
  void initState() {
    super.initState();
    startMonitoringConnection();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    stopMonitoringConnection();
    print("Device Select Screen에서 stop scan");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ListenableProvider<BluetoothControl>(
            create: (_) => _bluetoothControl,
          ),
        ],
        child: Consumer<BluetoothControl>(
            builder: (context, bluetoothControl, child) {
              return Stack(
                children: [
                  Positioned(top: 8, left: 8,
                      child: _exitBtn(context)),
                  Positioned(top: 8, right: 10,
                      child: _refreshBtn(bluetoothControl)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 34,
                          child: Container(),
                        ),
                        SimpleSeparator(color: Colors.deepPurpleAccent,
                            height: .2,
                            top: 0,
                            bottom: 8),
                        deviceListView_selected(bluetoothControl),
                        SizedBox(height: 10,),
                        Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Other Devices (${bluetoothControl
                                        .recentScanResult.length})",
                                        textAlign: TextAlign.left),
                                    SizedBox(width: 20,),
                                    bluetoothControl.isScanning
                                        ? loadingAnimationWhenScan(
                                        bluetoothControl)
                                        : Container(),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                deviceListView_otherDevices(bluetoothControl),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
        )
    );
  }

  Widget deviceListView_selected(BluetoothControl bluetoothControl) {
    return bluetoothControl.recentBluetoothDevice != null ?
    Column(
        children: [
          SizedBox(width: double.infinity,
              height: 22,
              child: Text("Connected", textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, color: Colors.black87),)),
          deviceListTile(
              context, bluetoothControl.recentBluetoothDevice!, true),
        ]
    ) : Container();
  }

  Widget deviceListView_otherDevices(BluetoothControl bluetoothControl) {
    // SizedBox(width: double.infinity, child: Text("Connected", textAlign: TextAlign.left,)),
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: bluetoothControl.recentScanResult.length,
          itemBuilder: (context, i) {
            return deviceListTile(
                context, bluetoothControl.recentScanResult[i].device, false);
          }),);
  }


  InkWell _refreshBtn(BluetoothControl bluetoothControl) {
    return InkWell(
      child: SizedBox(width: 35,
          height: 35,
          child: Icon(Icons.refresh, size: 30, color: Colors.black87,)),
      onTap: () {
        bluetoothControl.startScan();
      },
    );
  }

  Widget _exitBtn(BuildContext context) {
    return InkWell(
      onTap: () {
        _onPressedExitBtn();
      },
      child: SizedBox(width: 35,
          height: 35,
          child: Icon(Icons.arrow_back_ios_new_sharp, size: 23,
            color: Colors.black87,)),);
  }

  _onPressedExitBtn() {
    _bluetoothControl.stopScan();
    Navigator.of(context).pop();
  }

  TextStyle contentTextStyle(double fontSize, Color color) {
    return TextStyle(fontSize: fontSize, color: color);
  }

  Widget getRssiIcon(int rssi) {
    if (rssi >= -40) {
      return Icon(Icons.signal_cellular_alt_sharp);
    }
    else if (rssi >= -50) {
      return Icon(Icons.signal_cellular_alt_2_bar_sharp);
    }
    else if (rssi >= -60) {
      return Icon(Icons.signal_cellular_alt_1_bar_sharp);
    }
    else {
      return Icon(Icons.signal_cellular_no_sim_outlined, size: 15,);
    }
  }

  _onClickedDeviceListTile(BluetoothDevice device, bool isForConnected) async
  {
    // isForConnected == true 인것은 recentDevice != null 이였기때문에 올려준것뿐 이것이 실제 state == connect를 의미하지 않음
    print("isForConnected :: $isForConnected");
    String deviceName = device.name;
    String deviceID = device.id.toString();
    BluetoothDeviceState bluetoothDeviceState = await device.state.first;
    bool isDeviceDisconnected = bluetoothDeviceState == BluetoothDeviceState.disconnected;
    bool isDeviceConnected = bluetoothDeviceState == BluetoothDeviceState.connected;

    bool bluetoothTurnOn = await _bluetoothControl.isBluetoothTurnOn();
    if(!bluetoothTurnOn)
    {
      bool response = await _bluetoothControl.bluetoothTurnOnDialog(context);
      if(!response)
      {
        return;
      }
      _bluetoothControl.startScan();
      setState(() {});
      return;
    }
    if (isForConnected && !isDeviceConnected) {
      print("리스트 위에있긴하지만 실제로 까보니 connceted가 아닌 경우");
      await simpleConfirmDialog(context, "만료된 디바이스입니다. 다시 연결해주세요", "OK");
      _bluetoothControl.startScan();
      setState(() {});
      return;
    }
    if (isDeviceDisconnected) {
      print("이 기기는 disconnceted이므로 연결시도해보겠음.");
      simpleLoadingDialog(context, "로딩중");
      await tryConnectDevice(device);
    }
    else {
      print("이 기기는 disconnceted 아니므로 연결시도 하지않겠음.");
      _onPressedExitBtn();
    }
  }

  tryConnectDevice(BluetoothDevice device) async
  {
    try {
      print("connect 2초간 시도");
      await device.connect(timeout: Duration(milliseconds: 3500));
      print("connect 2초의 시도완료");
      Navigator.of(context).pop();
      _bluetoothControl.startScan();
      setState(() {});
    }
    catch (e) {
      Navigator.of(context).pop();
      await simpleConfirmDialog(
          context, "블루투스 기기연결에 실패했습니다. 다시시도해보세요.", "OK");
      _bluetoothControl.startScan();
      setState(() {});
      print("기기 연결 중 에러발생 $e");
    }
  }

  Widget deviceListTile(BuildContext context, BluetoothDevice device, bool isForConnected) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
            title: Text(device.name.isNotEmpty ? device.name : "no name",
              style: contentTextStyle(16, Colors.black87),),
            subtitle: Text(device.id.toString(),
              style: contentTextStyle(10, Colors.black38),),
            trailing: isForConnected
                ? Icon(Icons.check, color: Colors.lightGreen, size: 30,)
                : SizedBox(width: 30,height: 30),
            onTap: () async {
              _onClickedDeviceListTile(device, isForConnected);
            })
    );
  }
  Widget loadingAnimationWhenScan(BluetoothControl bluetoothControl) {
    return
      bluetoothControl.isScanning ? LoadingAnimationWidget.prograssiveDots(
        size: 20, color: Colors.deepPurple,) : Container();
  }
  StreamSubscription<dynamic>? _currentDeviceStateSubscription;

  void startMonitoringConnection() {

  }

  void stopMonitoringConnection() {
    _currentDeviceStateSubscription?.cancel();
    _currentDeviceStateSubscription = null;
  }
}

