import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:video_box/util/duration_string.dart' show durationString;
import 'package:volume/volume.dart';

import 'video_box.dart';
part 'video.controller.g.dart';

class VideoController = _VideoController with _$VideoController;

abstract class _VideoController with Store {
  @action
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
    videoCtrl = source;
    _initPlatformState();
  }

  /// 控制媒体音量
  Future<void> _initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  /// 动画icon的初始化
  void initAnimetedIconController(TickerProvider vsync) {
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
    if (animetedIconController == null) return;
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

  /// 屏障颜色
  @observable
  Color barrierColor;

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

  /// 随时监听缓冲状态
  @action
  void setVideoBuffer() {
    var value = videoCtrl.value;
    if (value.buffered?.isEmpty ?? true) {
      isBfLoading = false;
    } else {
      sliderBufferValue =
          value.buffered.last.end.inSeconds / duration.inSeconds;

      /// 当前播放的位置，大于了缓冲的位置，就会进入加载状态
      if (value.isPlaying) {
        isBfLoading = value.position >= value.buffered.last.end;
      } else {
        isBfLoading = value.position > value.buffered.last.end;
      }
    }
  }

  /// set cover
  @action
  void setCover(Widget newCover) => cover = newCover;

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
  void setAutoplay(bool autoplay) => autoplay = autoplay;

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

  @observable
  VideoPlayerController videoCtrl;

  @observable
  bool initialized = false;

  /// Initialize the play position
  @observable
  Duration initPosition;

  /// set [initPosition]
  @action
  void setInitPosition(Duration p) => initPosition = p;

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
        _showCtrlTimer = Timer(Duration(seconds: 20), () {
          // 2秒后，暂停状态不自动关闭
          if (videoCtrl.value.isPlaying) {
            showVideoCtrl(false);
          }
        });
      }
    }
  }

  void toggleShowVideoCtrl() => showVideoCtrl(!isShowVideoCtrl);

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
  String get durationText => duration == null ? '' : durationString(duration);

  /// 00:01 当前时间
  @computed
  String get positionText =>
      (videoCtrl == null) ? '' : durationString(position);

  /// '00:00/00:00'
  @computed
  String get videoBoxTimeText =>
      initialized ? "$positionText/$durationText" : '00:00/00:00';

  @computed
  double get sliderValue =>
      (position?.inSeconds != null && duration?.inSeconds != null)
          ? position.inSeconds / duration.inSeconds
          : 0.0;

  @observable
  double sliderBufferValue = 0.0;

  /// 返回一个符合当前音量的icon
  @computed
  IconData get volumeIcon => volume <= 0
      ? Icons.volume_off
      : volume <= 0.5 ? Icons.volume_down : Icons.volume_up;

  @computed
  IconData get fullScreenIcon =>
      !isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit;

  /// 替换当前播放的视频资源
  @action
  Future<void> setSource(VideoPlayerController source) async {
    var oldCtrl = videoCtrl;
    oldCtrl?.pause();
    oldCtrl?.removeListener(_videoListenner);
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    setAnimetedIconState(autoplay || videoCtrl.value.isPlaying);
    videoCtrl = source;
  }

  /// 初始化viedo控制器
  @action
  Future<void> initialize() async {
    assert(videoCtrl != null);
    initialized = false;
    isBfLoading = false;
    await videoCtrl.initialize();
    videoCtrl.setLooping(loop);
    videoCtrl.setVolume(volume);
    if (autoplay) videoCtrl.play();
    if (initPosition != null) seekTo(initPosition);
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    videoCtrl.addListener(_videoListenner);
    initialized = true;
  }

  /// 视频播放时的监听器
  /// seek 也会触发
  /// 第一帧也会触发
  @action
  void _videoListenner() {
    position = videoCtrl.value.position;
    setVideoBuffer();
    if (playingListenner != null) playingListenner();

    /// video播放结束
    if (position >= duration) {
      setAnimetedIconState(false);

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

  /// set [volume]
  @action
  void setVolume(double v) {
    volume = v;
    videoCtrl?.setVolume(v);
  }

  /// 开启声音或关闭
  void setOnSoundOrOff() {
    if (videoCtrl.value != null) {
      double v = videoCtrl.value.volume > 0 ? 0.0 : 1.0;
      setVolume(v);
    }
  }

  /// 播放或暂停
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
  Future<void> play() async {
    // 如果视频播放结束
    // 再点击播放则重头开始播放
    if (isPlayEnd) {
      await videoCtrl.seekTo(Duration(seconds: 0));
    }

    await setAnimetedIconState(true);
    await videoCtrl.play();
    showVideoCtrl(false);
  }

  /// 暂停
  Future<void> pause() async {
    await setAnimetedIconState(false);
    await videoCtrl.pause();
    showVideoCtrl(true);
  }

  /// 控制播放时间位置
  Future<void> seekTo(Duration d) async {
    if (videoCtrl.value != null) {
      await videoCtrl.seekTo(d);
    }
  }

  /// 快进
  void fastForward([Duration st]) {
    if (videoCtrl.value != null)
      seekTo(videoCtrl.value.position + (st ?? skiptime));
  }

  /// 快退
  void rewind([Duration st]) {
    if (videoCtrl.value != null) {
      seekTo(videoCtrl.value.position - (st ?? skiptime));
    }
  }

  /// 手动改变进度条
  void sliderChanged(double v) =>
      seekTo(Duration(seconds: (v * duration.inSeconds).toInt()));

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

  /// screen  自定义全屏page
  Future<void> onFullScreen(BuildContext context, [Widget screen]) async {
    if (isFullScreen) {
      Navigator.of(context).pop(); // 退出全屏
    } else {
      // 开启全屏
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

  // 右侧板块设置媒体音量
  Future<void> setMediaVolume(DragUpdateDetails d) async {
    // if (d.delta.dy < 0) {
    //   Volume.volUp();
    // } else if (d.delta.dy > 0) {
    //   Volume.volDown();
    // }
    int _currentVol = await Volume.getVol;
    int dy = (-d.delta.dy * 0.2).toInt();
    setVol(_currentVol + dy);
  }

  double _currentBrightness;
  // 左侧板块设置屏幕亮度
  Future<void> setScreenBrightness(DragUpdateDetails d) async {
    double dy = d.delta.dy / 200;
    _currentBrightness ??= await Screen.brightness;
    double v;
    if (dy > 0) {
      v = max(_currentBrightness - dy.abs(), 0);
    } else {
      v = min(_currentBrightness + dy.abs(), 1);
    }
    _currentBrightness = v;
    Screen.setBrightness(v);
  }

  /// set MEDIA Volume
  Future<int> setVol(int i) => Volume.setVol(i);

  Future<void> dispose() async {
    animetedIconController?.dispose();
    videoCtrl?.removeListener(_videoListenner);
    await videoCtrl?.pause();
    await videoCtrl?.dispose();
    _showCtrlTimer?.cancel();
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
    return Scaffold(body: Center(child: VideoBox(controller: controller)));
  }
}
