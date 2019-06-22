import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';
import 'package:video_player/video_player.dart';
part 'video.store.g.dart';

class VideoStore = _VideoStore with _$VideoStore;

abstract class _VideoStore with Store {
  _VideoStore({
    this.src,
    this.skiptime = const Duration(seconds: 10),
    this.isAutoplay = false,
    this.isLooping = false,
    this.volume = 1.0,
  }) {
    initVideoPlaer();
  }

  /// 播放地址
  @observable
  String src;

  /// 自动播放 [false]
  @observable
  bool isAutoplay;

  /// 是否循环播放 [false]
  @observable
  bool isLooping;

  /// 音量 [1.0]
  @observable
  double volume;

  @observable
  VideoPlayerController videoCtrl;

  /// 加载视频中...
  @observable
  bool isVideoLoading = true;

  /// 当前anime播放位置
  @observable
  Duration position;

  /// anime总时长
  @observable
  Duration duration;

  /// 是否显示控制器
  @observable
  bool isShowVideoCtrl = true;

  /// 是否为全屏播放
  @observable
  bool isFullScreen = false;

  /// 快进，快退的时间
  @observable
  Duration skiptime;

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
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer() async {
    if (isNull(src)) return;
    isVideoLoading = true;
    videoCtrl = VideoPlayerController.network(src);

    await videoCtrl.initialize();

    videoCtrl.setLooping(isLooping);
    videoCtrl.setVolume(volume);
    if (isAutoplay) {
      videoCtrl.play();
    }
    position = videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    isVideoLoading = false;
    videoCtrl.addListener(_videoListenner);
  }

  /// 开启声音或关闭
  void setVolume() {
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

  @action
  void showVideoCtrl(bool show) {
    isShowVideoCtrl = show;
  }

  /// 设置为横屏模式
  @action
  setLandscape() {
    isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  @action
  setPortrait() {
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

  /// 控制播放时间
  seekTo(Duration d) async {
    if (videoCtrl != null &&
        videoCtrl.value != null &&
        videoCtrl.value.isPlaying) {
      videoCtrl.seekTo(d);
    }
  }

  /// 快进
  fastForward() {
    if (videoCtrl.value.isPlaying) {
      seekTo(videoCtrl.value.position + skiptime);
    }
  }

  /// 快退
  rewind() {
    if (videoCtrl.value.isPlaying) {
      seekTo(videoCtrl.value.position - skiptime);
    }
  }

  @override
  void dispose() {
    videoCtrl?.removeListener(_videoListenner);
    videoCtrl?.pause();
    videoCtrl?.dispose();
    super.dispose();
  }
}
