import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:video_player/video_player.dart';
part 'video.store.g.dart';

/// 构造资源的类
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
    this.isAutoplay = false,
    this.isLooping = false,
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

  /// 播放完毕
  Function playEnd;

  /// 封面
  @observable
  Widget cover;

  /// 设置封面
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

  /// 自动播放 [false]
  @observable
  bool isAutoplay;

  /// set  [isAutoplay]
  @action
  void setIsAutoplay(bool autoplay) {
    isAutoplay = autoplay;
  }

  /// 是否循环播放 [false]
  @observable
  bool isLooping;

  @action
  void setIsLooping(bool loop) {
    isLooping = loop;
    videoCtrl?.setLooping(loop);
  }

  /// 音量 [1.0]
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

  /// 加载 VideoPlayerController中
  @observable
  bool isVideoLoading = true;

  /// 初始化播放位置
  @observable
  Duration initPosition;

  /// set [initPosition]
  @action
  void setInitPosition(Duration p) {
    initPosition = p;
  }

  /// 当前anime播放位置
  @observable
  Duration position;

  /// anime总时长
  @observable
  Duration duration;

  /// 是否显示控制器
  @observable
  bool isShowVideoCtrl = true;

  /// set [isShowVideoCtrl]
  @action
  void showVideoCtrl(bool show) {
    isShowVideoCtrl = show;
    if (show && videoCtrl.value.isPlaying) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        if (videoCtrl.value.isPlaying) {
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
    if (playingListenner != null) {
      playingListenner();
    }
    if (this.playEnd != null && position >= duration) {
      playEnd();
    }
  }

  @action
  void setSource([VideoDataSource videoDataSource]) {
    videoCtrl?.pause();
    videoCtrl?.removeListener(_videoListenner);
    var oldCtrl = videoCtrl;

    /// 延迟一秒清理资源
    /// 如果以后出现 `Once you have called dispose() on a VideoPlayerController, it can no longer be used.`
    /// 我将保留资源，并删除下面这段代码
    Future.delayed(Duration(seconds: 1)).then((_) => oldCtrl?.dispose());
    initVideoPlaer(videoDataSource);
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer(VideoDataSource videoDataSource) async {
    isVideoLoading = true;
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
    videoCtrl.setLooping(isLooping);
    videoCtrl.setVolume(volume);
    if (isAutoplay) {
      videoCtrl.play();
    }
    if (initPosition != null) {
      seekTo(initPosition);
    }
    position = initPosition ?? videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    isVideoLoading = false;
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

  /// 播放或暂停
  @action
  void togglePlay() {
    if (videoCtrl.value.isPlaying) {
      videoCtrl.pause();
      isShowVideoCtrl = true;
    } else {
      videoCtrl.play();
      isShowVideoCtrl = false;
    }
  }

  /// 设置为横屏模式
  @action
  void setLandscape() {
    isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  @action
  void setPortrait() {
    isFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
      isAutoplay: isAutoplay,
      isLooping: isLooping,
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
      "isAutoplay": isAutoplay,
      "isLooping": isLooping,
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
    this.isLooping,
    this.isAutoplay,
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
  bool isAutoplay;
  bool isLooping;
  double volume;
  Duration initPosition;
  Duration position;
  Duration duration;
  Duration skiptime;
  String positionText;
  String durationText;
  double sliderValue;
}
