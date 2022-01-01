import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'KCustomFullScreen_io.dart';
import '_util.dart';
import 'video_state.dart';

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

typedef TAccelerometerEventsListenner = void Function(
    VideoController controller, AccelerometerEvent event);

class UI {
  final VideoController controller;
  const UI(this.controller);

  get timeText => controller.vpc.value.isInitialized
      ? "${controller.positionText}/${controller.durationText}"
      : '00:00/00:00';

  IconData get volumeIcon {
    var volume = controller.vpc.value.volume;
    return volume <= 0
        ? Icons.volume_off
        : volume <= 0.5
            ? Icons.volume_down
            : Icons.volume_up;
  }

  IconData get screenIcon =>
      controller.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen;

  Widget get bgWidth => controller.bg ?? Container(color: Colors.black);
}

class VideoController extends ChangeNotifier {
  late VideoPlayerController vpc;
  late CustomFullScreen customFullScreen;
  late Duration controlsDuration;
  late Duration controlsLiveDuration;
  late Duration playIconDuration;
  late double playIconSize;
  late Duration arrowIconDuration;
  late Widget laodingWidget;
  late Duration skiptime;
  ThemeData? theme;
  Color? controlsBg;
  Widget? bg;
  List<Widget>? children;
  Animation<double>? playIconTween;
  AnimationController? arrowIconLtRController;
  AnimationController? arrowIconRtLController;
  AnimationController? playIconController;
  late UI ui;

  VideoController({
    required this.vpc,
    this.customFullScreen = const KCustomFullScreen(),
    this.controlsDuration = const Duration(milliseconds: 800),
    this.controlsLiveDuration = const Duration(seconds: 2),
    this.playIconDuration = const Duration(milliseconds: 300),
    this.playIconSize = 40.0,
    this.arrowIconDuration = const Duration(milliseconds: 300),
    this.skiptime = const Duration(seconds: 10),
    this.laodingWidget = const Center(child: CircularProgressIndicator()),
    this.controlsBg,
    this.bg,
    this.theme,
  }) {
    ui = UI(this);

    _accelerometerEventsSubscriptions$ ??=
        accelerometerEvents.listen(_streamSubscriptionsCallback);
    _connectivityChanged$ ??= Connectivity()
        .onConnectivityChanged
        .listen(_connectivityChangedCallBack);
  }

  /// 监听页面旋转流
  TAccelerometerEventsListenner accelerometerEventsListenner =
      kAccelerometerEventsListenner;
  StreamSubscription<dynamic>? _accelerometerEventsSubscriptions$;
  void _streamSubscriptionsCallback(AccelerometerEvent event) =>
      accelerometerEventsListenner(this, event);

  /// 监听网络连接
  ConnectivityResult? _connectivityStatus;
  StreamSubscription<ConnectivityResult>? _connectivityChanged$;
  void _connectivityChangedCallBack(ConnectivityResult result) {
    bool isReconnection = _connectivityStatus == ConnectivityResult.none &&
        result != ConnectivityResult.none &&
        _value.isBuffering &&
        _value.buffered.isEmpty;
    if (isReconnection) {
      // 从断网中恢复过来, 重新连接解码器
      // 所有事件监听器不会被移除
      // initialize(true);
    }

    _connectivityStatus = result;
  }

  /// 动画icon的初始化
  ///
  /// Initialization of the animation icon
  void initAnimetedIconController(TickerProvider vsync) {
    arrowIconLtRController = AnimationController(
      duration: arrowIconDuration,
      vsync: vsync,
    );

    arrowIconRtLController = AnimationController(
      duration: arrowIconDuration,
      vsync: vsync,
    );

    playIconController = AnimationController(
      duration: playIconDuration,
      vsync: vsync,
    );
    playIconTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(playIconController!);
    updateAnimetedIconState();
  }

  Future<void> updateAnimetedIconState() async {
    // ignore: unnecessary_null_comparison
    if (playIconController == null) return;
    if (vpc.value.isPlaying) {
      await playIconController!.forward();
    } else {
      await playIconController!.reverse();
    }
  }

