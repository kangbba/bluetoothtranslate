import 'package:flutter/material.dart';
//
// Future<bool> simpleConfirmDialog(BuildContext context, String title, String message) async {
//   bool? confirmed = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(title, style: TextStyle(fontSize: 16),),
//         content: Text(message, style: TextStyle(fontSize: 12),),
//         actions: <Widget>[
//           ElevatedButton(
//             child: Text('OK', style: TextStyle(fontSize: 10),),
//             onPressed: () {
//               Navigator.of(context).pop(true);
//             },
//           ),
//         ],
//       );
//     },
//   );
//   if(confirmed == null)
//   {
//     return false;
//   }
//   else{
//     return confirmed;
//   }
// }

Future<bool?> simpleConfirmDialog(BuildContext context, String message, String positiveStr) async {
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
              child: SizedBox(width : 100, height: 30, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
        ],
        actionsPadding: EdgeInsets.only(bottom: 12),
      );

    },
  );
}





