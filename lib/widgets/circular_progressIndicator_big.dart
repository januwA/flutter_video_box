import 'package:flutter/material.dart';

/// 稍微大一点的loading
class CircularProgressIndicatorBig extends StatelessWidget {
  static const double SIZE = 50;
  final double size;
  final Color color;

  const CircularProgressIndicatorBig({
    Key key,
    this.size = SIZE,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child:
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(color)),
    );
  }
}
