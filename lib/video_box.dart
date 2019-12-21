import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:video_player/video_player.dart';

import 'video.controller.dart';
import 'widgets/buffer_loading.dart';
import 'widgets/circular_progressIndicator_big.dart';
import 'widgets/seek_to_view.dart';
import 'widgets/video_bottom_ctroller.dart';

class VideoBox extends StatefulWidget {
  /// Example:
  ///
  /// ```dart
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
    this.barrierColor,
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

  /// 屏障颜色
  final Color barrierColor;
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
      ..afterChildren ??= widget.afterChildren
      ..barrierColor ??= widget.barrierColor ?? Colors.black.withOpacity(0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
      ),
      child: Container(
        color: Colors.black,
        child: Observer(
          builder: (context) {
            return InkWell(
              onTap: controller.toggleShowVideoCtrl,
              child: Stack(
                children: <Widget>[
                  if (!controller.initialized) ...[
                    // 加载中同时显示loading和海报
                    if (controller.cover != null)
                      Center(child: controller.cover),
                    Center(child: CircularProgressIndicatorBig()),
                  ] else ...[
                    // 加载完成在第一帧显示海报
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: controller.isShowCover
                          ? Center(child: controller.cover)
                          : Center(
                              child: AspectRatio(
                                aspectRatio:
                                    controller.videoCtrl.value.aspectRatio,
                                child: VideoPlayer(controller.videoCtrl),
                              ),
                            ),
                    ),

                    if (controller.beforeChildren != null)
                      for (Widget item in controller.beforeChildren) item,

                    if (controller.controllerWidgets) ...[
                      Positioned.fill(
                          child: SeekToView(controller: controller)),
                      BufferLoading(controller: controller),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: kTabScrollDuration,
                          child: controller.isShowVideoCtrl
                              ? Container(
                                  color: controller.barrierColor,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                          child: SeekToView(
                                              controller: controller)),
                                      Center(
                                        child: IconButton(
                                          iconSize: VideoBox.centerIconSize,
                                          icon: AnimatedIcon(
                                            icon: AnimatedIcons.play_pause,
                                            progress:
                                                controller.animetedIconTween,
                                          ),
                                          onPressed: () {
                                            controller.togglePlay();
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        bottom: 0,
                                        right: 0,
                                        child: VideoBottomCtroller(
                                            controller: controller),
                                      ),
                                      if (controller.children != null)
                                        for (Widget item in controller.children) item,
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
            );
          },
        ),
      ),
    );
  }
}
