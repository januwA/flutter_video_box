import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show document;
import 'package:flutter/material.dart';
import 'video_box.dart';

class KCustomFullScreen extends CustomFullScreen {
  const KCustomFullScreen();

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
    bool isClose = false;
    late StreamSubscription f;
    document.documentElement!.requestFullscreen();
    f = document.documentElement!.onFullscreenChange.listen((e) {
      if (document.fullscreenElement == null && !isClose) {
        this.close(context, controller);
        f.cancel();
      }
    });

    await Navigator.of(context).push(_route(controller));
    if (document.fullscreenElement != null) {
      isClose = true;
      f.cancel();
      document.exitFullscreen();
    }
    return Null;
  }
}
