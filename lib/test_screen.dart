import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_control.dart';


class TestScreen extends StatefulWidget {
  final BluetoothControl bluetoothControl;

  const TestScreen({Key? key, required this.bluetoothControl}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
      color: Colors.cyan,
      ),
    );
  }
}
