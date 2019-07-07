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
                    if (videoStore.isBfLoading)
                      _CircularProgressIndicatorBig(
                        color: Colors.black87,
                      ),
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
            child: GestureDetector(
              onTap: () =>
                  videoStore.showVideoCtrl(!videoStore.isShowVideoCtrl),
              onDoubleTap: videoStore.rewind,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  videoStore.showVideoCtrl(!videoStore.isShowVideoCtrl),
              onDoubleTap: videoStore.fastForward,
            ),
          ),
        ],
      ),
    );
  }
}

/// video 中间的播放按钮
class _PlayButton extends StatefulWidget {
  @override
  __PlayButtonState createState() => __PlayButtonState();
}

class __PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _tween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final videoStore = Provider.of<VideoStore>(context);
    if (!videoStore.videoCtrl.value.isPlaying) {
      _controller.reset();
    } else {
      _controller.forward();
    }
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
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _tween,
            ),
            onPressed: videoStore.isShowVideoCtrl
                ? () => videoStore.togglePlay(_controller)
                : null,
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
                    sliderTheme: Theme.of(context).sliderTheme.copyWith(
                          trackHeight: 4, // line的高度
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: RoundSliderThumbShape(
                            // 拇指的形状和大小
                            enabledThumbRadius: 6.0,
                          ),
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
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            cover == null ? _CircularProgressIndicatorBig() : cover,
          ],
        ),
      ),
    );
  }
}

class _CircularProgressIndicatorBig extends StatelessWidget {
  final double size;
  final Color color;

  const _CircularProgressIndicatorBig({
    Key key,
    this.size = 50,
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
