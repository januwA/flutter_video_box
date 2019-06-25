import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

import 'globals.dart';

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl> {
  Video video;
  @override
  void initState() {
    super.initState();
    video = Video(
      store: VideoStore(
        videoDataSource: VideoDataSource.network(src1),
        // initPosition: Duration(minutes: 20),
        cover: Text(
          'cover',
          style: TextStyle(color: Colors.white),
        ),
        // playingListenner: () {
        //   print(video.store.toMap());
        // },
        // isAutoplay: true,
        // isLooping: true,
        // volume: 0.0,
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
