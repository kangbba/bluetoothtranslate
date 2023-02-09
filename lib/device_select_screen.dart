import 'dart:ffi';

import 'package:bluetoothtranslate/simple_ask_dialog.dart';
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
                                    Text("Other Devices (${bluetoothControl.deviceForms.length})", textAlign: TextAlign.left),
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
        child: Icon(Icons.cancel, size: 30,),);
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
  Widget deviceListTile(BuildContext context, BluetoothControl bluetoothControl, DeviceForm deviceForm) {
    final icon;
    switch (deviceForm.deviceStatus) {
      case DeviceStatus.connectedDevice:
        icon = (deviceForm.device == bluetoothControl.selectedDeviceForm?.device) ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.devices);
        break;
      case DeviceStatus.scannedDevice:
        icon = getRssiIcon(deviceForm.rssi!);
        break;
      default:
        icon = Container();
        break;
    }
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
            title: Text(deviceForm.device.name.isNotEmpty ? deviceForm.device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
            subtitle: Text(deviceForm.device.id.toString(), style: contentTextStyle(10, Colors.black38),),
            trailing: icon,
            onTap: () async {
              await onClickedConnectDevice(context, bluetoothControl, deviceForm);
            })
    );
  }
  onClickedConnectDevice(BuildContext context, BluetoothControl bluetoothControl, DeviceForm deviceForm) async
  {
    simpleLoadingDialog(context, "");
    bool success = await bluetoothControl.connectDevice(deviceForm, 4);
    setState(() { });
    Navigator.of(context).pop();
    if(success) {
      setState(() { });
      Navigator.of(context).pop();
    }
    else {
      setState(() { });
    }
  }

  Widget infoBtn(BuildContext context, BluetoothDevice device)
  {
    return IconButton(
      icon: Icon(Icons.info),
      onPressed: () async {
        await _showDeviceInfo(context, device);
      },
    );
  }

  Future<void> _showDeviceInfo(BuildContext context, BluetoothDevice device) async {

    List<BluetoothService> services = await device.discoverServices();
    var servicesTable = Table(
      defaultColumnWidth: FlexColumnWidth(1.0),
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("No.", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("UUID", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Characteristics", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
    for (var i = 0; i < services.length; i++) {
      BluetoothService service = services[i];
      var characteristics = service.characteristics;

      var serviceRow = TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text("${i + 1}", style: TextStyle(fontSize: 8),),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text("${service.uuid}", style: TextStyle(fontSize: 8),),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: List.generate(
                characteristics.length,
                    (j) => Text("${j + 1}. ${characteristics[j].uuid} (${characteristics[j].properties})", style: TextStyle(fontSize: 8),),
              ),
            ),
          ),
        ],
      );
      servicesTable.children.add(serviceRow);
    }
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Device ${device.name} Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            servicesTable,
          ],
        );
      },
    );
  }
  Widget deviceListView_selected(BluetoothControl bluetoothControl) {
    if ((bluetoothControl.selectedDeviceForm == null)) {
      return Container();
    }
    else {
      return Column(
        children: [
          SizedBox(width: double.infinity, height : 22, child: Text("Connected", textAlign: TextAlign.left,)),
          deviceListTile(context, bluetoothControl, bluetoothControl.selectedDeviceForm!),
        ]
      );
    }
  }
  Widget deviceListView_otherDevices(BluetoothControl bluetoothControl) {
   // SizedBox(width: double.infinity, child: Text("Connected", textAlign: TextAlign.left,)),
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: bluetoothControl.deviceForms.length,
          itemBuilder: (context, index) {
            return deviceListTile(context, bluetoothControl, bluetoothControl.deviceForms[index]);
          }),);
  }

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
