import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:video_box/custom_slider.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_player/video_player.dart';

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
    this.controller,
  }) : super(key: key);

  final VideoController controller;
  @override
  _VideoBoxState createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox>
    with SingleTickerProviderStateMixin {
  VideoController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller..initAnimetedIconController(this);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => controller.isVideoLoading
          ? _VideoLoading()
          : MultiProvider(
              providers: [Provider<VideoController>.value(value: controller)],
              child: GestureDetector(
                onTap: () =>
                    controller.showVideoCtrl(!controller.isShowVideoCtrl),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: controller.isShowCover
                          ? _VideoLoading(cover: controller.cover)
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.black,
                              child: VideoPlayer(controller.videoCtrl),
                            ),
                    ),
                    _SeekToView(),
                    _Bfloading(),
                    _PlayButton(),
                    _VideoBottomCtrl(),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 视频进入缓冲状态,显示laoding
class _Bfloading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<VideoController>(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: store.isBfLoading
          ? _CircularProgressIndicatorBig(color: Colors.black87)
          : SizedBox(),
    );
  }
}

/// 快进，快退两个隐藏的板块按钮
class _SeekToView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<VideoController>(context);
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => store.showVideoCtrl(!store.isShowVideoCtrl),
              onDoubleTap: store.rewind,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => store.showVideoCtrl(!store.isShowVideoCtrl),
              onDoubleTap: store.fastForward,
            ),
          ),
        ],
      ),
    );
  }
}

/// video box 中间的播放按钮
class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<VideoController>(context);
    if (!store.videoCtrl.value.isPlaying) {
      store.animetedIconController.reset();
    } else {
      store.animetedIconController.forward();
    }
    return Observer(
      builder: (_) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: store.isShowVideoCtrl
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Colors.black,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: store.animetedIconTween,
                  ),
                  onPressed: () => store.togglePlay(),
                ),
              )
            : SizedBox(),
      ),
    );
  }
}

/// video 底部的控制器
class _VideoBottomCtrl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<VideoController>(context);
    return Observer(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 300),
          firstChild: Container(),
          secondChild: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, -1.0),
                end: Alignment(0.0, 1.0),
                colors: [
                  Colors.black12.withOpacity(0),
                  Colors.black87,
                ],
              ),
            ),
            child: ListTile(
              title: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        store.videoBoxTimeText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(store.volumeIcon),
                      onPressed: store.setOnSoundOrOff,
                    ),
                    IconButton(
                      icon: Icon(
                        !store.isFullScreen
                            ? Icons.fullscreen
                            : Icons.fullscreen_exit,
                      ),
                      onPressed: () => store.onFullScreen(context),
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
                          enabledThumbRadius: 4.0,
                        ),
                      ),
                ),
                child: CustomSlider(
                  inactiveColor: Colors.white24,
                  bufferColor: Colors.white38,
                  activeColor: Colors.white,
                  value: store.sliderValue,
                  bufferValue: store.sliderBufferValue,
                  onChanged: store.sliderChanged,
                ),
              ),
            ),
          ),
          crossFadeState: store.isShowVideoCtrl
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ),
    );
  }
}

/// 没有src的时候，显示加载中
class _VideoLoading extends StatelessWidget {
  const _VideoLoading({
    Key key,
    this.cover,
  }) : super(key: key);

  final Widget cover;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cover == null ? _CircularProgressIndicatorBig() : cover,
        ],
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
