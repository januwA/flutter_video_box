import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';
import 'package:video_player/video_player.dart';
part 'video.store.g.dart';

class VideoStore = _VideoStore with _$VideoStore;

abstract class _VideoStore with Store {
  _VideoStore({this.src}) {
    initVideoPlaer();
  }

  /// 播放地址
  @observable
  String src;

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
  void videoListenner() {
    position = videoCtrl.value.position;
  }

  /// 初始化viedo控制器
  @action
  Future<void> initVideoPlaer() async {
    if (isNull(src)) return;
    // 尝试关闭上一个video
    videoCtrl?.pause();
    videoCtrl?.setVolume(0.0);

    isVideoLoading = true;
    videoCtrl = VideoPlayerController.network(src);

    await videoCtrl.initialize();

    videoCtrl.setVolume(1.0);
    position = videoCtrl.value.position;
    duration = videoCtrl.value.duration;
    isVideoLoading = false;
    videoCtrl.addListener(videoListenner);
  }

  /// 开启声音或关闭
  void setVolume() {
    if (videoCtrl.value.volume > 0) {
      videoCtrl.setVolume(0.0);
    } else {
      videoCtrl.setVolume(1.0);
    }
  }

  /// 快进
  void seekTo(double v) {
    videoCtrl.seekTo(Duration(seconds: (v * duration.inSeconds).toInt()));
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

  /// 全屏播放切换事件
  onFullScreen() {
    if (isFullScreen) {
      setPortrait();
    } else {
      setLandscape();
    }
  }

  @action
  void setIsFullScreen(bool full) {
    isFullScreen = full;
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

  @override
  void dispose() {
    videoCtrl?.removeListener(videoListenner);
    videoCtrl?.pause();
    videoCtrl?.dispose();
  }
}
