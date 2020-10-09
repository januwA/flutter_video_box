import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:video_player/video_player.dart';

import '_util.dart';
import 'mixin/custom_view_mixin.dart';
import 'video.controller.dart';
import 'widgets/buffer_slider.dart';
import 'widgets/circular_progressIndicator_big.dart';
import 'widgets/seek_to_view.dart';

export 'video.controller.dart';
export 'package:video_player/video_player.dart';

Widget kBottomViewBuilder(BuildContext context, VideoController c) {
  return KBottomViewBuilder(controller: c);
}

class VideoBox extends StatefulObserverWidget {
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
    Key key,
    @required this.controller,
    this.children = const <Widget>[],
    this.beforeChildren = const <Widget>[],
    this.afterChildren = const <Widget>[],
    this.background,
    this.cover,
    this.bottomPadding = const EdgeInsets.only(bottom: 10),
    this.theme,
    this.customLoadingWidget,
    this.customBufferedWidget,
    this.barrierColor,
    this.bottomViewBuilder = kBottomViewBuilder,
    this.customFullScreen = const KCustomFullScreen(),
  })  : assert(controller != null),
        super(key: key);

  static const double centerIconSize = 40.0;

  final VideoController controller;

  final Widget background;

  /// video / beforeChildren / controllerWidgets-> children / afterChildren
  final List<Widget> afterChildren;

  /// video / beforeChildren / controllerWidgets-> children / afterChildren
  final List<Widget> beforeChildren;

  /// add your widget
  ///
  /// ```dart
  /// AspectRatio(
  ///   aspectRatio: 16 / 9,
  ///   child: VideoBox(
  ///     controller: controller,
  ///     children: <Widget>[
  ///       Align(
  ///         alignment: Alignment(-0.5, 0),
  ///         child: IconButton(
  ///           iconSize: 40,
  ///           disabledColor: Colors.white60,
  ///           icon: Icon(Icons.skip_previous),
  ///           onPressed: canPrev() ? prevVideo : null,
  ///         ),
  ///       ),
  ///       Align(
  ///         alignment: Alignment(0.5, 0),
  ///         child: IconButton(
  ///           iconSize: 40,
  ///           disabledColor: Colors.white60,
  ///           icon: Icon(Icons.skip_next),
  ///           onPressed: canNext() ? nextVideo : null,
  ///         ),
  ///       ),
  ///     ],
  ///   ),
  /// ),
  /// ```
  final List<Widget> children;

  final Widget cover;

  final EdgeInsets bottomPadding;

  ///
  /// Set the color of the control
  ///
  ///```dart
  /// var _theme = Theme.of(context);
  ///
  /// VideoBox(
  ///  controller: vc,
  ///  theme: ThemeData(
  ///    iconTheme: IconThemeData(color: Colors.pinkAccent),
  ///    textTheme: _theme.textTheme.copyWith(
  ///     bodyText1: _theme.textTheme.bodyText1.copyWith(color: Colors.white),
  ///    ),
  ///     sliderTheme: _theme.sliderTheme.copyWith(
  ///       trackHeight: 2,
  ///       overlayShape: SliderComponentShape.noOverlay,
  ///       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
  ///       activeTrackColor: Colors.white,
  ///       inactiveTrackColor: Colors.white24,
  ///       thumbColor: Colors.white,
  ///     ),
  ///     accentColor: Colors.white,
  ///   ),
  /// )
  ///```
  final ThemeData theme;

  /// This widget will be displayed when the video is first loaded.
  final Widget customLoadingWidget;

  /// This widget will be displayed when the video enters the buffer.
  final Widget customBufferedWidget;

  /// controller layer color
  final Color barrierColor;

  /// see also [kBottomViewBuilder]
  final BottomViewBuilder bottomViewBuilder;

  /// see also [KCustomFullScreen]
  final CustomFullScreen customFullScreen;

  @override
  _VideoBoxState createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> with TickerProviderStateMixin {
  VideoController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller
      ..initAnimetedIconController(this)
      ..children ??= widget.children
      ..beforeChildren ??= widget.beforeChildren
      ..afterChildren ??= widget.afterChildren
      ..background ??= widget.background
      ..cover ??= widget.cover
      ..bottomPadding ??= widget.bottomPadding
      ..theme ??= widget.theme
      ..customLoadingWidget ??= widget.customLoadingWidget
      ..customBufferedWidget ??= widget.customBufferedWidget
      ..barrierColor ??= widget.barrierColor
      ..bottomViewBuilder ??= widget.bottomViewBuilder
      ..customFullScreen ??= widget.customFullScreen;
  }

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    controller.theme ??= _theme.copyWith(
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: _theme.textTheme.copyWith(
        bodyText1: _theme.textTheme.bodyText1.copyWith(color: Colors.white),
      ),
      sliderTheme: _theme.sliderTheme.copyWith(
        trackHeight: 2,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
      ),
      accentColor: Colors.white,
    );

    var _seekToView =
        Positioned.fill(child: SeekToView(controller: controller));
    return Theme(
      data: controller.theme,
      child: GestureDetector(
        onTap: debounce(controller.toggleShowVideoCtrl),
        child: Stack(
          children: <Widget>[
            // background widget
            controller.background ?? Container(color: Colors.black),
            if (!controller.initialized) ...[
              // 加载中同时显示loading和海报
              if (controller.cover != null) Center(child: controller.cover),
              controller.customLoadingWidget ??
                  Center(child: CircularProgressIndicatorBig()),
            ] else ...[
              // 加载完成在第一帧显示海报
              controller.isShowCover
                  ? Center(child: controller.cover)
                  : Center(
                      child: AspectRatio(
                        aspectRatio: controller.aspectRatio,
                        child: VideoPlayer(controller.videoCtrl),
                      ),
                    ),

              if (controller.beforeChildren != null)
                ...controller.beforeChildren,

              if (controller.controllerWidgets) ...[
                // 快进快退
                _seekToView,

                // controller layer
                AnimatedSwitcher(
                  duration: controller.controllerLayerDuration,
                  child: controller.controllerLayer
                      ? Container(
                          color: controller.barrierColor ??
                              Colors.black.withOpacity(0.6),
                          child: Stack(
                            children: <Widget>[
                              _seekToView,
                              controller.isBfLoading
                                  ? SizedBox()
                                  : Center(
                                      child: IconButton(
                                        iconSize: VideoBox.centerIconSize,
                                        icon: AnimatedIcon(
                                          icon: AnimatedIcons.play_pause,
                                          progress:
                                              controller.animetedIconTween,
                                        ),
                                        onPressed: controller.togglePlay,
                                      ),
                                    ),
                              if (controller.bottomViewBuilder != null)
                                controller.bottomViewBuilder(
                                    context, controller),
                              if (controller.children != null)
                                ...controller.children,
                            ],
                          ),
                        )
                      : SizedBox(),
                ),

                // buffer loading
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: controller.isBfLoading
                      ? controller.customBufferedWidget ??
                          Center(child: CircularProgressIndicatorBig())
                      : SizedBox(),
                ),
              ],

              // 自定义控件
              if (controller.afterChildren != null) ...controller.afterChildren,
            ]
          ],
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
  Future<Object> open(BuildContext context, VideoController controller);

  /// 用户点击视图上的icon按钮时，将调用此方法
  ///
  /// 但，如果用户使用的是系统导航栏的返回按钮，此方法将不会被调用
  FutureOr<void> close(BuildContext context, VideoController controller);
}

class KCustomFullScreen extends CustomFullScreen {
  const KCustomFullScreen();

  /// 设置为横屏模式
  ///
  /// Set to landscape mode
  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  ///
  /// Set to normal mode
  void _setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void close(BuildContext context, VideoController controller) {
    Navigator.of(context).pop();
  }

  Route<T> _route<T>(VideoController controller) {
    return MaterialPageRoute<T>(
      builder: (_) => KVideoBoxFullScreenPage(controller: controller),
    );
  }

  @override
  Future<Object> open(BuildContext context, VideoController controller) async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _setLandscape();
    await Navigator.of(context).push(_route(controller));
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _setPortrait();
    return null;
  }
}

