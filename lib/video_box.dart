import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:video_player/video_player.dart';

import 'video.controller.dart';
import 'widgets/buffer_loading.dart';
import 'widgets/circular_progressIndicator_big.dart';
import 'widgets/seek_to_view.dart';
import 'widgets/video_bottom_ctroller.dart';

abstract class CustomFullScreen {
  /// 您需要返回一个异步事件(通常是等待页面结束的异步事件)
  /// 请参考[VideoController.customFullScreen]的example
  ///
  /// You need to return an asynchronous event (usually an asynchronous event waiting for the page to end)
  /// please refer to the example of [VideoController.customFullScreen]
  Future<Object> open(BuildContext context, VideoController controller);
  void close(BuildContext context, VideoController controller);
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

class _VideoBoxState extends State<VideoBox>
    with SingleTickerProviderStateMixin {
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
    return Theme(
      data: ThemeData(iconTheme: IconThemeData(color: controller.color)),
      child: Container(
        color: controller.background,
        child: GestureDetector(
          onTap: controller.toggleShowVideoCtrl,
          child: Stack(
            children: <Widget>[
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
                  for (Widget item in controller.beforeChildren) item,

                if (controller.controllerWidgets) ...[
                  Positioned.fill(child: SeekToView(controller: controller)),
                  BufferLoading(controller: controller),
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: controller.controllerLayerDuration,
                      child: controller.controllerLayer
                          ? Container(
                              color: controller.barrierColor,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                      child:
                                          SeekToView(controller: controller)),
                                  Center(
                                    child: IconButton(
                                      iconSize: VideoBox.centerIconSize,
                                      icon: AnimatedIcon(
                                        icon: AnimatedIcons.play_pause,
                                        progress: controller.animetedIconTween,
                                      ),
                                      onPressed: controller.togglePlay,
                                    ),
                                  ),
                                  controller.bottomViewBuilder != null
                                      ? controller.bottomViewBuilder(
                                          context, controller)
                                      : Positioned(
                                          left: controller.bottomPadding.left,
                                          bottom:
                                              controller.bottomPadding.bottom,
                                          right: controller.bottomPadding.right,
                                          child: VideoBottomView(
                                              controller: controller),
                                        ),
                                  if (controller.children != null)
                                    for (Widget item in controller.children)
                                      item,
                                ],
                              ),
                            )
                          : SizedBox(),
                    ),
                  ),
                ],

                // 自定义控件
                if (controller.afterChildren != null)
                  for (Widget item in controller.afterChildren) item,
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// 全屏页面
class VideoBoxFullScreenPage extends StatelessWidget {
  final controller;

  const VideoBoxFullScreenPage({Key key, @required this.controller})
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
