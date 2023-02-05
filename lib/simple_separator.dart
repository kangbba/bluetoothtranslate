
import 'package:flutter/material.dart';

class SimpleSeparator extends StatelessWidget {
  const SimpleSeparator({
    super.key,
    required this.height,
    required this.top,
    required this.bottom,
  });

  final double height;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(top: top, bottom: bottom),
      color: Colors.grey[300],
    );
  }
}
