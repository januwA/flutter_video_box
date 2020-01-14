import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import '../globals.dart';

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  VideoController vc;

  @override
  void initState() {
    super.initState();
    vc = VideoController(
      source: VideoPlayerController.network(src1),
      cover: Text(
        'init cover',
        style: TextStyle(color: Colors.white),
      ),
    )..initialize();
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  void _changeSource(String src) async {
    vc.setSource(VideoPlayerController.network(src));
    vc.setCover(Center(
        child: Text(
      src,
      style: TextStyle(color: Colors.white),
    )));

    vc.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('videos'),
      ),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(controller: vc),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('第一集'),
                onPressed: () => _changeSource(src1),
              ),
              RaisedButton(
                child: Text('第二集'),
                onPressed: () => _changeSource(src2),
              ),
              RaisedButton(
                child: Text('第三集'),
                onPressed: () => _changeSource(src3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
