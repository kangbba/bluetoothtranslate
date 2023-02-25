import 'package:flutter/material.dart';

class SimpleGaugeProgress extends StatefulWidget {
  final Future<void> downloadFuture;

  SimpleGaugeProgress({required this.downloadFuture});

  @override
  _SimpleGaugeProgressState createState() => _SimpleGaugeProgressState();
}

class _SimpleGaugeProgressState extends State<SimpleGaugeProgress> {
  double _downloadProgress = 0;


  @override
  void initState() {
    super.initState();
    widget.downloadFuture.then((value) {
      setState(() {
        _downloadProgress = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: _downloadProgress),
        Text("Download progress: ${(_downloadProgress * 100).round()}%"),
      ],
    );
  }
}