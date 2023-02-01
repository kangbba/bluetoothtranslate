import 'package:flutter/material.dart';
Future<void> simpleLoadingDialog(BuildContext context, String title) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(title),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}