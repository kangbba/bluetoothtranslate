import 'package:flutter/material.dart';
simpleLoadingDialog(BuildContext context, String title) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}