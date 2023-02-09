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
                        SimpleSeparator(color: Colors.indigoAccent, height: .2, top: 0, bottom: 8),
                        deviceListView_connected(bluetoothControl),
                        SizedBox(height: 10,),
                        Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Other Devices (${bluetoothControl.scanResults.length})", textAlign: TextAlign.left),
                                    SizedBox(width: 20,),
                                    bluetoothControl.isScanning ? loadingAnimationWhenScan(bluetoothControl) : _refreshBtn(bluetoothControl)
                                  ],
                                ),
                                SizedBox(height: 8,),
                                deviceListView_scanned(bluetoothControl),
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
  Widget getRssiIcon(ScanResult r)
  {
    if(r.rssi >= -40)
    {
      return Icon(Icons.signal_cellular_alt_sharp);
    }
    else if(r.rssi >= -50)
    {
      return Icon(Icons.signal_cellular_alt_2_bar_sharp);
    }
    else if(r.rssi >= -60)
    {
      return Icon(Icons.signal_cellular_alt_1_bar_sharp);
    }
    else{
      return Icon(Icons.signal_cellular_no_sim_outlined, size: 15,);
    }
  }

  Widget connectedDeviceListTile(BuildContext context, BluetoothControl bluetoothControl, BluetoothDevice device) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey,
          width: 0.2,
        ),
      ),
      child: ListTile(
        title: Text(device.name.isNotEmpty ? device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
        subtitle: Text(device.id.toString(), style: contentTextStyle(10,Colors.black38),),
        trailing: Icon(Icons.check, color: Colors.green,),
        onTap : () async {
          await onClickedConnectDevice(context, bluetoothControl, device);
        }
      ),
    );
  }
  Widget deviceListTileWithConnected(BuildContext context, BluetoothControl bluetoothControl, BluetoothDevice device) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: device.state,
      builder: (context, snapshot) {
        return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
                title: Text(device.name.isNotEmpty ? device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
                subtitle: Text(device.id.toString(), style: contentTextStyle(10, Colors.black38),),
                trailing: Icon(Icons.devices),
                onTap: () async {
                  await onClickedConnectDevice(context, bluetoothControl, device);
                })
        );
      },
    );
  }
  Widget deviceListTileWithScanned(BuildContext context, BluetoothControl bluetoothControl, ScanResult result) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: result.device.state,
      builder: (context, snapshot) {
        return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          child: ListTile(
            title: Text(result.device.name.isNotEmpty ? result.device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
            subtitle: Text(result.device.id.toString(), style: contentTextStyle(10, Colors.black38),),
            trailing: getRssiIcon(result),
            onTap: () async {
              await onClickedConnectDevice(context, bluetoothControl, result.device);
            })
        );
      },
    );
  }
  onClickedConnectDevice(BuildContext context, BluetoothControl bluetoothControl, BluetoothDevice device) async
  {
    simpleLoadingDialog(context, "");
    bool success = await bluetoothControl.connectDevice(device, 4);
    Navigator.of(context).pop();
    if(success) {
      Navigator.of(context).pop();
    }
    else {

    }
    setState(() {

    });
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
  }Widget deviceListView_connected(BluetoothControl bluetoothControl) {
    if ((bluetoothControl.connectedDevice == null)) {
      return Container();
    }
    else {
      return Column(
        children: [
          SizedBox(width: double.infinity, height : 22, child: Text("Connected", textAlign: TextAlign.left,)),
          connectedDeviceListTile(context, bluetoothControl, bluetoothControl.connectedDevice!),
        ]
      );
    }
  }


  Widget deviceListView_scanned(BluetoothControl bluetoothControl) {
   // SizedBox(width: double.infinity, child: Text("Connected", textAlign: TextAlign.left,)),
    return FutureBuilder<List<BluetoothDevice>>(
        future: bluetoothControl.flutterBlue.connectedDevices,
        builder: (context, snapshot)
        {
          if (snapshot.hasData) {
            return Flexible(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length + bluetoothControl.scanResults.length,
                  itemBuilder: (context, index) {
                    return (index < snapshot.data!.length) ?
                    deviceListTileWithConnected(context, bluetoothControl, snapshot.data![index]) :
                    deviceListTileWithScanned(context, bluetoothControl, bluetoothControl.scanResults[index]);
                  }),);
          }
          else{
            return Container();
          }
        }
    );
  }

  Widget loadingAnimationWhenScan(BluetoothControl bluetoothControl) {
    return
      SizedBox(
        height : 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            bluetoothControl.isScanning ? LoadingAnimationWidget.fourRotatingDots(size: 20, color: Colors.indigoAccent) : Container(),
          ],
        ),
      );
  }
}
