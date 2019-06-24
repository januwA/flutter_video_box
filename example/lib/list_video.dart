import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

import 'globals.dart';

class ListVideo extends StatefulWidget {
  @override
  _ListVideoState createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  List<Video> videos = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      videos.add(
        Video(
          store: VideoStore(videoDataSource: VideoDataSource.network(src1)),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var v in videos) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('list video'),
      ),
      body: ListView(
        children: <Widget>[
          for (var v in videos)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: v.videoBox,
            ),
        ],
      ),
    );
  }
}
