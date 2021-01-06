import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'video_box.dart';

class KCustomFullScreen extends CustomFullScreen {
  const KCustomFullScreen();

  /// 设置为横屏模式
  ///
  /// Set to landscape mode
  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /// 设置为正常模式
  ///
  /// Set to normal mode
  void _setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Route<T> _route<T>(VideoController controller) {
    return MaterialPageRoute<T>(
      builder: (_) => KVideoBoxFullScreenPage(controller: controller),
    );
  }

  @override
  void close(BuildContext context, VideoController controller) {
    Navigator.of(context).pop();
  }

  @override
  Future<Object> open(BuildContext context, VideoController controller) async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _setLandscape();
    await Navigator.of(context).push(_route(controller));
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _setPortrait();
    return null;
  }
}