  Future<void> initialize() async {
    await vpc.initialize();
  }

  VideoPlayerValue get _value => vpc.value;

  /// 25:00 or 2:00:00 总时长
  ///
  /// Total duration
  // ignore: unnecessary_null_comparison
  String get durationText => durationString(_value.duration);

  /// 00:01 当前时间
  ///
  /// current time
  String get positionText => durationString(_value.position);

  double get sliderValue {
    var r = _value.position.inSeconds / _value.duration.inSeconds;
    return r.isNaN ? 0 : r;
  }

  Duration get _buffered {
    if (_value.buffered.isEmpty) return Duration.zero;
    return _value.buffered.last.end;
  }

  double get sliderBufferValue {
    var r = _buffered.inSeconds / _value.duration.inSeconds;
    return r.isNaN ? 0 : r;
  }

  bool get isShowLoading => !_value.isInitialized || _value.isBuffering;

  /// 开启声音或关闭
  ///
  /// Turn sound on or off
  void volumeToggle() {
    vpc.setVolume(_value.volume > 0 ? 0.0 : 1.0);

    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_value.isPlaying) {
      await pause();
    } else {
      await play();
    }
    updateAnimetedIconState();
  }

  EdgeInsets bottomPadding = const EdgeInsets.only(bottom: 10);

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;

  /// 打开或关闭全屏
  ///
  /// Turn full screen on or off
  Future<void> fullScreenToggle(BuildContext context) async {
    if (isFullScreen) {
      customFullScreen.close(context, this);
    } else {
      _isFullScreen = true;
      notifyListeners();
      await customFullScreen.open(context, this);
      _isFullScreen = false;
      notifyListeners();
    }
  }

  Timer? _controlsTimer;
  bool _controls = true;
  bool get controls => _controls;
  void setControls(bool v) {
    _controls = v;
    notifyListeners();
    if (!v) return;

    if (_controlsTimer?.isActive ?? false) {
      return _controlsTimer?.cancel();
    }

    _controlsTimer = Timer(controlsLiveDuration, () {
      // 暂停状态不自动关闭
      // Pause status does not close automatically
      if (_value.isPlaying && controls) setControls(false);
    });
  }

  void controlsToggle() => setControls(!controls);

  bool get isPlayEnd => (_value.position) >= (_value.duration);

  /// 播放
  Future<void> play() async {
    if (isPlayEnd) {
      await vpc.seekTo(const Duration(seconds: 0));
    }

    await vpc.play();
    updateAnimetedIconState();
    setControls(false);
  }

  /// 暂停
  Future<void> pause() async {
    await vpc.pause();
    updateAnimetedIconState();
    setControls(true);
  }

  /// 快进
  void fastForward([Duration? st]) {
    arrowIconLtRController?.forward();
    vpc.seekTo(_value.position + (st ?? skiptime));
  }

  /// 快退
  void rewind([Duration? st]) {
    arrowIconRtLController?.forward();
    vpc.seekTo(_value.position - (st ?? skiptime));
  }

  void _animatedDispose() {
    playIconController?.dispose();
    arrowIconRtLController?.dispose();
    arrowIconLtRController?.dispose();
  }

  void _streamDispose() {
    _accelerometerEventsSubscriptions$?.cancel();
    _connectivityChanged$?.cancel();
  }

  @override
  void dispose() {
    super.dispose();

    _controlsTimer?.cancel();
    _animatedDispose();
    _streamDispose();
    vpc.dispose();
  }

  VideoState get value => VideoState(
        skiptime: skiptime,
        positionText: positionText,
        durationText: durationText,
        sliderValue: sliderValue,
        dataSource: vpc.dataSource,
        dataSourceType: vpc.dataSourceType,
        size: _value.size,
        isPlaying: _value.isPlaying,
        volume: _value.volume,
        position: _value.position,
        duration: _value.duration,
        playbackSpeed: _value.playbackSpeed,
      );
}
