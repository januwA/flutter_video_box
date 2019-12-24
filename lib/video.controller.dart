import 'dart:async';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
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
    this.controllerWidgets = true,
    this.controllerDuration = const Duration(seconds: 2),
    this.background = Colors.black,
    this.color = Colors.white,
    this.bufferColor = Colors.white38,
    this.inactiveColor = Colors.white24,
    this.circularProgressIndicatorColor = Colors.white,
    this.animetedIconDuration = kTabScrollDuration,
    Color barrierColor,
  }) {
    videoCtrl = source;
    this.barrierColor = barrierColor ?? Colors.black.withOpacity(0.6);
    _initPlatformState();
  }

  final Duration animetedIconDuration;
  final Color background;
  final Color color;
  final Color bufferColor;
  final Color inactiveColor;
  final Color circularProgressIndicatorColor;

  /// 监听视频播放回调
  /// Listening to video playback callbacks
  Function _playingListenner;
  addListener(void Function() listener) {
    this._playingListenner = listener;
  }

  /// 监听视频播放结束回调
  /// Listening to video playback end callback
  Function _playEnd;
  addPlayEndListener(void Function() listener) {
    this._playEnd = listener;
  }

  Function _fullScreenChange;
  addFullScreenChangeListener(void Function() listener) {
    this._fullScreenChange = listener;
  }

  /// 控制媒体音量
  /// Controlling media volume
  Future<void> _initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  /// 动画icon的初始化
  /// Initialization of the animation icon
  void initAnimetedIconController(TickerProvider vsync) {
    animetedIconController = AnimationController(
      duration: animetedIconDuration,
      vsync: vsync,
    );

    animetedIconTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animetedIconController);
    setAnimetedIconState();
  }

  Future<void> setAnimetedIconState() async {
    if (animetedIconController == null) return;
    if (videoCtrl.value.isPlaying) {
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

  /// 控制器背景色
  /// Controller background color
  @observable
  Color barrierColor;

  bool isPlayEnd = false;

  /// 自动关闭 Controller layer 的计时器
  /// Automatically turn off the timer of the Controller layer
  Timer _controllerLayerTimer;

  /// cover
  ///
  /// 自动居中
  /// Auto-center
  @observable
  Widget cover;

  /// 是否显示默认控件 默认[true]
  /// Whether to show default controls default [true]
  @observable
  bool controllerWidgets;

  @observable
  bool isBfLoading = false;

  Duration get buffered {
    var value = videoCtrl.value;
    if (value.buffered?.isEmpty ?? true) return null;
    return value.buffered.last.end;
  }

  /// 随时监听缓冲状态
  /// Listen to buffer status at any time
  @action
  void setVideoBuffer() {
    if (buffered == null) {
      isBfLoading = false;
    } else {
      sliderBufferValue = buffered.inSeconds / duration.inSeconds;

      /// 当前播放的位置大于了缓冲的位置，就会进入加载状态
      /// The currently playing position is greater than the buffer position, and it will enter the loading state
      var value = videoCtrl.value;
      if (value.isPlaying) {
        isBfLoading = value.position >= buffered;
      } else {
        isBfLoading = value.position > buffered;
      }
    }
  }

  /// set cover
  @action
  void setCover(Widget newCover) => cover = newCover;

  /// 是否显示封面，只有在第一次播放前显示
  /// Whether to show the cover, only before the first play
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

  /// 视频总时长
  /// Total video duration
  @observable
  Duration duration;

  /// 是否显示控制器层
  /// Whether to show the controller layer
  @observable
  bool controllerLayer = true;

  /// set [controllerLayer]
  @action
  void setControllerLayer({bool show}) {
    controllerLayer = show;
    if (show) {
      if (_controllerLayerTimer?.isActive ?? false) {
        _controllerLayerTimer?.cancel();
      } else {
        _controllerLayerTimer = Timer(this.controllerDuration, () {
          // 暂停状态不自动关闭
          // Pause status does not close automatically
          if (videoCtrl.value.isPlaying) {
            setControllerLayer(show: false);
          }
        });
      }
    }
  }

  void toggleShowVideoCtrl() => setControllerLayer(show: !controllerLayer);

  /// 是否为全屏播放
  /// Whether to play in full screen
  @observable
  bool isFullScreen = false;

  /// 快进，快退的时间
  /// Fast forward and rewind time
  @observable
  Duration skiptime;

  /// set [skiptime]
  @action
  void setSkiptime(Duration st) {
    skiptime = st;
  }

  /// 25:00 or 2:00:00 总时长
  /// Total duration
  @computed
  String get durationText => duration == null ? '' : durationString(duration);

  /// 00:01 当前时间
  /// current time
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
  /// Returns an icon that matches the current volume
  @computed
  IconData get volumeIcon => volume <= 0
      ? Icons.volume_off
      : volume <= 0.5 ? Icons.volume_down : Icons.volume_up;

  @computed
  IconData get fullScreenIcon =>
      !isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit;

  /// 替换当前播放的视频资源
  /// Replace the currently playing video resource
  @action
  Future<void> setSource(VideoPlayerController source) async {
    var oldCtrl = videoCtrl;
    oldCtrl?.pause();
    oldCtrl?.removeListener(_videoListenner);
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    videoCtrl = source;
  }

  /// 控制器层存活的时间
  /// Controller layer time to live
  final Duration controllerDuration;

  /// 初始化viedo控制器
  /// Initialize the viedo controller
  @action
  Future<void> initialize() async {
    assert(videoCtrl != null);
    initialized = false;
    isBfLoading = false;
    await videoCtrl.initialize();
    videoCtrl
      ..setLooping(loop)
      ..setVolume(volume);
    if (autoplay) {
      setControllerLayer(show: false);
      await videoCtrl.play();
      setAnimetedIconState();
    }

    if (initPosition != null) seekTo(initPosition);
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    videoCtrl.addListener(_videoListenner);
    initialized = true;
  }

  /// 视频播放时的监听器
  /// Listener during video playback
  ///
  /// seek 也会触发
  /// 第一帧也会触发
  @action
  void _videoListenner() {
    position = videoCtrl.value.position;
    setVideoBuffer();
    if (_playingListenner != null) _playingListenner();

    /// video播放结束
    /// video playback ends
    if (position >= duration) {
      isPlayEnd = true;
      isBfLoading = false;
      setAnimetedIconState();

      /// 如果用户调用了播放结束的监听器
      if (this._playEnd != null) _playEnd();
      setControllerLayer(show: true);
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
  /// Turn sound on or off
  void setOnSoundOrOff() {
    if (videoCtrl.value != null) {
      double v = videoCtrl.value.volume > 0 ? 0.0 : 1.0;
      setVolume(v);
    }
  }

  /// 播放或暂停
  /// Play or pause
  Future<void> togglePlay() async {
    // 等待Icon动画关闭
    // Wait for Icon animation to close
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
    setAnimetedIconState();
  }

  /// 播放
  Future<void> play() async {
    if (isPlayEnd) {
      await videoCtrl.seekTo(Duration(seconds: 0));
    }

    await videoCtrl.play();
    setAnimetedIconState();
    setControllerLayer(show: false);
  }

  /// 暂停
  Future<void> pause() async {
    await videoCtrl.pause();
    setAnimetedIconState();
    setControllerLayer(show: true);
  }

  /// 控制播放时间位置
  /// Controlling playback time position
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

  /// 进度条被改变
  /// The progress bar is changed
  void sliderChanged(double v) =>
      seekTo(Duration(seconds: (v * duration.inSeconds).toInt()));

  /// 设置为横屏模式
  /// Set to landscape mode
  @action
  void _setLandscape() {
    isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  /// Set to normal mode
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
  Future<void> onFullScreen(BuildContext context, [Widget customScreen]) async {
    if (isFullScreen) {
      // Exit Full Screen
      Navigator.of(context).pop();
    } else {
      // Turn on full screen
      _setLandscape();
      // Screen.keepOn(true);
      SystemChrome.setEnabledSystemUIOverlays([]);
      if (_fullScreenChange != null) _fullScreenChange();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => customScreen ?? _FullPageVideo(controller: this),
        ),
      );
      _setPortrait();
      // Screen.keepOn(false);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (_fullScreenChange != null) _fullScreenChange();
    }
  }

  /// 右侧版块设置媒体音量
  /// Set the media volume on the right side
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

  // double _currentBrightness;

  /// 左侧版块设置屏幕亮度
  /// The left section sets the screen brightness
  /// TODO: Screen 出现错误删除此依赖，寻找其它解决方案
  Future<void> setScreenBrightness(DragUpdateDetails d) async {
    // double dy = d.delta.dy / 200;
    // _currentBrightness ??= await Screen.brightness;
    // double v;
    // if (dy > 0) {
    //   v = max(_currentBrightness - dy.abs(), 0);
    // } else {
    //   v = min(_currentBrightness + dy.abs(), 1);
    // }
    // _currentBrightness = v;
    // Screen.setBrightness(v);
  }

  /// set MEDIA Volume
  Future<int> setVol(int i) => Volume.setVol(i);

  /// 清理资源
  Future<void> dispose() async {
    animetedIconController?.dispose();
    videoCtrl?.removeListener(_videoListenner);
    await videoCtrl?.pause();
    await videoCtrl?.dispose();
    _controllerLayerTimer?.cancel();
  }

  VideoState get value => VideoState(
        dataSource: videoCtrl.dataSource,
        dataSourceType: videoCtrl.dataSourceType,
        size: videoCtrl.value.size,
        autoplay: autoplay,
        isLooping: videoCtrl.value.isLooping,
        isPlaying: videoCtrl.value.isPlaying,
        volume: volume,
        initPosition: initPosition,
        position: position,
        duration: duration,
        skiptime: skiptime,
        positionText: positionText,
        durationText: durationText,
        sliderValue: sliderValue,
      );

  @override
  String toString() => value.toString();
}

class VideoState {
  VideoState({
    this.dataSource,
    this.dataSourceType,
    this.size,
    this.isLooping,
    this.isPlaying,
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

  String dataSource;
  DataSourceType dataSourceType;
  Size size;
  bool autoplay;
  bool isLooping;
  bool isPlaying;
  double volume;
  Duration initPosition;
  Duration position;
  Duration duration;
  Duration skiptime;
  String positionText;
  String durationText;
  double sliderValue;

  Map<String, dynamic> toMap() {
    return {
      "dataSource": dataSource,
      "dataSourceType": dataSourceType,
      "size": size,
      "autoplay": autoplay,
      "isLooping": isLooping,
      "isPlaying": isPlaying,
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

  @override
  String toString() {
    return """
    {
      "dataSource": $dataSource,
      "dataSourceType": $dataSourceType,
      "size": $size,
      "autoplay": $autoplay,
      "isLooping": $isLooping,
      "isPlaying": $isPlaying,
      "volume": $volume,
      "initPosition": $initPosition,
      "position": $position,
      "duration": $duration,
      "skiptime": $skiptime,
      "positionText": $positionText,
      "durationText": $durationText,
      "sliderValue": $sliderValue,
    }
    """;
  }
}

class _FullPageVideo extends StatelessWidget {
  final VideoController controller;

  const _FullPageVideo({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: VideoBox(controller: controller)));
  }
}
