import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:video_box/util/duration_string.dart' show durationString;

import 'video_box.dart';
part 'video.controller.g.dart';

class VideoController = _VideoController with _$VideoController;

abstract class _VideoController with Store {
  _VideoController({
    VideoPlayerController source,
    this.skiptime = const Duration(seconds: 10),
    this.autoplay = false,
    this.loop = false,
    this.volume = 1.0,
    this.initPosition = const Duration(seconds: 0),
    this.cover,
    this.playingListenner,
    this.playEnd,
    this.controllerWidgets = true,
  }) {
    assert(source != null);
    initVideoPlaer(source);
  }

  initAnimetedIconController(TickerProvider vsync) {
    animetedIconController = AnimationController(
      duration: kTabScrollDuration,
      vsync: vsync,
    );
    animetedIconTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animetedIconController);
    setAnimetedIconState(autoplay || videoCtrl.value.isPlaying);
  }

  Future<void> setAnimetedIconState(bool play) async {
    if (play) {
      await animetedIconController.forward();
    } else {
      await animetedIconController.reverse();
    }
  }

  AnimationController animetedIconController;
  Animation<double> animetedIconTween;

  List<Widget> children;
  List<Widget> beforeChildren;
  List<Widget> afterChildren;

  @observable
  bool isPlayEnd = false;

  /// 自动关闭 videoCtrl 的计时器
  Timer _showCtrlTimer;

  /// 用户可以发送一个callback的函数进来，video播放时触发
  Function playingListenner;

  /// Played out
  Function playEnd;

  /// cover
  ///
  /// 自动居中
  @observable
  Widget cover;

  /// 是否显示默认控件 默认[true]
  @observable
  bool controllerWidgets;

  @observable
  bool isBfLoading = false;

  @action
  void setIsBfLoading() {
    if (videoCtrl.value.buffered == null || videoCtrl.value.buffered.isEmpty) {
      isBfLoading = false;
    } else {
      /// 当前播放的位置，大于了缓冲的位置，就会进入加载状态
      isBfLoading =
          videoCtrl.value.position >= videoCtrl.value.buffered.last.end;
    }
  }

  /// set cover
  @action
  void setCover(Widget newCover) {
    cover = newCover;
  }

  /// 是否显示封面，只有在第一次播放前显示
  @computed
  bool get isShowCover {
    if (cover == null) return false;
    if (position == initPosition || position == Duration(seconds: 0)) {
      return true;
    } else {
      return false;
    }
  }

  /// autoplay [false]
  @observable
  bool autoplay;

  /// set [autoplay]
  @action
  void setAutoplay(bool autoplay) {
    autoplay = autoplay;
  }

  /// Loop [false]
  @observable
  bool loop;

  @action
  void setLoop(bool loop) {
    loop = loop;
    videoCtrl?.setLooping(loop);
  }

  /// volume [1.0]
  @observable
  double volume;

  /// set [volume]
  @action
  void setVolume(double v) {
    volume = v;
    videoCtrl?.setVolume(v);
  }

  @observable
  VideoPlayerController videoCtrl;

  /// loading VideoPlayerController
  @observable
  bool isVideoLoading = true;

  /// set [isVideoLoading]
  @action
  void setVideoLoading(bool v) {
    isVideoLoading = v;
  }

  /// Initialize the play position
  @observable
  Duration initPosition;

  /// set [initPosition]
  @action
  void setInitPosition(Duration p) {
    initPosition = p;
  }

  /// Current position
  @observable
  Duration position;

  /// anime总时长
  @observable
  Duration duration;

  /// total length
  @observable
  bool isShowVideoCtrl = true;

  /// set [isShowVideoCtrl]
  @action
  void showVideoCtrl(bool show) {
    isShowVideoCtrl = show;
    if (show) {
      if (_showCtrlTimer?.isActive ?? false) {
        _showCtrlTimer?.cancel();
      } else {
        _showCtrlTimer = Timer(Duration(seconds: 2), () {
          // 2秒后，暂停状态不自动关闭
          if (videoCtrl.value.isPlaying) {
            showVideoCtrl(false);
          }
        });
      }
    }
  }

  /// 是否为全屏播放
  @observable
  bool isFullScreen = false;

  /// 快进，快退的时间
  @observable
  Duration skiptime;

  /// set [skiptime]
  @action
  void setSkiptime(Duration st) {
    skiptime = st;
  }

  /// 25:00 or 2:00:00 总时长
  @computed
  String get durationText {
    return duration == null ? '' : durationString(duration);
  }

  /// 00:01 当前时间
  @computed
  String get positionText {
    return (videoCtrl == null) ? '' : durationString(position);
  }

  /// '00:00/00:00'
  @computed
  String get videoBoxTimeText =>
      isVideoLoading ? '00:00/00:00' : "$positionText/$durationText";

  @computed
  double get sliderValue {
    if (position?.inSeconds != null && duration?.inSeconds != null) {
      return position.inSeconds / duration.inSeconds;
    } else {
      return 0.0;
    }
  }

  @observable
  double sliderBufferValue = 0.0;

  /// 返回一个符合当前音量的icon
  @computed
  IconData get volumeIcon {
    if (isVideoLoading) {
      return Icons.volume_up;
    }
    return volume <= 0
        ? Icons.volume_off
        : volume <= 0.5 ? Icons.volume_down : Icons.volume_up;
  }

  @computed
  IconData get fullScreenIcon =>
      !isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit;

  /// 视频播放时的监听器
  @action
  void _videoListenner() {
    position = videoCtrl.value.position;

    // 因为可能会出现空值
    if (videoCtrl.value.buffered != null &&
        videoCtrl.value.buffered.isNotEmpty) {
      sliderBufferValue =
          videoCtrl.value.buffered.last.end.inSeconds / duration.inSeconds;
    }

    setIsBfLoading();
    if (playingListenner != null) {
      playingListenner();
    }

    /// video播放结束
    if (position >= duration) {
      /// 如果用户调用了播放结束的监听器
      if (this.playEnd != null) {
        playEnd();
      }
      isPlayEnd = true;
      isBfLoading = false; // 播放结束缓冲什么的都不存在了
      showVideoCtrl(true); // 播放结束默认弹起video的控制器
    } else {
      isPlayEnd = false;
    }
  }

  @action
  Future<void> setSource(VideoPlayerController videoDataSource) async {
    assert(videoDataSource != null);
    videoCtrl?.pause();
    videoCtrl?.removeListener(_videoListenner);
    var oldCtrl = videoCtrl;
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    await initVideoPlaer(videoDataSource);
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer(VideoPlayerController videoDataSource) async {
    assert(videoDataSource != null);
    setVideoLoading(true);
    isBfLoading = false;
    videoCtrl = videoDataSource;
    await videoCtrl.initialize();
    videoCtrl.setLooping(loop);
    videoCtrl.setVolume(volume);
    if (autoplay) {
      videoCtrl.play();
    }
    if (initPosition != null) {
      seekTo(initPosition);
    }
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    videoCtrl.addListener(_videoListenner);
    setVideoLoading(false);
  }

  /// 开启声音或关闭
  @action
  void setOnSoundOrOff() {
    if (isVideoLoading) return;
    if (videoCtrl.value.volume > 0) {
      setVolume(0.0);
    } else {
      setVolume(1.0);
    }
  }

  /// 手动改变进度条
  void sliderChanged(double v) {
    seekTo(Duration(seconds: (v * duration.inSeconds).toInt()));
  }

  /// 设置为横屏模式
  @action
  void _setLandscape() {
    isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  @action
  void _setPortrait() {
    isFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 播放或暂停
  @action
  Future<void> togglePlay() async {
    // 等待Icon动画关闭
    await setAnimetedIconState(!videoCtrl.value.isPlaying);
    if (controllerWidgets == false) {
      if (videoCtrl.value.isPlaying) {
        await videoCtrl.pause();
      } else {
        await videoCtrl.play();
      }
    } else {
      if (videoCtrl.value.isPlaying) {
        await pause();
      } else {
        await play();
      }
    }
  }

  /// 播放
  @action
  Future<void> play() async {
    // 如果视频播放结束
    // 再点击播放则重头开始播放
    if (isPlayEnd) {
      await videoCtrl.seekTo(Duration(seconds: 0));
    }
    await videoCtrl.play();
    showVideoCtrl(false);
  }

  /// 暂停
  @action
  Future<void> pause() async {
    await videoCtrl.pause();
    showVideoCtrl(true);
  }

  /// 控制播放时间位置
  @action
  Future<void> seekTo(Duration d) async {
    if (videoCtrl != null && videoCtrl.value != null) {
      videoCtrl.seekTo(d);
      setIsBfLoading();
    }
  }

  /// 快进
  void fastForward([Duration st]) {
    seekTo(videoCtrl.value.position + (st ?? skiptime));
  }

  /// 快退
  void rewind([Duration st]) {
    seekTo(videoCtrl.value.position - (st ?? skiptime));
  }

  /// screen  自定义全屏page
  Future<void> onFullScreen(BuildContext context, [Widget screen]) async {
    if (isFullScreen) {
      /// 退出全屏
      Navigator.of(context).pop();
    } else {
      /// 开启全屏
      _setLandscape();
      Screen.keepOn(true);
      SystemChrome.setEnabledSystemUIOverlays([]);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => screen ?? _FullPageVideo(controller: this),
        ),
      );
      _setPortrait();
      Screen.keepOn(false);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

  @override
  Future<void> dispose() async {
    animetedIconController.dispose();
    videoCtrl?.removeListener(_videoListenner);
    await videoCtrl?.pause();
    await videoCtrl?.dispose();
    super.dispose();
  }

  VideoState toObject() {
    return VideoState(
      src: videoCtrl.dataSource,
      size: videoCtrl.value.size,
      autoplay: autoplay,
      loop: loop,
      volume: volume,
      initPosition: initPosition,
      position: position,
      duration: duration,
      skiptime: skiptime,
      positionText: positionText,
      durationText: durationText,
      sliderValue: sliderValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "src": videoCtrl.dataSource,
      "size": videoCtrl.value.size,
      "autoplay": autoplay,
      "loop": loop,
      "volume": volume,
      "initPosition": initPosition,
      "position": position,
      "duration": duration,
      "skiptime": skiptime,
      "positionText": positionText,
      "durationText": durationText,
      "sliderValue": sliderValue,
    };
  }
}

class VideoState {
  VideoState({
    this.src,
    this.size,
    this.loop,
    this.autoplay,
    this.volume,
    this.initPosition,
    this.position,
    this.duration,
    this.skiptime,
    this.positionText,
    this.durationText,
    this.sliderValue,
  });

  String src;
  Size size;
  bool autoplay;
  bool loop;
  double volume;
  Duration initPosition;
  Duration position;
  Duration duration;
  Duration skiptime;
  String positionText;
  String durationText;
  double sliderValue;
}

class _FullPageVideo extends StatelessWidget {
  final VideoController controller;

  const _FullPageVideo({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: VideoBox(controller: controller),
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
