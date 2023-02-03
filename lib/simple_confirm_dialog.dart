import 'package:flutter/material.dart';

Future<bool?> simpleConfirmDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          ElevatedButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}
