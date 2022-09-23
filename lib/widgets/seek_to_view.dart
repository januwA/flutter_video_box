import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_box/video_box.dart';

import 'animated_arrow_icon.dart';

class SeekToView extends StatelessWidget {
  final VideoController controller;

  const SeekToView({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      children: <Widget>[
        // 左侧模块，负责快退，调整系统亮度
        Expanded(
          child: GestureDetector(
            onDoubleTap: controller.rewind,
            child: Container(
              color: Colors.transparent,
              child: Center(
                // ignore: unnecessary_null_comparison
                child: controller.arrowIconRtLController != null
                    ? Transform.rotate(
                        angle: math.pi / 180 * 180,
                        child: AnimatedArrowIcon(
                          iconSize: VideoBox.centerIconSize,
                          controller: controller.arrowIconRtLController!,
                          color: theme.iconTheme.color!,
                        ),
                      )
                    : SizedBox(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),

        // 右侧模块，负责快进，调整媒体音量
        Expanded(
          child: GestureDetector(
            onDoubleTap: controller.fastForward,
            child: Container(
              color: Colors.transparent,
              child: Center(
                // ignore: unnecessary_null_comparison
                child: controller.arrowIconLtRController != null
                    ? AnimatedArrowIcon(
                        iconSize: VideoBox.centerIconSize,
                        controller: controller.arrowIconLtRController!,
                        color: theme.iconTheme.color!,
                      )
                    : SizedBox(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
