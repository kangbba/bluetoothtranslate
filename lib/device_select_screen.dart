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
          child: AlertDialog(
            contentPadding: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Bluetooth Devices"),
            content: Container(
              height: 250,
              child: Consumer<BluetoothControl>(
                  builder: (context, bluetoothControl, child) {
                    return ListView.builder(
                      itemCount: widget.bluetoothControl.scanResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(widget.bluetoothControl.scanResults[index].device.name),
                          subtitle: Text(widget.bluetoothControl.scanResults[index].device.id.toString()),
                          trailing: Text(widget.bluetoothControl.scanResults[index].rssi.toString()),
                          onTap: (){
                            simpleLoadingDialog(context, "");
                          },
                        );
                      },
                    );
                  }
              ),
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
          ),

        ),
      ),
    );
  }
}
