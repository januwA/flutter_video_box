import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

import 'video_box.dart';
part 'video.store.g.dart';

class VideoStore = _VideoStore with _$VideoStore;

abstract class _VideoStore with Store {
  _VideoStore({
    VideoPlayerController source,
    this.skiptime = const Duration(seconds: 10),
    this.autoplay = false,
    this.loop = false,
    this.volume = 1.0,
    this.initPosition,
    this.cover,
    this.playingListenner,
    this.playEnd,
  }) {
    initVideoPlaer(source);
  }

  @observable
  bool isPlayEnd = false;

  /// 自动关闭 videoCtrl 的计时器
  Timer _showCtrlTimer;

  /// 用户可以发送一个callback的函数进来，video播放时触发
  Function playingListenner;

  /// Played out
  Function playEnd;

  /// cover
  @observable
  Widget cover;

  @observable
  bool isBfLoading = false;

  @action
  void _setIsBfLoading() {
    if (videoCtrl.value.buffered == null || videoCtrl.value.buffered.isEmpty)
      return;

    /// 当前播放的位置，大于了缓冲的位置，就会进入加载状态
    isBfLoading = videoCtrl.value.position >= videoCtrl.value.buffered.last.end;
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
    if (show && videoCtrl.value.isPlaying) {
      if (_showCtrlTimer?.isActive ?? false) {
        _showCtrlTimer?.cancel();
      } else {
        _showCtrlTimer = Timer(Duration(seconds: 2), () {
          isShowVideoCtrl = false;
          if (videoCtrl.value.isPlaying && !isBfLoading) {
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
    return duration == null
        ? ''
        : duration
            .toString()
            .split('.')
            .first
            .split(':')
            .where((String e) => e != '0')
            .toList()
            .join(':');
  }

  /// 00:01 当前时间
  @computed
  String get positionText {
    return (videoCtrl == null)
        ? ''
        : position
            .toString()
            .split('.')
            .first
            .split(':')
            .where((String e) => e != '0')
            .toList()
            .join(':');
  }

  @computed
  double get sliderValue {
    if (position?.inSeconds != null && duration?.inSeconds != null) {
      return position.inSeconds / duration.inSeconds;
    } else {
      return 0.0;
    }
  }

  /// 视频播放时的监听器
  @action
  void _videoListenner() {
    position = videoCtrl.value.position;

    _setIsBfLoading();
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
    videoCtrl?.pause();
    videoCtrl?.removeListener(_videoListenner);
    var oldCtrl = videoCtrl;
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    await initVideoPlaer(videoDataSource);
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer(VideoPlayerController videoDataSource) async {
    setVideoLoading(true);
    isBfLoading = false;
    if (videoDataSource == null) return;
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
    setVideoLoading(false);
    videoCtrl.addListener(_videoListenner);
  }

  /// 开启声音或关闭
  void setOnSoundOrOff() {
    if (videoCtrl.value.volume > 0) {
      videoCtrl.setVolume(0.0);
    } else {
      videoCtrl.setVolume(1.0);
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
  void togglePlay(AnimationController controller) {
    assert(isShowVideoCtrl == true);
    if (!isShowVideoCtrl) return;

    if (videoCtrl.value.isPlaying) {
      videoCtrl.pause();
      isShowVideoCtrl = true;
      controller.reverse();
    } else {
      /// 如果视频播放结束
      /// 再点击播放则重头开始播放
      if (isPlayEnd) {
        videoCtrl.seekTo(Duration(seconds: 0));
      }
      videoCtrl.play();
      controller.forward();

      /// 避免闪烁
      if (_showCtrlTimer?.isActive ?? false) {
        _showCtrlTimer?.cancel();
      } else {
        _showCtrlTimer = Timer(Duration(seconds: 2), () {
          isShowVideoCtrl = false;
        });
      }
    }
  }

  /// 播放
  @action
  void play() {
    videoCtrl.play();
    isShowVideoCtrl = false;
  }

  /// 暂停
  @action
  void pause() {
    videoCtrl.pause();
    isShowVideoCtrl = true;
  }

  /// 控制播放时间位置
  @action
  Future<void> seekTo(Duration d) async {
    if (videoCtrl != null && videoCtrl.value != null) {
      videoCtrl.seekTo(d);
      _setIsBfLoading();
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

  Future<void> onFullScreen(context) async {
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
          builder: (_) => SafeArea(
            child: Scaffold(
              body: Center(
                child: VideoBox(store: this),
              ),
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );
      _setPortrait();
      Screen.keepOn(false);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

  @override
  Future<void> dispose() async {
    videoCtrl?.removeListener(_videoListenner);
    await videoCtrl?.pause();
    await videoCtrl?.dispose();
    super.dispose();
  }

  VideoState toJson() {
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
