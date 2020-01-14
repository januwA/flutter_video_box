import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import '../globals.dart';

class MyFullScreen implements CustomFullScreen {
  @override
  void close(BuildContext context, VideoController controller) {
    Navigator.of(context).pop(controller.value.positionText);
  }

  @override
  Future open(BuildContext context, VideoController controller) async {
    setLandscape();
    SystemChrome.setEnabledSystemUIOverlays([]);
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            body: Center(child: VideoBox(controller: controller)),
          );
        },
      ),
    ).then(print);
    setPortrait();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl> {
  VideoController vc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    vc = VideoController(
      source: VideoPlayerController.network(src1),
      looping: true,
      autoplay: true,
      color: Colors.red,
      bufferColor: Colors.orange,
      inactiveColor: Colors.pink,
      background: Colors.indigo,
      circularProgressIndicatorColor: Colors.lime,
      bottomPadding: EdgeInsets.only(bottom: 10),
      customLoadingWidget: Center(
        child: Container(
          color: Colors.pink,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text("Lading..."),
            ],
          ),
        ),
      ),
      customBufferedWidget: Center(
        child: Container(
          color: Colors.pink,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text("please wait..."),
            ],
          ),
        ),
      ),
      customFullScreen: MyFullScreen(),
      // cover: Image.network('https://i.loli.net/2019/08/29/7eXVLcHAhtO9YQg.jpg'),
      // controllerWidgets: false,
      // cover: Text('Cover'),
      // initPosition: Duration(minutes: 23, seconds: 50)
    )
      ..addFullScreenChangeListener((c) async {})
      ..initialize().then((_) {
        // initialized
      });
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('one video ctrl'),
      ),
      body: ListView(
        controller: controller,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(
              controller: vc,
              children: <Widget>[
                Align(
                  alignment: Alignment(0.5, 0),
                  child: IconButton(
                    iconSize: VideoBox.centerIconSize,
                    disabledColor: Colors.white60,
                    icon: Icon(Icons.skip_next),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                child: Text('play'),
                onPressed: () {
                  vc.play();
                },
              ),
              RaisedButton(
                child: Text('pause'),
                onPressed: () {
                  vc.pause();
                },
              ),
              RaisedButton(
                child: Text('full screen'),
                onPressed: () {
                  vc.onFullScreenSwitch(context);
                },
              ),
              RaisedButton(
                child: Text('print'),
                onPressed: () {
                  print(vc);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
