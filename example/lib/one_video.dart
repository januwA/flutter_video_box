import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

import 'globals.dart';

class OneVideo extends StatefulWidget {
  @override
  _OneVideoState createState() => _OneVideoState();
}

class _OneVideoState extends State<OneVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('页面上确保只有一个video'),
      ),
      body: ListView(
        children: [
          VideoBox(
            isDispose: true,
            videoDataSource: VideoDataSource.network(src1),
          ),
        ],
      ),
    );
  }
}
