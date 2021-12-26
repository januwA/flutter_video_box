import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'KCustomFullScreen_io.dart';
import '_util.dart';

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
  });

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

  @override
  void dispose() {
    super.dispose();
    vpc.dispose();
  }
}
