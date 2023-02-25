import 'package:flutter/material.dart';
Future<bool?> simpleAskDialog2(BuildContext context, String message, String positiveStr, String negativeStr) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(fontSize: 14, color: Colors.black),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message, style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
        actions: <Widget>[
          InkWell(
            onTap: (){
              Navigator.of(context).pop(false);
            },
            child: SizedBox(width : 100, height: 30, child: Align(alignment: Alignment.center, child: Text(negativeStr, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
          InkWell(
              onTap: (){
                Navigator.of(context).pop(true);
              },
              child: SizedBox(width : 100, height: 30, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ))))
          ),
        ],
        actionsPadding: EdgeInsets.only(bottom: 12),
      );

    },
  );
}


