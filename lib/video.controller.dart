import 'dart:async';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobx/mobx.dart';
import 'package:video_player/video_player.dart';
import 'package:volume/volume.dart';

import 'video_box.dart' show CustomFullScreen, VideoBoxFullScreenPage;
import 'util/duration_string.dart' show durationString;
import 'video_state.dart';

part 'video.controller.g.dart';

typedef FullScreenChange = Function(VideoController controller);

Route<T> _defaultCustomFullScreenRoute<T>(VideoController controller) {
  return MaterialPageRoute<T>(
      builder: (_) => VideoBoxFullScreenPage(controller: controller));
}

/// 设置为正常模式
///
/// Set to normal mode
void setPortrait() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// 设置为横屏模式
///
/// Set to landscape mode
void setLandscape() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}

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
    this.controllerLiveDuration = const Duration(seconds: 2),
    this.controllerLayerDuration = kTabScrollDuration,
    this.background = Colors.black,
    this.color = Colors.white,
    this.bufferColor = Colors.white38,
    this.inactiveColor = Colors.white24,
    this.circularProgressIndicatorColor = Colors.white,
    this.animetedIconDuration = kTabScrollDuration,
    Color barrierColor,
    this.customLoadingWidget,
    this.customBufferedWidget,
    this.customFullScreen,
    this.bottomPadding = EdgeInsets.zero,
  }) {
    videoCtrl = source;
    this.barrierColor = barrierColor ?? Colors.black.withOpacity(0.6);
    _initPlatformState();
  }

  /// icon动画的持续时间
  /// 
  /// icon animation duration
  final Duration animetedIconDuration;
  final Color background;
  final Color color;
  final Color bufferColor;
  final Color inactiveColor;
  final Color circularProgressIndicatorColor;

  /// 控制器层打开和关闭动画的持续时间
  /// 
  /// Controller layer opening and closing animation duration
  final Duration controllerLayerDuration;

  /// 底部控制器的padding
  ///
  /// Padding of bottom controller
  final EdgeInsets bottomPadding;

  ///
  ///Example
  ///```dart
  ///class MyFullScreen extends CustomFullScreen {
  ///   @override
  ///   void close(BuildContext context, VideoController controller) {
  ///     Navigator.of(context).pop(controller.value.positionText);
  ///   }
  ///
  ///   @override
  ///   Future open(BuildContext context, VideoController controller) async {
  ///     setLandscape();
  ///     SystemChrome.setEnabledSystemUIOverlays([]);
  ///     await Navigator.of(context)
  ///         .push<String>(
  ///           PageRouteBuilder(
  ///             transitionDuration: Duration(seconds: 2),
  ///             pageBuilder: (context, animation, secondaryAnimation) {
  ///               return Scaffold(
  ///                   body: Center(child: VideoBox(controller: controller)));
  ///             },
  ///             transitionsBuilder:
  ///                 (context, animation, secondaryAnimation, child) {
  ///               return ScaleTransition(
  ///                 scale: Tween<double>(begin: 0.0, end: 1.0).animate(
  ///                   CurvedAnimation(
  ///                     parent: animation,
  ///                     curve: Curves.ease,
  ///                   ),
  ///                 ),
  ///                 child: child,
  ///               );
  ///             },
  ///           ),
  ///         )
  ///         .then(print);
  ///     setPortrait();
  ///     SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  ///   }
  /// }
  ///```
  final CustomFullScreen customFullScreen;

  /// 当视频首次加载时将显示这个widget。
  ///
  /// This widget will be displayed when the video is first loaded.
  ///
  /// Example:
  /// ```dart
  /// vc = VideoController(
  ///   ...
  ///   customLoadingWidget: Center(
  ///     child: Container(
  ///       color: Colors.pink,
  ///       padding: const EdgeInsets.all(12),
  ///       child: Column(
  ///         mainAxisSize: MainAxisSize.min,
  ///         children: <Widget>[
  ///           CircularProgressIndicator(),
  ///           SizedBox(height: 12),
  ///           Text("Lading..."),
  ///         ],
  ///       ),
  ///     ),
  ///   ),
  /// )
  /// ```
  final Widget customLoadingWidget;

  /// 当视频进入缓冲时将显示这个widget。
  /// 类似[customLoadingWidget]那样设置
  ///
  /// This widget will be displayed when the video enters the buffer.
  /// Set like [customLoadingWidget]
  final Widget customBufferedWidget;

  /// 监听视频播放回调
  ///
  /// Listening to video playback callbacks
  Function _playingListenner;
  addListener(void Function() listener) {
    _playingListenner = listener;
  }

  /// 监听视频播放结束回调
  ///
  /// Listening to video playback end callback
  Function _playEnd;
  addPlayEndListener(void Function() listener) {
    _playEnd = listener;
  }

  FullScreenChange _fullScreenChange;

  /// 添加监听屏幕改变事件
  ///
  /// Add listen screen change events
  addFullScreenChangeListener(FullScreenChange listener) {
    _fullScreenChange = listener;
  }

  /// 控制媒体音量
  ///
  /// Controlling media volume
  Future<void> _initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  /// 动画icon的初始化
  ///
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
  ///
  /// Controller background color
  @observable
  Color barrierColor;

  bool isPlayEnd = false;

  /// 自动关闭 Controller layer 的计时器
  ///
  /// Automatically turn off the timer of the Controller layer
  Timer _controllerLayerTimer;

  /// cover
  ///
  /// 自动居中
  /// Auto-center
  @observable
  Widget cover;

  /// 是否显示默认控件 默认[true]
  ///
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
  ///
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
  ///
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
  ///
  /// Total video duration
  @observable
  Duration duration;

  /// 是否显示控制器层
  ///
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
        _controllerLayerTimer = Timer(this.controllerLiveDuration, () {
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
  ///
  /// Whether to play in full screen
  @observable
  bool isFullScreen = false;

  @action
  void _setFullScreen({bool full}) {
    isFullScreen = full;
    if (_fullScreenChange != null) _fullScreenChange(this);
  }

  /// 快进，快退的时间
  ///
  /// Fast forward and rewind time
  @observable
  Duration skiptime;

  /// set [skiptime]
  @action
  void setSkiptime(Duration st) {
    skiptime = st;
  }

  /// 25:00 or 2:00:00 总时长
  ///
  /// Total duration
  @computed
  String get durationText => duration == null ? '' : durationString(duration);

  /// 00:01 当前时间
  ///
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
  ///
  /// Returns an icon that matches the current volume
  @computed
  IconData get volumeIcon => volume <= 0
      ? Icons.volume_off
      : volume <= 0.5 ? Icons.volume_down : Icons.volume_up;

  @computed
  IconData get fullScreenIcon =>
      !isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit;

  /// 替换当前播放的视频资源
  ///
  /// Replace the currently playing video resource
  @action
  Future<void> setSource(VideoPlayerController source) async {
    var oldCtrl = videoCtrl;
    oldCtrl?.pause();
    oldCtrl?.removeListener(_videoListenner);
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    videoCtrl = source;
  }

  /// 控制器层被打开后存活的时间
  ///
  /// Time to live after the controller layer is opened
  final Duration controllerLiveDuration;

  /// 初始化viedo控制器
  ///
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
  ///
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
  ///
  /// Turn sound on or off
  void setOnSoundOrOff() {
    if (videoCtrl.value != null) {
      double v = videoCtrl.value.volume > 0 ? 0.0 : 1.0;
      setVolume(v);
    }
  }

  /// 播放或暂停
  ///
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
  ///
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
  ///
  /// The progress bar is changed
  void sliderChanged(double v) =>
      seekTo(Duration(seconds: (v * duration.inSeconds).toInt()));

  /// 打开或关闭全屏
  ///
  /// Turn full screen on or off
  Future<void> onFullScreenSwitch(BuildContext context) async {
    if (customFullScreen == null) {
      if (isFullScreen) {
        Navigator.of(context).pop();
      } else {
        _setFullScreen(full: true);
        SystemChrome.setEnabledSystemUIOverlays([]);
        setLandscape();
        await Navigator.of(context).push(_defaultCustomFullScreenRoute(this));
        // 这里可以监听到系统导航栏的返回事件
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        setPortrait();
        _setFullScreen(full: false);
      }
    } else {
      if (isFullScreen) {
        customFullScreen.close(context, this);
      } else {
        _setFullScreen(full: true);
        await customFullScreen.open(context, this);
        _setFullScreen(full: false);
      }
    }
  }

  /// 右侧版块设置媒体音量
  ///
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
  ///
  /// The left section sets the screen brightness
  /// ! [screen 0.0.5]出现错误，删除此依赖，寻找其它解决方案
  /// https://pub.dev/packages/screen
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
        aspectRatio: videoCtrl.value.aspectRatio,
      );

  @override
  String toString() => value.toString();
}
