import 'package:flutter/material.dart';
Future<bool?> simpleConfirmDialog(BuildContext context, String message, String positiveStr) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(fontSize: 14, color: Colors.black87),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message, style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
        actions: <Widget>[
          InkWell(
              onTap: (){
                Navigator.of(context).pop(false);
              },
              child: SizedBox(width : 250, height: 30, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
        ],
        actionsPadding: EdgeInsets.only(bottom: 12),
      );

    },
  );
}





