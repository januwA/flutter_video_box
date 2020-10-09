import 'package:connectivity/connectivity.dart';
import 'package:sensors/sensors.dart' show AccelerometerEvent;

import '../video.controller.dart';

typedef TPlayingListenner = void Function(VideoController controller);
typedef TPlayEndListenner = void Function(VideoController controller);
typedef TFullScreenChangeListenner = void Function(
    VideoController controller, bool isFullScreen);
typedef TConnectivityChangedListenner = void Function(
    VideoController controller, ConnectivityResult result);

typedef TAccelerometerEventsListenner = void Function(
    VideoController controller, AccelerometerEvent event);

typedef TLnitializeErrorEventsListenner = void Function(dynamic error);

/// 各种监听事件
mixin VideoListennerMixin on BaseVideoController {
  /// 监听video播放结束事件
  TPlayEndListenner playEndListenner;

  /// 监听屏幕改变(开启/关闭全屏)事件
  TFullScreenChangeListenner fullScreenChangeListenner;

  /// 监听网络变更事件
  TConnectivityChangedListenner connectivityChangedListenner;

  // 屏幕旋转事件
  TAccelerometerEventsListenner accelerometerEventsListenner;

  addConnectivityChangedListener(TConnectivityChangedListenner listener) {
    connectivityChangedListenner = listener;
  }

  addPlayEndListener(TPlayEndListenner listener) => playEndListenner = listener;
  addFullScreenChangeListener(TFullScreenChangeListenner listener) =>
      fullScreenChangeListenner = listener;

  addAccelerometerEventsListenner(TAccelerometerEventsListenner listener) {
    accelerometerEventsListenner = listener;
  }

  /// initialize 初始化错误时
  TLnitializeErrorEventsListenner initializeErrorEventsListenner;
  addInitializeErrorListenner(TLnitializeErrorEventsListenner listener) {
    initializeErrorEventsListenner = listener;
  }

  void addListener(void Function() listener) {
    videoCtrl.addListener(listener);
  }

  void removeListener(void Function() listener) {
    videoCtrl.removeListener(listener);
  }
}
