import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_player/video_player.dart';

import 'widgets/buffer_slider.dart';

class VideoBox extends StatefulWidget {
  /// Example:
  ///
  /// ```dart
  /// VideoController vc = VideoController(source: VideoPlayerController.network('xxx.mp4'));
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

  final VideoController controller;

  /// video / beforeChildren / controllerWidgets-> children / afterChildren
  final List<Widget> afterChildren;

  /// video / beforeChildren / controllerWidgets-> children / afterChildren
  final List<Widget> beforeChildren;

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
      ..children = widget.children
      ..beforeChildren = widget.beforeChildren
      ..afterChildren = widget.afterChildren;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<VideoController>.value(value: controller),
      ],
      child: Observer(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              controller.showVideoCtrl(!controller.isShowVideoCtrl);
            },
            child: Stack(
              children: <Widget>[
                if (controller.isVideoLoading) ...[
                  // 加载中同时显示loading和海报
                  if (controller.cover != null)
                    Center(child: controller.cover),
                  Center(
                    child: _CircularProgressIndicatorBig(
                      color: Colors.black,
                    ),
                  ),
                ] else ...[
                  // 加载完成在第一帧显示海报
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: controller.isShowCover
                        ? Center(child: controller.cover)
                        : VideoPlayer(controller.videoCtrl),
                  ),

                  if (controller.beforeChildren != null)
                    for (Widget item in controller.beforeChildren) item,

                  if (controller.controllerWidgets) ...[
                    Positioned.fill(child: _SeekToView()),
                    Center(child: _Bfloading()),
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: kTabScrollDuration,
                        child: controller.isShowVideoCtrl
                            ? Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(child: _SeekToView()),
                                    Center(
                                      child: IconButton(
                                        iconSize: 40,
                                        color: Colors.white,
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
                                      child: _VideoBottomCtrl(),
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
          );
        },
      ),
    );
  }
}

/// 视频进入缓冲状态,显示laoding
class _Bfloading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kTabScrollDuration,
      child: Observer(
        builder: (_) => Provider.of<VideoController>(context).isBfLoading
            ? _CircularProgressIndicatorBig(color: Colors.white)
            : SizedBox(),
      ),
    );
  }
}

/// 快进，快退两个隐藏的板块按钮
class _SeekToView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoController>(context);
    Function tap = () => controller.showVideoCtrl(!controller.isShowVideoCtrl);
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: tap,
            onDoubleTap: controller.rewind,
            child: Container(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: InkWell(
            onTap: tap,
            onDoubleTap: controller.fastForward,
            child: Container(),
          ),
        ),
      ],
    );
  }
}

/// video 底部的控制器
class _VideoBottomCtrl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoController>(context);
    return Observer(
      builder: (_) => ListTile(
        title: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(color: Colors.white),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  controller.videoBoxTimeText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(controller.volumeIcon),
                onPressed: controller.setOnSoundOrOff,
              ),
              IconButton(
                icon: Icon(controller.fullScreenIcon),
                onPressed: () => controller.onFullScreen(context),
              ),
            ],
          ),
        ),
        subtitle: Theme(
          data: Theme.of(context).copyWith(
            sliderTheme: Theme.of(context).sliderTheme.copyWith(
                  trackHeight: 2, // line的高度
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: RoundSliderThumbShape(
                    // 拇指的形状和大小
                    enabledThumbRadius: 6.0,
                  ),
                ),
          ),
          child: BufferSlider(
            inactiveColor: Colors.white24,
            bufferColor: Colors.white38,
            activeColor: Colors.white,
            value: controller.sliderValue,
            bufferValue: controller.sliderBufferValue,
            onChanged: controller.sliderChanged,
          ),
        ),
      ),
    );
  }
}

/// 稍微大一点的loading
class _CircularProgressIndicatorBig extends StatelessWidget {
  static const double SIZE = 50;
  final double size;
  final Color color;

  const _CircularProgressIndicatorBig({
    Key key,
    this.size = SIZE,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
