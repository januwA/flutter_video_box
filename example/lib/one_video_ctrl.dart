import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

import 'globals.dart';

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl>
    with SingleTickerProviderStateMixin {
  Video video;
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    video = Video(
      store: VideoStore(
        videoDataSource: VideoDataSource.network(src1),
        // autoplay: true,
        // initPosition: Duration(minutes: 20),
        cover: Text(
          'cover',
          style: TextStyle(color: Colors.white),
        ),
        loop: true,
      ),
    );
  }

  @override
  void dispose() {
    video.dispose();
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
          video.videoBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('play'),
                onPressed: () {
                  // video.store.videoCtrl.play();
                  video.store.play();
                },
              ),
              RaisedButton(
                child: Text('pause'),
                onPressed: () {
                  // video.store.videoCtrl.pause();
                  video.store.pause();
                },
              ),
              RaisedButton(
                child: Text('full screen'),
                onPressed: () {
                  video.store.onFullScreen(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
