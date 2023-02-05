import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
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
      body: Container(
        child: MultiProvider(
          providers: [
            ListenableProvider<BluetoothControl>(
              create: (_) => widget.bluetoothControl,
            ),
          ],
          child: Consumer<BluetoothControl>(
              builder: (context, bluetoothControl, child) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text("Bluetooth Devices"),
                  content: Column(
                    children: [
                      Text("발견된 디바이스수 : ${widget.bluetoothControl.scanResults.length}"),
                      Container(
                        height: 250,
                        child: ListView.builder(
                          itemCount: widget.bluetoothControl.scanResults.length,
                          itemBuilder: (context, index) {
                            return StreamBuilder<BluetoothDeviceState>(
                              stream: widget.bluetoothControl.scanResults[index].device.state,
                              builder: (context, snapshot) {
                                return deviceListTile(context, index, snapshot);
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

  Widget deviceListTile(BuildContext context, int index, AsyncSnapshot<BluetoothDeviceState> snapshot) {
    return ListTile(
      title: Text(widget.bluetoothControl.scanResults[index].device.name),
      subtitle: Text(widget.bluetoothControl.scanResults[index].device.id.toString()),
      trailing: Text(
        (snapshot.data == BluetoothDeviceState.connected ? "Connected" : "Disconnected"),
        style: TextStyle(fontSize: 8),
      ),
      onTap: () async {
        bool isConnected =snapshot.data == BluetoothDeviceState.connected;
        bool? confirmed = await simpleAskDialog(context,widget.bluetoothControl.scanResults[index].device.name + "에 연결하시겠습니까?", "");
        if (!isConnected && confirmed!) {
          simpleLoadingDialog(context, "");
          ScanResult scanResult = widget.bluetoothControl.scanResults[index];
          BluetoothDevice device = scanResult.device;
          await device.connect().then((value) {
            widget.bluetoothControl.recentBluetoothDevice = device;
          });
        }
        else{
        }
        setState(() {});
        Navigator.of(context).pop();
      },
    );
  }
}
