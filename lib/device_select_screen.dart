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
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _bluetoothControl.stopScan();
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
                  Positioned(top: 8, right: 8, child: _cancelBtn(context)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height : 34,
                          child: Text("Please select your device" ,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                              textAlign: TextAlign.center),
                        ),
                        SimpleSeparator(color: Colors.deepPurpleAccent, height: .2, top: 0, bottom: 8),
                        deviceListView_selected(bluetoothControl),
                        SizedBox(height: 10,),
                        Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Other Devices (${bluetoothControl.recentScanResult.length})", textAlign: TextAlign.left),
                                    SizedBox(width: 20,),
                                    bluetoothControl.isScanning ? loadingAnimationWhenScan(bluetoothControl) : _refreshBtn(bluetoothControl)
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
    return FutureBuilder<BluetoothDevice?>(
      future: bluetoothControl.getConnectedDevice(),
      builder: (BuildContext context, AsyncSnapshot<BluetoothDevice?> snapshot) {
        if(!snapshot.hasData)
        {
          return Container();
        }
        else{
          if (snapshot.connectionState == ConnectionState.done) {
            BluetoothDevice connectedDevice = snapshot.data!;
            // 여기서 연결된 장치 목록을 사용하여 UI를 업데이트합니다.
            return Column(
                children: [
                  SizedBox(width: double.infinity, height : 22, child: Text("Connected", textAlign: TextAlign.left,)),
                  deviceListTile(context, connectedDevice, true),
                ]
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            // 연결된 장치 목록을 가져오는 중임을 나타내는 UI를 반환합니다.
            return CircularProgressIndicator();
          } else {
            // 연결된 장치 목록을 가져오는 도중 에러가 발생하면, 해당 에러를 나타내는 UI를 반환합니다.
            return Text('Error: ${snapshot.error}');
          }

        }

      },
    );
  }
  Widget deviceListView_otherDevices(BluetoothControl bluetoothControl) {
    // SizedBox(width: double.infinity, child: Text("Connected", textAlign: TextAlign.left,)),
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: bluetoothControl.recentScanResult.length,
          itemBuilder: (context, i) {
            return deviceListTile(context, bluetoothControl.recentScanResult[i].device, false);
          }),);
  }


  InkWell _refreshBtn(BluetoothControl bluetoothControl) {
    return InkWell(
      child: Icon(Icons.refresh),
      onTap : (){
        bluetoothControl.stopScan();
        bluetoothControl.startScan();
      },
    );
  }

  Widget _cancelBtn(BuildContext context) {
    return InkWell(
        onTap: (){
          Navigator.of(context).pop();
          setState(() {
          });
        },
        child: Icon(Icons.navigate_next_rounded, size: 36,),);
  }

  TextStyle contentTextStyle(double fontSize, Color color)
  {
    return TextStyle(fontSize: fontSize, color: color);
  }
  Widget getRssiIcon(int rssi)
  {
    if(rssi >= -40)
    {
      return Icon(Icons.signal_cellular_alt_sharp);
    }
    else if(rssi >= -50)
    {
      return Icon(Icons.signal_cellular_alt_2_bar_sharp);
    }
    else if(rssi >= -60)
    {
      return Icon(Icons.signal_cellular_alt_1_bar_sharp);
    }
    else{
      return Icon(Icons.signal_cellular_no_sim_outlined, size: 15,);
    }
  }
  Widget deviceListTile(BuildContext context, BluetoothDevice device, bool isForConnected) {

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: FutureBuilder<int>(
          future: device.readRssi(),
          builder: (context, snapshot) {
            return ListTile(
                title: Text(device.name.isNotEmpty ? device.name : "no name", style: contentTextStyle(15,Colors.black87),),
                subtitle: Text(device.id.toString(), style: contentTextStyle(10, Colors.black38),),
                trailing: isForConnected ? Icon(Icons.check, color: Colors.lightGreen,) : (snapshot.hasData ? getRssiIcon(snapshot.data!) : getRssiIcon(0)),
                onTap: () async {
                  // await onClickedConnectDevice(context, bluetoothControl, deviceForm);
                });
          }
        )
    );
  }
  // onClickedConnectDevice(BuildContext context, BluetoothControl bluetoothControl, DeviceForm deviceForm) async
  // {
  //   bool bluetoothTurnOn= false;
  //   if ((await _bluetoothControl.flutterBlue.state.first) != BluetoothState.on)
  //   {
  //     bool? bluetoothResponse = await simpleAskDialog2(context, "Bluetooth 기능이 필요합니다.", "허용", "거부");
  //     if(bluetoothResponse != null && bluetoothResponse)
  //     {
  //       bluetoothTurnOn = true;
  //       simpleLoadingDialog(context, ("블루투스를 켜는중"));
  //       await _bluetoothControl.flutterBlue.turnOn();
  //       Navigator.of(context).pop();
  //       _bluetoothControl.startScan();
  //     }
  //     else{
  //       bluetoothTurnOn = false;
  //     }
  //   }
  //   else{
  //     bluetoothTurnOn = true;
  //   }
  //   if(!bluetoothTurnOn)
  //   {
  //     print("bluetooth 허용되지않음");
  //     return;
  //   }
  //   simpleLoadingDialog(context, ("블루투스를 켜는중"));
  //   bool success = await bluetoothControl.connectDevice(deviceForm, 3);
  //   Navigator.of(context).pop();
  //   setState(() { });
  //   if(success) {
  //     setState(() { });
  //     Navigator.of(context).pop();
  //   }
  //   else {
  //     await simpleConfirmDialog(context, "연결에 실패했습니다. 다시 시도해보세요", "OK");
  //     _bluetoothControl.startScan();
  //     setState(() { });
  //   }
  // }
  //
  // Widget infoBtn(BuildContext context, BluetoothDevice device)
  // {
  //   return IconButton(
  //     icon: Icon(Icons.info),
  //     onPressed: () async {
  //       await _showDeviceInfo(context, device);
  //     },
  //   );
  // }
  //
  // Future<void> _showDeviceInfo(BuildContext context, BluetoothDevice device) async {
  //
  //   List<BluetoothService> services = await device.discoverServices();
  //   var servicesTable = Table(
  //     defaultColumnWidth: FlexColumnWidth(1.0),
  //     border: TableBorder.all(),
  //     children: [
  //       TableRow(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.all(8),
  //             child: Text("No.", style: TextStyle(fontWeight: FontWeight.bold)),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(8),
  //             child: Text("UUID", style: TextStyle(fontWeight: FontWeight.bold)),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(8),
  //             child: Text("Characteristics", style: TextStyle(fontWeight: FontWeight.bold)),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  //   for (var i = 0; i < services.length; i++) {
  //     BluetoothService service = services[i];
  //     var characteristics = service.characteristics;
  //
  //     var serviceRow = TableRow(
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.all(8),
  //           child: Text("${i + 1}", style: TextStyle(fontSize: 8),),
  //         ),
  //         Padding(
  //           padding: EdgeInsets.all(8),
  //           child: Text("${service.uuid}", style: TextStyle(fontSize: 8),),
  //         ),
  //         Padding(
  //           padding: EdgeInsets.all(8),
  //           child: Column(
  //             children: List.generate(
  //               characteristics.length,
  //                   (j) => Text("${j + 1}. ${characteristics[j].uuid} (${characteristics[j].properties})", style: TextStyle(fontSize: 8),),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //     servicesTable.children.add(serviceRow);
  //   }
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.all(8),
  //             child: Text("Device ${device.name} Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  //           ),
  //           servicesTable,
  //         ],
  //       );
  //     },
  //   );
  // }
  Widget loadingAnimationWhenScan(BluetoothControl bluetoothControl) {
    return
      SizedBox(
        height : 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            bluetoothControl.isScanning ? LoadingAnimationWidget.prograssiveDots(size: 20, color: Colors.deepPurple, ) : Container(),
          ],
        ),
      );
  }
}
