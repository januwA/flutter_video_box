import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

import 'video_box.dart';
part 'video.store.g.dart';

/// Construction a resources
class VideoDataSource {
  final DataSourceType dataSourceType;
  final String dataSource;
  final String package;

  VideoDataSource.network(this.dataSource)
      : dataSourceType = DataSourceType.network,
        package = null;

  VideoDataSource.file(File file)
      : dataSource = 'file://${file.path}',
        dataSourceType = DataSourceType.file,
        package = null;

  VideoDataSource.asset(this.dataSource, {this.package})
      : dataSourceType = DataSourceType.asset;
}

class VideoStore = _VideoStore with _$VideoStore;

abstract class _VideoStore with Store {
  _VideoStore({
    VideoDataSource videoDataSource,
    this.skiptime = const Duration(seconds: 10),
    this.autoplay = false,
    this.loop = false,
    this.volume = 1.0,
    this.initPosition,
    this.cover,
    this.playingListenner,
    this.playEnd,
  }) {
    initVideoPlaer(videoDataSource);
  }

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
    isBfLoading = videoCtrl.value.position >= videoCtrl.value.buffered[0].end;
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
      Future.delayed(Duration(seconds: 2)).then((_) {
        if (videoCtrl.value.isPlaying && !isBfLoading) {
          showVideoCtrl(false);
        }
      });
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

  @action
  void _videoListenner() {
    position = videoCtrl.value.position;

    _setIsBfLoading();
    if (playingListenner != null) {
      playingListenner();
    }
    if (this.playEnd != null && position >= duration) {
      playEnd();
    }
  }

  @action
  Future<void> setSource(VideoDataSource videoDataSource) async {
    videoCtrl?.pause();
    videoCtrl?.removeListener(_videoListenner);
    var oldCtrl = videoCtrl;
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    await initVideoPlaer(videoDataSource);
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer(VideoDataSource videoDataSource) async {
    setVideoLoading(true);
    if (videoDataSource == null) return;
    DataSourceType dataSourceType = videoDataSource.dataSourceType;
    if (dataSourceType == DataSourceType.network) {
      videoCtrl = VideoPlayerController.network(videoDataSource.dataSource);
    } else if (dataSourceType == DataSourceType.file) {
      videoCtrl = VideoPlayerController.file(File(videoDataSource.dataSource));
    } else if (dataSourceType == DataSourceType.asset) {
      videoCtrl = VideoPlayerController.asset(videoDataSource.dataSource,
          package: videoDataSource.package);
    }
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
    if (videoCtrl.value.isPlaying) {
      videoCtrl.pause();
      isShowVideoCtrl = true;
      if (autoplay) {
        controller.forward();
      } else {
        controller.reverse();
      }
    } else {
      videoCtrl.play();
      if (autoplay) {
        controller.reverse();
      } else {
        controller.forward();
      }
      Future.delayed(Duration(milliseconds: 600)).then((_) {
        isShowVideoCtrl = false;
      });
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
    if (videoCtrl.value.isPlaying) {
      seekTo(videoCtrl.value.position + (st ?? skiptime));
    }
  }

  /// 快退
  void rewind([Duration st]) {
    if (videoCtrl.value.isPlaying) {
      seekTo(videoCtrl.value.position - (st ?? skiptime));
    }
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
                child: VideoBox(
                  store: this,
                ),
              ),
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
