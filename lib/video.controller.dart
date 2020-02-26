import 'dart:async' show Timer, StreamSubscription;

import 'package:connectivity/connectivity.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobx/mobx.dart';
import 'package:video_player/video_player.dart' show VideoPlayerController;

import 'video_box.dart' show CustomFullScreen, VideoBoxFullScreenPage;
import 'util/duration_string.dart' show durationString;
import 'video_state.dart';

part 'video.controller.g.dart';

typedef FullScreenChange = Function(VideoController controller);
typedef BottomViewBuilder = Widget Function(
    BuildContext context, VideoController controller);

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
    this.looping = false,
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
    this.bottomViewBuilder,
    this.options,
  }) {
    videoCtrl = source;
    this.barrierColor = barrierColor ?? Colors.black.withOpacity(0.6);

    _streamSubscriptions ??=
        accelerometerEvents.listen(_streamSubscriptionsCallback);
    _connectivityChanged$ ??= Connectivity()
        .onConnectivityChanged
        .listen(_connectivityChangedCallBack);
  }

  /// 监听页面旋转流
  StreamSubscription<dynamic> _streamSubscriptions;
  void _streamSubscriptionsCallback(AccelerometerEvent event) {
    if (isFullScreen && event.x.abs() > event.y.abs()) {
      if (event.x > 1) {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft]);
      } else if (event.x < -1) {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeRight]);
      }
    }
  }

  /// 监听网络连接
  ConnectivityResult _connectivityStatus;
  StreamSubscription<ConnectivityResult> _connectivityChanged$;
  void _connectivityChangedCallBack(ConnectivityResult result) {
    if (_connectivityChangedListener != null)
      _connectivityChangedListener(result);
    if (_connectivityStatus == ConnectivityResult.none &&
        result != ConnectivityResult.none &&
        isBfLoading) {
      // 从断网中恢复过来
      // 重新链接解码器
      videoCtrl.initialize().then((_) async {
        // 有些设置需要重新设置
        videoCtrl
          ..seekTo(position) // 跳到上一次断开的位置
          ..setLooping(looping)
          ..setVolume(volume);
        play();
      });
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

  /// 如果您想自定义底部控制器视图，那么可以使用这个api来实施
  ///
  /// 当然，您可能会编写更多的代码，具体的实施可以参考源码的默认实现，或则看下面的Example
  ///
  /// ---
  ///
  /// If you want to customize the bottom controller view, you can use this api to implement
  ///
  /// Of course, you may write more code, the specific implementation can refer to the default implementation of the source code, or see the following Example
  ///
  /// ## bottomViewBuilder Example
  /// ```dart
  /// import 'package:video_player/video_player.dart';
  /// import 'package:video_box/video_box.dart';
  /// import 'package:video_box/video.controller.dart';
  /// import 'package:video_box/widgets/buffer_slider.dart';
  ///
  /// vc = VideoController(
  ///   source: VideoPlayerController.network(src1),
  ///   bottomViewBuilder: (context, c) {
  ///     var theme = Theme.of(context);
  ///     return Positioned(
  ///       left: c.bottomPadding.left,
  ///       bottom: c.bottomPadding.bottom,
  ///       right: c.bottomPadding.right,
  ///       child: Column(
  ///         children: <Widget>[
  ///           Row(
  ///             children: <Widget>[
  ///               Text(
  ///                 c.initialized
  ///                     ? "${c.positionText}/${c.durationText}"
  ///                     : '00:00/00:00',
  ///                 style: TextStyle(color: Colors.white),
  ///               )
  ///             ],
  ///           ),
  ///           Theme(
  ///             data: theme.copyWith(
  ///               sliderTheme: theme.sliderTheme.copyWith(
  ///                 trackHeight: 6, // line的高度
  ///                 overlayShape: SliderComponentShape.noThumb,
  ///               ),
  ///             ),
  ///             child: Padding(
  ///               padding: const EdgeInsets.all(8.0),
  ///               child: BufferSlider(
  ///                 pointWidget: const SizedBox(),
  ///                 value: c.sliderValue,
  ///                 bufferValue: c.sliderBufferValue,
  ///                 onChanged: (double v) => c.seekTo(
  ///                     Duration(seconds: (v * c.duration.inSeconds).toInt())),
  ///               ),
  ///             ),
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   },
  /// );
  /// ```
  final BottomViewBuilder bottomViewBuilder;

  /// icon动画的持续时间
  ///
  /// icon animation duration
  final Duration animetedIconDuration;

  final Color background;
  final Color color;
  final Color bufferColor;
  final Color inactiveColor;
  final Color circularProgressIndicatorColor;

  /// 快进，快退的时间
  ///
  /// Fast forward and rewind time
  final Duration skiptime;

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

  void Function(ConnectivityResult result) _connectivityChangedListener;
  addConnectivityChangedListener(
      void Function(ConnectivityResult result) listener) {
    _connectivityChangedListener = listener;
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
    _setAnimetedIconState();
  }

  Future<void> _setAnimetedIconState() async {
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

  @observable
  bool isBfLoading = false;

  Duration get _buffered {
    var value = videoCtrl.value;
    if (value.buffered?.isEmpty ?? true) return null;
    return value.buffered.last.end;
  }

  /// 随时监听缓冲状态
  ///
  /// Listen to buffer status at any time
  @action
  void _setVideoBuffer() {
    if (_buffered == null) {
      isBfLoading = false;
    } else {
      sliderBufferValue = _buffered.inSeconds / duration.inSeconds;

      /// 当前播放的位置大于了缓冲的位置，就会进入加载状态
      /// The currently playing position is greater than the buffer position, and it will enter the loading state
      var value = videoCtrl.value;
      if (value.isPlaying) {
        isBfLoading = value.position >= _buffered;
      } else {
        isBfLoading = value.position > _buffered;
      }
    }
  }

  /// cover
  ///
  /// 自动居中
  /// Auto-center
  @observable
  Widget cover;

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
  bool autoplay;

  /// Loop [false]
  @observable
  bool looping;

  @action
  void setLooping(bool loop) {
    this.looping = loop;
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
    aspectRatio = videoCtrl.value.aspectRatio;
    videoCtrl
      ..setLooping(looping)
      ..setVolume(volume);
    if (autoplay) {
      setControllerLayer(show: false);
      await videoCtrl.play();
    }

    if (initPosition != null) seekTo(initPosition);
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    videoCtrl.addListener(_videoListenner);
    _setAnimetedIconState();
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
    if (videoCtrl.value.position == Duration.zero &&
        _buffered == null &&
        _connectivityStatus == ConnectivityResult.none) {
      // 播放途中解码器被关闭（断网）
      isBfLoading = true;
      return;
    }
    if (videoCtrl.value.position != Duration.zero)
      position = videoCtrl.value.position;
    if (_playingListenner != null) _playingListenner();
    _setVideoBuffer();

    /// video播放结束
    /// video playback ends
    /// 如果loop: true则不会走到这一步
    if (isPlayEnd) {
      isBfLoading = false;

      /// 如果用户调用了播放结束的监听器
      if (this._playEnd != null) _playEnd();
      setControllerLayer(show: true);
      _setAnimetedIconState();
    }
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
    _setAnimetedIconState();
  }

  /// 播放
  Future<void> play() async {
    if (isPlayEnd) {
      await videoCtrl.seekTo(Duration(seconds: 0));
    }

    if (!videoCtrl.value.isPlaying) {
      await videoCtrl.play();
      _setAnimetedIconState();
      setControllerLayer(show: false);
    }
  }

  /// 暂停
  Future<void> pause() async {
    if (videoCtrl.value.isPlaying) {
      await videoCtrl.pause();
      _setAnimetedIconState();
      setControllerLayer(show: true);
    }
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

  Future<void> dispose() async {
    animetedIconController?.dispose();
    videoCtrl?.removeListener(_videoListenner);
    await videoCtrl?.pause();
    await videoCtrl?.dispose();
    _controllerLayerTimer?.cancel();
    _streamSubscriptions?.cancel();
    _connectivityChanged$?.cancel();
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
