import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
// import 'package:flutter_android_pip/flutter_android_pip.dart';

import '../globals.dart';

class PipPage extends StatefulWidget {
  @override
  _PipPageState createState() => _PipPageState();
}

class _PipPageState extends State<PipPage> with WidgetsBindingObserver {
  VideoController vc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    vc = VideoController(
      source: VideoPlayerController.network(src1),
    )..initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    vc?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('应用程序可见并响应用户输入。');
        break;
      case AppLifecycleState.inactive:
        print('应用程序处于非活动状态，并且未接收用户输入');
        // click home
        if (vc != null && vc.value.isPlaying) {
          // FlutterAndroidPip.enterPictureInPictureMode;
        }
        break;
      case AppLifecycleState.paused:
        print('用户当前看不到应用程序，没有响应');
        break;
      case AppLifecycleState.detached:
        print('应用程序将暂停。');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(controller: vc),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  for (var i = 0; i < 20; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40,
                        color: Colors.brown,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
