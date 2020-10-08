import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:video_player/video_player.dart';

import 'video.controller.dart';
import 'widgets/circular_progressIndicator_big.dart';
import 'widgets/seek_to_view.dart';
import 'widgets/video_bottom_ctroller.dart';

export 'video.controller.dart';
export 'package:video_player/video_player.dart';

class VideoBox extends StatefulWidget {
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
  VideoBox({
    Key key,
    @required this.controller,
    this.afterChildren = const <Widget>[],
    this.beforeChildren = const <Widget>[],
    this.children = const <Widget>[],
  }) : super(key: key);

  static const double centerIconSize = 40.0;

  final VideoController controller;

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
      ..afterChildren ??= widget.afterChildren;
  }

  @override
  Widget build(BuildContext context) {
    var _seekToView =
        Positioned.fill(child: SeekToView(controller: controller));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints size) {
        return Observer(
          builder: (BuildContext context) => Theme(
            data: ThemeData(iconTheme: IconThemeData(color: controller.color)),
            child: GestureDetector(
              onTap: controller.toggleShowVideoCtrl,
              child: Stack(
                children: <Widget>[
                  // background widget
                  Container(
                    width: size.maxWidth,
                    height: size.maxHeight,
                    color: controller.background,
                  ),

                  if (!controller.initialized) ...[
                    // 加载中同时显示loading和海报
                    if (controller.cover != null)
                      Center(child: controller.cover),
                    controller.customLoadingWidget ??
                        Center(
                          child: CircularProgressIndicatorBig(
                            color: controller.circularProgressIndicatorColor,
                          ),
                        ),
                  ] else ...[
                    // 加载完成在第一帧显示海报
                    Container(
                      child: controller.isShowCover
                          ? Center(child: controller.cover)
                          : Center(
                              child: AspectRatio(
                                aspectRatio: controller.aspectRatio,
                                child: VideoPlayer(controller.videoCtrl),
                              ),
                            ),
                    ),

                    if (controller.beforeChildren != null)
                      ...controller.beforeChildren,

                    if (controller.controllerWidgets) ...[
                      // 快进快退
                      _seekToView,

                      // controller layer
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: controller.controllerLayerDuration,
                          child: controller.controllerLayer
                              ? Container(
                                  width: size.maxWidth,
                                  height: size.maxHeight,
                                  color: controller.barrierColor,
                                  child: Stack(
                                    children: <Widget>[
                                      _seekToView,
                                      controller.isBfLoading
                                          ? SizedBox()
                                          : Center(
                                              child: IconButton(
                                                iconSize:
                                                    VideoBox.centerIconSize,
                                                icon: AnimatedIcon(
                                                  icon:
                                                      AnimatedIcons.play_pause,
                                                  progress: controller
                                                      .animetedIconTween,
                                                ),
                                                onPressed:
                                                    controller.togglePlay,
                                              ),
                                            ),
                                      controller.bottomViewBuilder != null
                                          ? controller.bottomViewBuilder(
                                              context, controller)
                                          : Positioned(
                                              left:
                                                  controller.bottomPadding.left,
                                              bottom: controller
                                                  .bottomPadding.bottom,
                                              right: controller
                                                  .bottomPadding.right,
                                              child: VideoBottomView(
                                                  controller: controller),
                                            ),
                                      if (controller.children != null)
                                        ...controller.children,
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ),
                      ),

                      // buffer loading
                      controller.isBfLoading
                          ? controller.customBufferedWidget ??
                              Center(
                                child: CircularProgressIndicatorBig(
                                    color: controller
                                        .circularProgressIndicatorColor),
                              )
                          : SizedBox(),
                    ],

                    // 自定义控件
                    if (controller.afterChildren != null)
                      ...controller.afterChildren,
                  ]
                ],
              ),
            ),
          ),
        );
      },
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
