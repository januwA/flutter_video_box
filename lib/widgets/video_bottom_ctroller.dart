import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../video.controller.dart';
import 'buffer_slider.dart';

class VideoBottomView extends StatefulObserverWidget {
  final VideoController controller;

  const VideoBottomView({Key key, @required this.controller}) : super(key: key);

  @override
  _VideoBottomViewState createState() => _VideoBottomViewState();
}

class _VideoBottomViewState extends State<VideoBottomView> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ListTile(
      title: Row(
        children: <Widget>[
          Text(
            widget.controller.initialized
                ? "${widget.controller.positionText}/${widget.controller.durationText}"
                : '00:00/00:00',
            style: TextStyle(color: widget.controller.color),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              widget.controller.volume <= 0
                  ? Icons.volume_off
                  : widget.controller.volume <= 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
            ),
            onPressed: widget.controller.setOnSoundOrOff,
          ),
          IconButton(
            icon: Icon(widget.controller.isFullScreen
                ? Icons.fullscreen_exit
                : Icons.fullscreen),
            onPressed: () => widget.controller.onFullScreenSwitch(context),
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
        child: BufferSlider(
          inactiveColor: widget.controller.inactiveColor,
          bufferColor: widget.controller.bufferColor,
          activeColor: widget.controller.color,
          value: widget.controller.sliderValue,
          bufferValue: widget.controller.sliderBufferValue,
          onChanged: (double v) => widget.controller.seekTo(Duration(
              seconds: (v * widget.controller.duration.inSeconds).toInt())),
        ),
      ),
    );
  }
}
