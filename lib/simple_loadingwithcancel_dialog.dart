import 'package:flutter/material.dart';

Future<bool> showLoadingWithCancel(BuildContext context) async {
  bool cancelLoading = false;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Cancel'),
                onPressed: () {
                  cancelLoading = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  return cancelLoading;
}