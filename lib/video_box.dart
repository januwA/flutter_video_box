import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video.controller.dart';
import 'widgets/buffer_slider.dart';

class VideoBox extends StatefulWidget {
  final VideoController controller;
  final List<Widget>? children;

  /// Example:
  ///
  /// ```dart
  /// import 'package:video_box/video.controller.dart';
  /// import 'package:video_box/video_box.dart';
  /// import 'package:video_player/video_player.dart';
  /// VideoController vc = VideoController(source: VideoPlayerController.network('xxx.mp4'))..initialize();
  ///
  /// @override
  /// void dispose() {
  ///   vc.dispose();
  /// }
  ///
  /// // display videoBox
  /// AspectRatio(
  ///   aspectRatio: 16 / 9,
  ///   child: VideoBox(controller: vc),
  /// )
  /// ```
  ///
  /// see also:
  ///
  /// https://github.com/januwA/flutter_video_box/tree/master/example
  const VideoBox({
    Key? key,
    required this.controller,
    this.children = const <Widget>[],
  }) : super(key: key);

  @override
  _VideoBoxState createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller
      ..initAnimetedIconController(this)
      ..children ??= widget.children;

    widget.controller.vpc.addListener(_update);
    widget.controller.addListener(_update);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    widget.controller.theme ??= _theme.copyWith(
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: _theme.textTheme.copyWith(
        bodyText1: _theme.textTheme.bodyText1!.copyWith(color: Colors.white),
      ),
      sliderTheme: _theme.sliderTheme.copyWith(
        trackHeight: 2,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
      ),
      colorScheme: _theme.colorScheme.copyWith(
        primary: Colors.white,
      ),
    );

    return Theme(
      data: widget.controller.theme!,
      child: GestureDetector(
        onTap: widget.controller.controlsToggle,
        child: Stack(
          children: [
            widget.controller.ui.bgWidth,
            if (widget.controller.vpc.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.vpc.value.aspectRatio,
                  child: VideoPlayer(widget.controller.vpc),
                ),
              ),
            if (widget.controller.isShowLoading)
              widget.controller.laodingWidget,
            AnimatedSwitcher(
              duration: widget.controller.controlsDuration,
              child: !widget.controller.controls
                  ? const SizedBox()
                  : Container(
                      color: widget.controller.controlsBg ??
                          Colors.black.withOpacity(0.6),
                      child: Stack(
                        children: [
                          if (widget.controller.children != null)
                            ...?widget.controller.children,
                          if (widget.controller.isShowLoading)
                            widget.controller.laodingWidget,
                          widget.controller.vpc.value.isBuffering
                              ? const SizedBox()
                              : Center(
                                  child: IconButton(
                                    iconSize: widget.controller.playIconSize,
                                    icon: AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress:
                                          widget.controller.playIconTween!,
                                    ),
                                    onPressed: widget.controller.togglePlay,
                                  ),
                                ),
                          KBottomViewBuilder(vc: widget.controller),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class KVideoBoxFullScreenPage extends StatelessWidget {
  final VideoController controller;

  const KVideoBoxFullScreenPage({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VideoBox(controller: controller),
      ),
    );
  }
}

class KBottomViewBuilder extends StatelessWidget {
  final VideoController vc;

  const KBottomViewBuilder({Key? key, required this.vc}) : super(key: key);

  void _onTap() {}
  void changed(double v) {
    vc.vpc.seekTo(
        Duration(seconds: (v * vc.vpc.value.duration.inSeconds).toInt()));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Positioned(
      left: vc.bottomPadding.left,
      bottom: vc.bottomPadding.bottom,
      right: vc.bottomPadding.right,
      child: GestureDetector(
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(vc.ui.timeText, style: theme.textTheme.bodyText1),
                  const Spacer(),
                  IconButton(
                    icon: Icon(vc.ui.volumeIcon),
                    onPressed: vc.volumeToggle,
                  ),
                  IconButton(
                    icon: Icon(vc.ui.screenIcon),
                    onPressed: () => vc.fullScreenToggle(context),
                  ),
                ],
              ),
              BufferSlider(
                value: vc.sliderValue,
                bufferValue: vc.sliderBufferValue,
                onChanged: changed,
              )
            ],
          ),
        ),
      ),
    );
  }
}

abstract class CustomFullScreen {
  const CustomFullScreen();

  /// 您需要返回一个异步事件(通常是等待页面结束的异步事件)
  /// 请参考[VideoController.customFullScreen]的example
  ///
  /// You need to return an asynchronous event (usually an asynchronous event waiting for the page to end)
  /// please refer to the example of [VideoController.customFullScreen]
  Future<Object>? open(BuildContext context, VideoController controller);

  /// 用户点击视图上的icon按钮时，将调用此方法
  ///
  /// 但，如果用户使用的是系统导航栏的返回按钮，此方法将不会被调用
  FutureOr<void>? close(BuildContext context, VideoController controller);
}
