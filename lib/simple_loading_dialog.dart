import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
simpleLoadingDialog(BuildContext context, String title) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 1000),
    pageBuilder: (context, anim1, anim2) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: LoadingAnimationWidget.prograssiveDots(
            size: 50, color: Colors.white,
          ),
        ),
      );
    },
  );
}