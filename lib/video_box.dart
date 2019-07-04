import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:video_box/video.store.dart';
import 'package:video_player/video_player.dart';

/// 下面是一个简单的example，更具体使用何以看 /example下面的代码或则源码
///
/// ```dart
/// Video video = Video(
///   store: VideoStore(videoDataSource: VideoDataSource.network('http://example.com/example.mp4')),
/// );
///
/// @override
/// void dispose() {
///   video.dispose();
///   super.dispose();
/// }
///
/// // 在ui中展示
/// Container(child: video.videoBox),
/// ```
class Video {
  Video({
    this.store,
  }) : videoBox = VideoBox(store: store);
  final VideoStore store;
  final VideoBox videoBox;
  dispose() {
    store.dispose();
  }
}

class VideoBox extends StatefulWidget {
  VideoBox({
    Key key,
    this.videoDataSource,
    this.store,
    this.isDispose = false,
  }) : super(key: key);

  final VideoDataSource videoDataSource;
  final VideoStore store;
  final isDispose;
  @override
  _VideoBoxState createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> {
  VideoStore videoStore;

  @override
  void initState() {
    super.initState();
    videoStore =
        widget.store ?? VideoStore(videoDataSource: widget.videoDataSource);
  }

  @override
  void dispose() {
    if (widget.isDispose) {
      videoStore.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => videoStore.isVideoLoading
          ? _VideoLoading()
          : MultiProvider(
              providers: [Provider<VideoStore>.value(value: videoStore)],
              child: GestureDetector(
                onTap: () =>
                    videoStore.showVideoCtrl(!videoStore.isShowVideoCtrl),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: _VideoLoading(
                        cover: videoStore.cover,
                      ),
                      secondChild: Container(
                        decoration: BoxDecoration(color: Colors.black),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: videoStore.videoCtrl.value.aspectRatio,
                            child: VideoPlayer(videoStore.videoCtrl),
                          ),
                        ),
                      ),
                      crossFadeState: videoStore.isShowCover
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    ),
                    _SeekToView(),
                    _PlayButton(),
                    _VideoBottomCtrl(),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 快进，快退两个隐藏的板块按钮
class _SeekToView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videoStore = Provider.of<VideoStore>(context);
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: GestureDetector(
              onDoubleTap: videoStore.rewind,
              child: Container(
                decoration: BoxDecoration(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onDoubleTap: videoStore.fastForward,
              child: Container(
                decoration: BoxDecoration(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// video 中间的播放按钮
class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videoStore = Provider.of<VideoStore>(context);
    return Observer(
      builder: (_) => AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        firstChild: Container(),
        secondChild: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: Colors.black,
            icon: Icon(
              videoStore.videoCtrl == null ||
                      videoStore.videoCtrl.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed:
                videoStore.isShowVideoCtrl ? videoStore.togglePlay : null,
          ),
        ),
        crossFadeState: videoStore.isShowVideoCtrl
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
      ),
    );
  }
}

/// video 底部的控制器
class _VideoBottomCtrl extends StatelessWidget {
  /// 返回一个符合当前音量的icon
  IconData _volumeIcon(double volume) {
    return volume <= 0
        ? Icons.volume_off
        : volume <= 0.5 ? Icons.volume_down : Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    final videoStore = Provider.of<VideoStore>(context);
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
                begin: Alignment(0.0, 0.3),
                end: Alignment(0.0, 1.0),
                colors: [
                  Colors.black12,
                  Colors.black54,
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
                          videoStore.isVideoLoading
                              ? '00:00/00:00'
                              : "${videoStore.positionText}/${videoStore.durationText}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      videoStore.isVideoLoading
                          ? IconButton(
                              icon: Icon(Icons.volume_up),
                              onPressed: () {},
                            )
                          : IconButton(
                              icon: Icon(_volumeIcon(
                                  videoStore.videoCtrl.value.volume)),
                              onPressed: videoStore.setOnSoundOrOff,
                            ),
                      IconButton(
                        icon: Icon(
                          !videoStore.isFullScreen
                              ? Icons.fullscreen
                              : Icons.fullscreen_exit,
                        ),
                        onPressed: () => videoStore.onFullScreen(context),
                      ),
                    ],
                  ),
                ),
                subtitle: Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      // trackHeight: 4, // line的高度
                      // overlayShape: RoundSliderOverlayShape(
                      //   overlayRadius: 0,
                      // ), // 用于绘制[Slider]叠加层的形状
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 5.0,
                      ), // 拇指的形状和大小
                    ),
                  ),
                  child: Slider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    value: videoStore.sliderValue,
                    onChanged: videoStore.sliderChanged,
                  ),
                )),
          ),
          crossFadeState: videoStore.isShowVideoCtrl
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
    const double size = 50;
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            cover == null
                ? SizedBox(
                    height: size,
                    width: size,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : cover,
          ],
        ),
      ),
    );
  }
}
