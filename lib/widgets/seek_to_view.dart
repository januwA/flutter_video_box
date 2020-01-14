import 'package:flutter/material.dart';

import '../video.controller.dart';

class SeekToView extends StatelessWidget {
  final VideoController controller;

  const SeekToView({Key key, @required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // 左侧模块，负责快退，调整系统亮度
        Expanded(
          child: GestureDetector(
            onTap: controller.toggleShowVideoCtrl,
            onDoubleTap: controller.rewind,
            child: Container(color: Colors.transparent),
          ),
        ),
        const SizedBox(width: 24),

        // 右侧模块，负责快进，调整媒体音量
        Expanded(
          child: GestureDetector(
            onTap: controller.toggleShowVideoCtrl,
            onDoubleTap: controller.fastForward,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
