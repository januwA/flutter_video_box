import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'globals.dart';

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl>
    with SingleTickerProviderStateMixin {
  VideoController vc;

  @override
  void initState() {
    super.initState();
    vc = VideoController(
      source: VideoPlayerController.network(src1),
      autoplay: true,
      loop: true,
      // initPosition: Duration(minutes: 20),
      cover: Text(
        'cover',
        style: TextStyle(color: Colors.white),
      ),
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
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(
              controller: vc,
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
