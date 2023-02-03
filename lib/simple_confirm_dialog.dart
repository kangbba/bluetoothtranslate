import 'package:flutter/material.dart';

Future<bool> simpleConfirmDialog(BuildContext context, String title, String message) async {
  bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(fontSize: 16),),
        content: Text(message, style: TextStyle(fontSize: 12),),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK', style: TextStyle(fontSize: 10),),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
  if(confirmed == null)
  {
    return false;
  }
  else{
    return confirmed;
  }
}


