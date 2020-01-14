import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../video.controller.dart';
import 'buffer_slider.dart';

class VideoBottomCtroller extends StatelessWidget {
  final VideoController controller;

  const VideoBottomCtroller({Key key, @required this.controller})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ListTile(
      title: Row(
        children: <Widget>[
          Observer(
            builder: (_) => Text(
              controller.initialized
                  ? "${controller.positionText}/${controller.durationText}"
                  : '00:00/00:00',
              style: TextStyle(color: controller.color),
            ),
          ),
          Spacer(),
          Observer(
            builder: (_) => IconButton(
              icon: Icon(
                controller.volume <= 0
                    ? Icons.volume_off
                    : controller.volume <= 0.5
                        ? Icons.volume_down
                        : Icons.volume_up,
              ),
              onPressed: controller.setOnSoundOrOff,
            ),
          ),
          Observer(
            builder: (_) => IconButton(
              icon: Icon(controller.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen),
              onPressed: () => controller.onFullScreenSwitch(context),
            ),
          ),
        ],
      ),
      subtitle: Theme(
        data: theme.copyWith(
          sliderTheme: theme.sliderTheme.copyWith(
            trackHeight: 2, // line的高度
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: RoundSliderThumbShape(
              // 拇指的形状和大小
              enabledThumbRadius: 6.0,
            ),
          ),
        ),
        child: Observer(
          builder: (_) => BufferSlider(
            inactiveColor: controller.inactiveColor,
            bufferColor: controller.bufferColor,
            activeColor: controller.color,
            value: controller.sliderValue,
            bufferValue: controller.sliderBufferValue,
            onChanged: (double v) => controller.seekTo(
                Duration(seconds: (v * controller.duration.inSeconds).toInt())),
          ),
        ),
      ),
    );
  }
}
