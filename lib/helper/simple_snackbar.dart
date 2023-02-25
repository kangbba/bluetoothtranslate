import 'package:flutter/material.dart';

void showSimpleSnackBar(BuildContext context, String message, int durationSec) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: durationSec),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
