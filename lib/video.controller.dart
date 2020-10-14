import 'dart:async' show StreamSubscription, Timer;

import 'package:connectivity/connectivity.dart';
// import 'package:dart_printf/dart_printf.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobx/mobx.dart';
import 'package:video_player/video_player.dart'
    show VideoPlayerController, VideoPlayerValue;

import '_util.dart';
import 'mixin/animation_icon_mixin.dart';
import 'mixin/custom_view_mixin.dart';
import 'mixin/video_listenner_mixin.dart';
import 'video_state.dart';

part 'video.controller.g.dart';

class VideoController = _VideoController with _$VideoController;

void kAccelerometerEventsListenner(
  VideoController controller,
  AccelerometerEvent event,
) {
  if (!controller.isFullScreen) return;
  bool isHorizontal = event.x.abs() > event.y.abs(); // 横屏模式
  if (!isHorizontal) return;
  if (event.x > 1) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  } else if (event.x < -1) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  }
}

abstract class BaseVideoController {
  VideoPlayerController videoCtrl;
  Duration animetedIconDuration;
}

abstract class _VideoController extends BaseVideoController
    with Store, VideoListennerMixin, CustomViewMixin, AnimationIconMixin {
  /// 控制器层被打开后存活的时间
  ///
  /// Time to live after the controller layer is opened
  final Duration controllerLiveDuration;

  /// 您可以传递一个[options]，但[options]并不会在内部使用，但您可以在各个回调中访问[options]:
  ///
  /// You can pass an [options], but [options] is not used internally, but you can access [options] in various callbacks:
  ///
  /// ```dart
  /// VideoController(
  ///   options: { "name": "Ajanuw" },
  ///   bottomViewBuilder: (context, c) {
  ///     c.options
  ///   }),
  /// );
  /// ```
  ///
  final dynamic options;

  /// icon动画的持续时间
  ///
  /// icon animation duration
  @override
  final Duration animetedIconDuration;

  /// 快进，快退的时间
  ///
  /// Fast forward and rewind time
  final Duration skiptime;

  /// 控制器层打开和关闭动画的持续时间
  ///
  /// Controller layer opening and closing animation duration
  final Duration controllerLayerDuration;

  @action
  _VideoController({
    VideoPlayerController source,
    this.skiptime = const Duration(seconds: 10),
    this.autoplay = false,
    this.looping = false,
    this.volume = 1.0,
    this.initPosition = const Duration(seconds: 0),
    this.controllerWidgets = true,
    this.controllerLiveDuration = const Duration(seconds: 2),
    this.controllerLayerDuration = kTabScrollDuration,
    this.animetedIconDuration = kTabScrollDuration,
    this.options,
  }) {
    videoCtrl = source;
    if (this.accelerometerEventsListenner == null)
      addAccelerometerEventsListenner(kAccelerometerEventsListenner);

    // 初始化所有需要的流

    _streamSubscriptions$ ??=
        accelerometerEvents.listen(_streamSubscriptionsCallback);
    _connectivityChanged$ ??= Connectivity()
        .onConnectivityChanged
        .listen(_connectivityChangedCallBack);
  }

  @override
  VideoPlayerController videoCtrl;
  VideoPlayerValue get _value => videoCtrl.value;

  /// 监听页面旋转流
  StreamSubscription<dynamic> _streamSubscriptions$;
  void _streamSubscriptionsCallback(AccelerometerEvent event) =>
      accelerometerEventsListenner(this, event);

  /// 监听网络连接
  ConnectivityResult _connectivityStatus;
  StreamSubscription<ConnectivityResult> _connectivityChanged$;
  void _connectivityChangedCallBack(ConnectivityResult result) {
    // printf('NetworkChange(%o)', result);

    if (connectivityChangedListenner != null)
      connectivityChangedListenner(this, result);

    bool isReconnection = _connectivityStatus == ConnectivityResult.none &&
        result != ConnectivityResult.none &&
        isBfLoading &&
        _value.buffered.isEmpty;
    if (isReconnection) {
      // 从断网中恢复过来, 重新连接解码器
      // 所有事件监听器不会被移除
      initialize(true);
    }

    _connectivityStatus = result;
  }

  @observable
  double aspectRatio;
  @action
  void setAspectRatio(double v) => aspectRatio = v;

  bool get isPlayEnd =>
      (position ?? Duration.zero) >= (duration ?? Duration.zero);

  /// 自动关闭 Controller layer 的计时器
  ///
  /// Automatically turn off the timer of the Controller layer
  Timer _controllerLayerTimer;

  /// 是否显示默认控件 默认[true]
  ///
  /// Whether to show default controls default [true]
  @observable
  bool controllerWidgets;
  @action
  void setControllerWidgets(bool v) => controllerWidgets = v;

  @observable
  bool isBfLoading = false;
  @action
  void setIsBfLoading(bool v) => isBfLoading = v;

  // 获取video的缓冲时间
  Duration get _buffered {
    if (_value.buffered?.isEmpty ?? true) return Duration.zero;
    // 经过我的测试发现这个buffered数组的length，总是为1
    // print('buffered length: ' + value.buffered.length.toString());
    return _value.buffered.last.end;
  }

  /// 是否显示封面，只有在第一次播放前显示
  ///
  /// Whether to show the cover, only before the first play
  @computed
  bool get isShowCover {
    if (cover == null) return false;
    return position == initPosition || position == Duration.zero;
  }

  /// autoplay [false]
  bool autoplay;

  bool looping = false;
  void setLooping(bool loop) {
    this.looping = loop;
    videoCtrl?.setLooping(loop);
  }

  @observable
  double volume;
  @action
  void setVolume(double v) {
    volume = v;
    videoCtrl?.setVolume(v);
  }

  @observable
  bool initialized = false;

  /// Initialize the play position
  Duration initPosition;

  /// Current position
  @observable
  Duration position = Duration.zero;

  /// 视频总时长
  ///
  /// Total video duration
  @observable
  Duration duration = Duration.zero;

  /// 是否显示控制器层
  ///
  /// Whether to show the controller layer
  @observable
  bool controllerLayer = true;
  @action
  void setControllerLayer(bool v) {
    controllerLayer = v;
    if (!v) return;

    if (_controllerLayerTimer?.isActive ?? false) {
      return _controllerLayerTimer?.cancel();
    }

    _controllerLayerTimer = Timer(this.controllerLiveDuration, () {
      // 暂停状态不自动关闭
      // Pause status does not close automatically
      if (_value.isPlaying && controllerLayer) setControllerLayer(false);
    });
  }

  void toggleShowVideoCtrl() => setControllerLayer(!controllerLayer);

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

  @computed
  double get sliderValue {
    if (position == null || duration == null) return 0;
    var r = position.inSeconds / duration.inSeconds;
    return r.isNaN ? 0 : r;
  }

  @computed
  double get sliderBufferValue {
    if (_buffered == null || duration == null) return 0;
    var r = _buffered.inSeconds / duration.inSeconds;
    return r.isNaN ? 0 : r;
  }

  /// 替换当前播放的视频资源
  ///
  /// Replace the currently playing video resource
  @action
  void setSource(VideoPlayerController source) {
    var oldCtrl = videoCtrl;
    Future.delayed(const Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    videoCtrl = source;
  }

  /// 初始化viedo控制器
  ///
  /// Initialize the viedo controller
  @action
  Future<dynamic> initialize([bool isReconnect = false]) async {
    assert(videoCtrl != null);

    if (isReconnect) {
      try {
        await videoCtrl.initialize();
        videoCtrl
          ..seekTo(position)
          ..setLooping(looping)
          ..setVolume(volume)
          ..play()
          ..setPlaybackSpeed(_playbackSpeed);
      } catch (e) {
        if (initializeErrorEventsListenner != null)
          initializeErrorEventsListenner(e);
        return e;
      }
    } else {
      try {
        initialized = false;
        await videoCtrl.initialize();
        videoCtrl.addListener(_videoListenner);
        aspectRatio = _value.aspectRatio;
        initialized = true;
        isBfLoading = false;
        videoCtrl
          ..setLooping(looping)
          ..setVolume(volume);
        if (autoplay) {
          setControllerLayer(false);
          await videoCtrl.play();
        }

        if (initPosition != null && initPosition != Duration.zero)
          seekTo(initPosition);
        position = initPosition ?? _value.position ?? Duration.zero;
        duration = _value.duration ?? Duration.zero;
        updateAnimetedIconState();
      } catch (e) {
        if (initializeErrorEventsListenner != null)
          initializeErrorEventsListenner(e);
        return e;
      }
    }
    return null;
  }

  /// 播放途中解码器被关闭（断网）
  bool get _isNetDisconnect =>
      _value.position == Duration.zero &&
      _value.duration == null &&
      _connectivityStatus == ConnectivityResult.none;

  /// 在极差的网络环境播放视频，可能导致解码器自动关闭(并未断网)
  bool get _isPoorNetwork {
    // 解码器彻底关闭
    if (_value.position == Duration.zero &&
        _value.duration == null &&
        _value.buffered.isEmpty &&
        !_isNetDisconnect &&
        !_value.isPlaying) return true;

    // 解码器关闭边缘...
    if (_value.position.inSeconds == _buffered.inSeconds &&
        !_isNetDisconnect &&
        _value.isPlaying) return true;

    return false;
  }

  /// 视频播放时的监听器
  ///
  /// Listener during video playback
  ///
  /// seek 也会触发
  /// 第一帧也会触发
  /// 网络断开时，不会触发
  /// 视频暂停不会触发
  @action
  void _videoListenner() {
    // printf(
    //   'position(%o), bufferd(%o), duration(%o), _isNetDisconnect(%b), isPlaying(%b)',
    //   _value.position,
    //   _value.buffered.isEmpty ? Duration.zero : _value.buffered.last.end,
    //   _value.duration,
    //   _isNetDisconnect,
    //   _value.isPlaying,
    // );

    if (_isNetDisconnect || _isPoorNetwork) {
      isBfLoading = true;
      _connectivityStatus = ConnectivityResult.none;
      return;
    }

    if (_value.position != Duration.zero) position = _value.position;

    if (_value.isPlaying) {
      isBfLoading = _value.position != null &&
          _value.position != Duration.zero &&
          _buffered == _value.position;
    }

    if (isPlayEnd) {
      isBfLoading = false;
      if (playEndListenner != null) playEndListenner(this);
      setControllerLayer(true);
      updateAnimetedIconState();
    }
  }

  /// 开启声音或关闭
  ///
  /// Turn sound on or off
  void volumeToggle() {
    if (_value == null) return;
    setVolume(_value.volume > 0 ? 0.0 : 1.0);
  }

  /// 播放或暂停
  ///
  /// Play or pause
  Future<void> togglePlay() async {
    var __play = controllerWidgets ? play : videoCtrl.play;
    var __pause = controllerWidgets ? pause : videoCtrl.pause;

    // 等待Icon动画关闭
    // Wait for Icon animation to close
    if (_value.isPlaying) {
      await __pause();
    } else {
      await __play();
    }
  }

  /// 播放
  Future<void> play() async {
    if (isPlayEnd) {
      await seekTo(Duration(seconds: 0));
    }

    await videoCtrl.play();
    updateAnimetedIconState();
    setControllerLayer(false);
  }

  /// 暂停
  Future<void> pause() async {
    await videoCtrl.pause();
    updateAnimetedIconState();
    setControllerLayer(true);
  }

  /// 控制播放时间位置
  ///
  /// Controlling playback time position
  Future<void> seekTo(Duration d) async {
    if (_value.duration != null) {
      await videoCtrl.seekTo(d);
    }
  }

  /// 快进
  void fastForward([Duration st]) {
    if (_value == null) return;
    arrowIconLtRController?.forward();
    seekTo(_value.position + (st ?? skiptime));
  }

  /// 快退
  void rewind([Duration st]) {
    if (_value == null) return;
    arrowIconRtLController?.forward();
    seekTo(_value.position - (st ?? skiptime));
  }

  double _playbackSpeed = 1.0;

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    return videoCtrl.setPlaybackSpeed(speed);
  }

  /// 是否为全屏播放
  ///
  /// Whether to play in full screen
  @observable
  bool isFullScreen = false;

  @action
  void _setFullScreen(bool v) {
    isFullScreen = v;
    if (fullScreenChangeListenner != null)
      fullScreenChangeListenner(this, isFullScreen);
  }

  /// 打开或关闭全屏
  ///
  /// Turn full screen on or off
  Future<void> onFullScreenSwitch(BuildContext context) async {
    if (isFullScreen) {
      customFullScreen.close(context, this);
    } else {
      _setFullScreen(true);
      await customFullScreen.open(context, this);
      _setFullScreen(false);
    }
  }

  void _animatedDispose() {
    animetedIconController?.dispose();
    arrowIconRtLController?.dispose();
    arrowIconLtRController?.dispose();
  }

  void _streamDispose() {
    _streamSubscriptions$?.cancel();
    _connectivityChanged$?.cancel();
  }

  void dispose() {
    _controllerLayerTimer?.cancel();
    _animatedDispose();
    _streamDispose();
    videoCtrl?.dispose();
  }

  VideoState get value => VideoState(
        autoplay: autoplay,
        skiptime: skiptime,
        positionText: positionText,
        durationText: durationText,
        sliderValue: sliderValue,
        initPosition: initPosition,
        dataSource: videoCtrl.dataSource,
        dataSourceType: videoCtrl.dataSourceType,
        size: _value.size,
        isLooping: looping,
        isPlaying: _value.isPlaying,
        volume: volume,
        position: position,
        duration: duration,
        aspectRatio: aspectRatio,
        playbackSpeed: _playbackSpeed,
      );
}