class KVideoBoxFullScreenPage extends StatelessWidget {
  final controller;

  const KVideoBoxFullScreenPage({Key key, @required this.controller})
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

class KBottomViewBuilder extends StatefulObserverWidget {
  final VideoController controller;

  const KBottomViewBuilder({Key key, @required this.controller})
      : super(key: key);

  @override
  _VideoBottomViewState createState() => _VideoBottomViewState();
}

class _VideoBottomViewState extends State<KBottomViewBuilder> {
  String get _timeText => widget.controller.initialized
      ? "${widget.controller.positionText}/${widget.controller.durationText}"
      : '00:00/00:00';

  IconData get _volumeIcon => widget.controller.volume <= 0
      ? Icons.volume_off
      : widget.controller.volume <= 0.5
          ? Icons.volume_down
          : Icons.volume_up;

  IconData get _screenIcon =>
      widget.controller.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen;

  void _onTap() {}
  void changed(double v) {
    widget.controller.seekTo(
        Duration(seconds: (v * widget.controller.duration.inSeconds).toInt()));
  }

  _onFullScreenSwitch() {
    widget.controller.onFullScreenSwitch(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Positioned(
      left: widget.controller.bottomPadding.left,
      bottom: widget.controller.bottomPadding.bottom,
      right: widget.controller.bottomPadding.right,
      child: GestureDetector(
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(_timeText, style: theme.textTheme.bodyText1),
                  Spacer(),
                  IconButton(
                    icon: Icon(_volumeIcon),
                    onPressed: widget.controller.volumeToggle,
                  ),
                  IconButton(
                    icon: Icon(_screenIcon),
                    onPressed: _onFullScreenSwitch,
                  ),
                ],
              ),
              BufferSlider(
                value: widget.controller.sliderValue,
                bufferValue: widget.controller.sliderBufferValue,
                onChanged: changed,
              )
            ],
          ),
        ),
      ),
    );
  }
}
