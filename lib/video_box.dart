import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:video_box/video.store.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';

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
    this.src,
    this.store,
    this.isDispose = false,
  }) : super(key: key);

  final String src;
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
    videoStore = widget.store ?? VideoStore(src: widget.src);
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
                    AnimatedOpacity(
                      opacity: videoStore.isShowCover ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: _VideoLoading(
                        cover: videoStore.cover,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: !videoStore.isShowCover ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: videoStore.videoCtrl.value.aspectRatio,
                            child: VideoPlayer(videoStore.videoCtrl),
                          ),
                        ),
                      ),
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
                onPressed: videoStore.togglePlay,
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
  Future<void> _onFullScreen(context, videoStore) async {
    if (videoStore.isFullScreen) {
      /// 退出全屏
      Navigator.of(context).pop();
    } else {
      /// 开启全屏
      videoStore.setLandscape();
      Screen.keepOn(true);
      SystemChrome.setEnabledSystemUIOverlays([]);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SafeArea(
                child: Scaffold(
                  body: Center(
                    child: VideoBox(
                      store: videoStore,
                    ),
                  ),
                ),
              ),
        ),
      );
      videoStore.setPortrait();
      Screen.keepOn(false);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

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
                decoration: BoxDecoration(color: Colors.black12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: IconThemeData(color: Colors.white),
                      sliderTheme: Theme.of(context).sliderTheme.copyWith(
                            /// 进度之前的颜色
                            activeTrackColor: Colors.white70,

                            /// 进度之后的颜色
                            inactiveTrackColor: Colors.white30,

                            // 指示器的颜色
                            thumbColor: Colors.white,
                          ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          videoStore.isVideoLoading
                              ? '00:00/00:00'
                              : "${videoStore.positionText}/${videoStore.durationText}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            // inactiveColor: Colors.grey[300],
                            // activeColor: Colors.white,
                            value: videoStore.sliderValue,
                            onChanged: videoStore.sliderChanged,
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
                                onPressed: videoStore.setVolume,
                              ),
                        IconButton(
                          icon: Icon(
                            !videoStore.isFullScreen
                                ? Icons.fullscreen
                                : Icons.fullscreen_exit,
                          ),
                          onPressed: () => _onFullScreen(context, videoStore),
                        ),
                      ],
                    ),
                  ),
                ),
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
            cover == null
                ? SizedBox(
                    height: 50,
                    width: 50,
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
