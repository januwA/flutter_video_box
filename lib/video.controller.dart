import 'dart:async' show StreamSubscription, Timer;

import 'package:connectivity/connectivity.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobx/mobx.dart';
import 'package:video_box/mixin/animation_icon_mixin.dart';
import 'package:video_player/video_player.dart'
    show DataSourceType, VideoPlayerController;

import 'util.dart';
import 'mixin/custom_view_mixin.dart';
import 'mixin/video_listenner_mixin.dart';
import 'video_box.dart' show CustomFullScreen, KCustomFullScreen;
import 'video_state.dart';

part 'video.controller.g.dart';

extension VideoPlayerControllerExtensions on VideoPlayerController {
  VideoPlayerController copyWith() {
    switch (dataSourceType) {
      case DataSourceType.network:
        return VideoPlayerController.network(
          dataSource,
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
        );
      case DataSourceType.asset:
        return VideoPlayerController.asset(
          dataSource,
          package: package,
          closedCaptionFile: closedCaptionFile,
        );
      default:
        throw '其他不支持!!';
    }
  }
}

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

class BaseVideoController {
  VideoPlayerController videoCtrl;
  Duration animetedIconDuration;
}

abstract class _VideoController extends BaseVideoController
    with Store, VideoListennerMixin, CustomViewMixin, AnimationIconMixin {
  @action
  _VideoController({
    VideoPlayerController source,
    this.skiptime = const Duration(seconds: 10),
    this.autoplay = false,
    this.looping = false,
    this.volume = 1.0,
    this.initPosition = const Duration(seconds: 0),
    this.cover,
    this.controllerWidgets = true,
    this.controllerLiveDuration = const Duration(seconds: 2),
    this.controllerLayerDuration = kTabScrollDuration,
    this.animetedIconDuration = kTabScrollDuration,
    this.options,
    EdgeInsets bottomPadding,
    Color background,
    Color color,
    Color bufferColor,
    Color inactiveColor,
    Color circularProgressIndicatorColor,
    Color barrierColor,
    Widget customLoadingWidget,
    Widget customBufferedWidget,
    CustomFullScreen customFullScreen,
    BottomViewBuilder bottomViewBuilder,
  }) {
    videoCtrl = source;
    this.barrierColor = barrierColor ?? Colors.black.withOpacity(0.6);
    this.customLoadingWidget = customLoadingWidget;
    this.customBufferedWidget = customBufferedWidget;
    this.customFullScreen = customFullScreen ?? const KCustomFullScreen();
    this.bottomViewBuilder = bottomViewBuilder;
    this.background = background ?? Colors.black;
    this.color = color ?? Colors.white;
    this.bufferColor = bufferColor ?? Colors.white38;
    this.inactiveColor = inactiveColor ?? Colors.white24;
    this.circularProgressIndicatorColor =
        circularProgressIndicatorColor ?? Colors.white;
    this.bottomPadding = bottomPadding ?? EdgeInsets.zero;
    if (this.accelerometerEventsListenner == null)
      addAccelerometerEventsListenner(kAccelerometerEventsListenner);
    _initStreams();
  }

  @override
  VideoPlayerController videoCtrl;

  bool _isDispose = false;

  /// 初始化所有需要的流
  _initStreams() {
    _streamSubscriptions$ ??=
        accelerometerEvents.listen(_streamSubscriptionsCallback);
    _connectivityChanged$ ??= Connectivity()
        .onConnectivityChanged
        .listen(_connectivityChangedCallBack);
  }

  /// 监听页面旋转流
  StreamSubscription<dynamic> _streamSubscriptions$;
  void _streamSubscriptionsCallback(AccelerometerEvent event) =>
      accelerometerEventsListenner(this, event);

  /// 监听网络连接
  ConnectivityResult _connectivityStatus;
  StreamSubscription<ConnectivityResult> _connectivityChanged$;
  void _connectivityChangedCallBack(ConnectivityResult result) {
    // 如果我关闭wifi，那么网络变化将是 none -> mobile
    // 当重新开启wifi，将会打印两次wifi
    // print(result);

    if (connectivityChangedListenner != null)
      connectivityChangedListenner(this, result);

    bool isReconnection = _connectivityStatus == ConnectivityResult.none &&
        result != ConnectivityResult.none &&
        isBfLoading &&
        videoCtrl.value.buffered.isEmpty;
    if (isReconnection) {
      // 从断网中恢复过来, 重新连接解码器
      // 可能出现BUG，没经过严格测试
      setSource(videoCtrl.copyWith());
      videoCtrl
          .initialize()
          .then((_) => videoCtrl.seekTo(position ?? Duration.zero))
          .then((_) => videoCtrl
            ..addListener(_videoListenner)
            ..setLooping(looping)
            ..setVolume(volume))
          .then((_) => play());
    }

    _connectivityStatus = result;
  }

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

  @observable
  double aspectRatio;
  @action
  void setAspectRatio(double v) => aspectRatio = v;

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

  /// 控制器背景色
  ///
  /// Controller background color
  @observable
  Color barrierColor;
  @action
  void setBarrierColor(Color v) => barrierColor = v;

  bool get isPlayEnd => position >= duration;

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
    var value = videoCtrl.value;
    if (value.buffered?.isEmpty ?? true) return null;
    // 经过我的测试发现这个buffered数组的length，总是为1
    // print('buffered length: ' + value.buffered.length.toString());

    // range的start也总是 0
    return value.buffered.last.end;
  }

  /// 随时监听缓冲状态
  ///
  /// Listen to buffer status at any time
  @action
  void _setVideoBuffer() {
    if (_buffered == null) {
      isBfLoading = false;
      return;
    }

    _setSliderBufferValue();

    /// 当前播放的位置大于了缓冲的位置，就会进入加载状态
    /// The currently playing position is greater than the buffer position, and it will enter the loading state
    // 这里判断了下，是否在播放状态
    // 如果在暂停途中改变了进度条，那么position是和_buffered相等的
    // 暂停状态下，不做处理
    if (videoCtrl.value.isPlaying) {
      isBfLoading = _buffered <= videoCtrl.value.position;
    }
  }

  /// cover
  @observable
  Widget cover;
  @action
  void setCover(Widget v) => cover = v;

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
  double volume = 1.0;
  @action
  void setVolume(double v) {
    volume = v;
    videoCtrl?.setVolume(v);
  }

  bool get _hasCtrlValue => videoCtrl.value != null;

  @observable
  bool initialized = false;

  /// Initialize the play position
  Duration initPosition;

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
      if (videoCtrl.value.isPlaying) setControllerLayer(false);
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
  double get sliderValue =>
      (position?.inSeconds != null && duration?.inSeconds != null)
          ? position.inSeconds / duration.inSeconds
          : 0.0;

  @observable
  double sliderBufferValue = 0.0;

  @action
  void _setSliderBufferValue() {
    if (_buffered == null) return;
    sliderBufferValue = _buffered.inSeconds / duration.inSeconds;
  }

  /// 替换当前播放的视频资源
  ///
  /// Replace the currently playing video resource
  @action
  void setSource(VideoPlayerController source) {
    var oldCtrl = videoCtrl;
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
    if (_isDispose) return; // 尽可能避免调用[dispose]还继续初始化的情况
    initialized = false;
    isBfLoading = false;
    await videoCtrl.initialize();
    aspectRatio = videoCtrl.value.aspectRatio;
    videoCtrl
      ..setLooping(looping)
      ..setVolume(volume);
    if (autoplay) {
      setControllerLayer(false);
      await videoCtrl.play();
    }

    if (initPosition != null) seekTo(initPosition);
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    videoCtrl.addListener(_videoListenner);
    updateAnimetedIconState();
    initialized = true;
  }

  /// 播放途中解码器被关闭（断网）
  bool get _isNetDisconnect =>
      videoCtrl.value.position == Duration.zero &&
      _buffered == null &&
      _connectivityStatus == ConnectivityResult.none;

  /// 视频播放时的监听器
  ///
  /// Listener during video playback
  ///
  /// seek 也会触发
  /// 第一帧也会触发
  /// 网络断开时，不会触发
  @action
  void _videoListenner() {
    if (_isNetDisconnect) {
      isBfLoading = true;
      return;
    }
    if (videoCtrl.value.position != Duration.zero)
      position = videoCtrl.value.position;
    _setVideoBuffer();

    _videoPlayEndListenner();
  }

  void _videoPlayEndListenner() {
    /// video播放结束
    /// video playback ends
    /// 如果looping: true则不会走到这一步
    if (isPlayEnd) {
      isBfLoading = false;
      if (playEndListenner != null) playEndListenner(this);
      setControllerLayer(true);
      updateAnimetedIconState();
    }
  }

  addListener(TPlayingListenner listener) {
    videoCtrl.addListener(() => listener(this));
  }

  /// 开启声音或关闭
  ///
  /// Turn sound on or off
  void setOnSoundOrOff() {
    if (!_hasCtrlValue) return;
    double v = videoCtrl.value.volume > 0 ? 0.0 : 1.0;
    setVolume(v);
  }

  /// 播放或暂停
  ///
  /// Play or pause
  Future<void> togglePlay() async {
    var __play = controllerWidgets ? play : videoCtrl.play;
    var __pause = controllerWidgets ? pause : videoCtrl.pause;

    // 等待Icon动画关闭
    // Wait for Icon animation to close
    if (videoCtrl.value.isPlaying) {
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
  Future<void> seekTo(Duration d) => videoCtrl.seekTo(d);

  /// 快进
  void fastForward([Duration st]) {
    if (!_hasCtrlValue) return;
    arrowIconLtRController?.forward();
    seekTo(videoCtrl.value.position + (st ?? skiptime));
  }

  /// 快退
  void rewind([Duration st]) {
    if (!_hasCtrlValue) return;
    arrowIconRtLController?.forward();
    seekTo(videoCtrl.value.position - (st ?? skiptime));
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
    _isDispose = true;
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
        size: videoCtrl.value.size,
        isLooping: videoCtrl.value.isLooping,
        isPlaying: videoCtrl.value.isPlaying,
        volume: videoCtrl.value.volume,
        position: videoCtrl.value.position,
        duration: videoCtrl.value.duration,
        aspectRatio: videoCtrl.value.aspectRatio,
      );

  @override
  String toString() => value.toString();
}
