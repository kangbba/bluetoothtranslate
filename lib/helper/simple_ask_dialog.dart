import 'package:flutter/material.dart';

Future<bool?> simpleAskDialog(BuildContext context, String title, String message) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title,  style: TextStyle(fontSize: 16),),
        content: Text(message, style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Yes', style: TextStyle(fontSize: 10)),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          ElevatedButton(
            child: Text('No', style: TextStyle(fontSize: 10)),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}


