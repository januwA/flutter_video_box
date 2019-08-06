import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'globals.dart';

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  Video video;
  @override
  void initState() {
    super.initState();
    video = Video(
      store: VideoStore(
        source: VideoPlayerController.network(src1),
        cover: Text(
          'init cover',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    video.dispose();
    super.dispose();
  }

  void _changeSource(String src) async {
    video.store.pause();
    video.store.setVideoLoading(true);
    await Future.delayed(Duration(seconds: 2));
    await video.store.setSource(VideoPlayerController.network(src));
    video.store.setCover(Center(
        child: Text(
      src,
      style: TextStyle(color: Colors.white),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('videos'),
      ),
      body: ListView(
        children: <Widget>[
          video.videoBox,
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
