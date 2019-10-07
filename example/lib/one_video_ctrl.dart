import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'globals.dart';

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl> {
  VideoController vc;
  bool get isPlay => vc.videoCtrl.value.isPlaying;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    vc = VideoController(
      source: VideoPlayerController.network(src1),
      // cover: Image.network('https://i.loli.net/2019/08/29/7eXVLcHAhtO9YQg.jpg'),
      // controllerWidgets: false,
      // cover: Text('Cover'),
    );
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
              barrierColor: Colors.green.withOpacity(0.4),
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
                  vc.onFullScreen(
                    context,
                    SafeArea(
                      child: Scaffold(
                        body: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: VideoBox(controller: vc),
                          ),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              RaisedButton(
                child: Text('print'),
                onPressed: () {
                  print(vc.toMap());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
