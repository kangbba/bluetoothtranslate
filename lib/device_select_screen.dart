import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_separator.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_control.dart';


class DeviceSelectScreen extends StatefulWidget {
  final BluetoothControl bluetoothControl;

  const DeviceSelectScreen({Key? key, required this.bluetoothControl}) : super(key: key);

  @override
  _DeviceSelectScreenState createState() => _DeviceSelectScreenState();
}

class _DeviceSelectScreenState extends State<DeviceSelectScreen> {
  @override
  Widget build(BuildContext context) {
    widget.bluetoothControl.startScan();
    return Scaffold(
      body: MultiProvider(
        providers: [
          ListenableProvider<BluetoothControl>(
            create: (_) => widget.bluetoothControl,
          ),
        ],
        child: Container(
          color: Colors.cyan,
          height: screenSize.height,
          child: Consumer<BluetoothControl>(
              builder: (context, bluetoothControl, child) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: StreamBuilder<BluetoothDeviceState>(
                    stream: bluetoothControl.recentBluetoothDevice?.state,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Text("기기 선택 (${(bluetoothControl.isScanning ? bluetoothControl.scanResults.length : "")})", textAlign: TextAlign.center),
                          bluetoothControl.recentBluetoothDevice != null ?
                          deviceListTile(context, bluetoothControl.recentBluetoothDevice!, snapshot) :
                              Container()
                        ],
                      );
                    }
                  ),
                  backgroundColor: Colors.white,
                  content: Stack(
                    children: [
                      // Text("발견된 디바이스수 : ${widget.bluetoothControl.scanResults.length}"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        height: 250,
                        child: ListView.builder(
                          itemCount: bluetoothControl.scanResults.length,
                          itemBuilder: (context, index) {
                            return StreamBuilder<BluetoothDeviceState>(
                              stream: bluetoothControl.scanResults[index].device.state,
                              builder: (context, snapshot) {
                                BluetoothDevice device = bluetoothControl.scanResults[index].device;
                                return deviceListTile(context, device, snapshot);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          widget.bluetoothControl.stopScan();
                          Navigator.of(context).pop();
                          setState(() {

                          });
                        }
                    )
                  ],
                );
              }
          ),
        ),


      ),
    );
  }

  TextStyle contentTextStyle(double fontSize, Color color)
  {
    return TextStyle(fontSize: fontSize, color: color);
  }

  Widget deviceListTile(BuildContext context, BluetoothDevice device, AsyncSnapshot<BluetoothDeviceState> snapshot) {
    return ListTile(
      title: Row(
        children: [
          Text(device.name.isNotEmpty ? device.name : "UNKNOWN",
            style: contentTextStyle(15,Colors.black87),
          ),
          Text(
            (snapshot.data == BluetoothDeviceState.connected ? "   (Connected)" : "   (Disconnected)"),
            style: contentTextStyle(6,Colors.black87),
          )
        ],
      ),
      subtitle: Text(device.id.toString(), style: contentTextStyle(10,Colors.black38),),
      // trailing: infoBtn(context, widget.bluetoothControl.scanResults[index].device),
      onTap: () async {
        bool isConnected = snapshot.data == BluetoothDeviceState.connected;
        bool? confirmed = await simpleAskDialog(context, device.name + "에 연결하시겠습니까?", "");
        if (!isConnected && confirmed!) {
          simpleLoadingDialog(context, "");
          await widget.bluetoothControl.connectDevice(device);
          Navigator.of(context).pop();
        }
        else{
        }
        setState(() {

        });
      },
    );
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
}
