import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../video.controller.dart';
import 'circular_progressIndicator_big.dart';

class BufferLoading extends StatelessObserverWidget {
  final VideoController controller;

  const BufferLoading({Key key, @required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: controller.isBfLoading
          ? controller.customBufferedWidget ??
              Center(
                child: CircularProgressIndicatorBig(
                  color: controller.circularProgressIndicatorColor,
                ),
              )
          : SizedBox(),
    );
  }
}
