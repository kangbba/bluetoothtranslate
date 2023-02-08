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
                          height : 30,
                          child: Text("Please select your device" ,
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center),
                        ),
                        SimpleSeparator(color: Colors.indigoAccent, height: .5, top: 0, bottom: 0),
                        SizedBox(
                          height : 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              bluetoothControl.isScanning ? LoadingAnimationWidget.fourRotatingDots(size: 20, color: Colors.indigoAccent) : Container(),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child : deviceListView_connected(bluetoothControl),
                        ),
                        Expanded(
                            flex: 4,
                            child: deviceListView_scanned(bluetoothControl)
                        ),
                        SizedBox(
                          height : 50,
                            child: Column(
                              children: [
                                Center(
                                  child: Text("Found devices (${(bluetoothControl.isScanning ? bluetoothControl.scanResults.length : "")})",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left),
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                    child: Icon(Icons.refresh),
                                  onTap : (){
                                    bluetoothControl.stopScan();
                                    bluetoothControl.startScan();
                                  },
                                ),
                              ],
                            ),
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

  Widget _cancelBtn(BuildContext context) {
    return InkWell(
        onTap: (){
          widget.bluetoothControl.stopScan();
          Navigator.of(context).pop();
          setState(() {
          });
        },
        child: Icon(Icons.cancel));
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
      child: ListTile(
        title: Text(device.name.isNotEmpty ? device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
        subtitle: Text(device.id.toString(), style: contentTextStyle(10,Colors.black38),),
        trailing: Icon(Icons.check),
        onTap : () async {
          await onClickedConnectDevice(context, bluetoothControl, device);
        }
      ),
    );
  }
  Widget deviceListTile(BuildContext context, BluetoothControl bluetoothControl, ScanResult result) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: result.device.state,
      builder: (context, snapshot) {
        return Card(
            child: ListTile(
                title: Text(result.device.name.isNotEmpty ? result.device.name : "Unknown", style: contentTextStyle(15,Colors.black87),),
                subtitle: Text(result.device.id.toString(), style: contentTextStyle(10,Colors.black38),),
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
    simpleLoadingDialog(context, "title");
    bluetoothControl.connectDevice(device).then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: bluetoothControl.connectedDevices.length,
        itemBuilder: (context, index) {
          return connectedDeviceListTile(
              context, bluetoothControl, bluetoothControl.connectedDevices[index]);
        });
  }


  Widget deviceListView_scanned(BluetoothControl bluetoothControl) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: bluetoothControl.scanResults.length,
        itemBuilder: (context, index) {
         return deviceListTile(context, bluetoothControl, bluetoothControl.scanResults[index]);
      });
  }
}
