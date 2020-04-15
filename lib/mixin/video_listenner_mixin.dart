import 'package:connectivity/connectivity.dart';

import '../video.controller.dart';

typedef TPlayingListenner = void Function(VideoController controller);
typedef TPlayEndListenner = void Function(VideoController controller);
typedef TFullScreenChangeListenner = void Function(
    VideoController controller, bool isFullScreen);
typedef TConnectivityChangedListenner = void Function(
    VideoController controller, ConnectivityResult result);

/// 各种监听事件
mixin VideoListennerMixin on BaseVideoController {
  /// 监听video播放结束事件
  TPlayEndListenner playEndListenner;

  /// 监听屏幕改变事件
  TFullScreenChangeListenner fullScreenChangeListenner;

  /// 监听网络变更事件
  TConnectivityChangedListenner connectivityChangedListenner;

  addConnectivityChangedListener(TConnectivityChangedListenner listener) {
    connectivityChangedListenner = listener;
  }

  addPlayEndListener(TPlayEndListenner listener) => playEndListenner = listener;
  addFullScreenChangeListener(TFullScreenChangeListenner listener) =>
      fullScreenChangeListenner = listener;

  addListener(TPlayingListenner listener) {
    videoCtrl?.addListener(() => listener(this));
  }
}
