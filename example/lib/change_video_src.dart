import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

import 'globals.dart';

class ChangeVideoSrc extends StatefulWidget {
  @override
  _ChangeVideoSrcState createState() => _ChangeVideoSrcState();
}

class _ChangeVideoSrcState extends State<ChangeVideoSrc> {
  List<String> source = [src1, src2, src3];
  int index = 0;
  String get src => source[index];
  Video video;

  @override
  void initState() {
    super.initState();
    video = Video(
      store: VideoStore(
        videoDataSource: VideoDataSource.network(src),
        // autoplay: true,
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
        title: Text('change src'),
      ),
      body: ListView(
        children: <Widget>[
          video.videoBox,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('index: $index'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('Prev'),
                onPressed: () {
                  var newindex = index - 1;
                  if (newindex < 0) {
                    newindex = source.length - 1;
                  }
                  setState(() {
                    index = newindex;
                  });
                  video.store.setAutoplay(false);
                  video.store.showVideoCtrl(true);
                  video.store.setSource(VideoDataSource.network(src));
                },
              ),
              RaisedButton(
                child: Text('Next'),
                onPressed: () {
                  var newindex = index + 1;
                  if (newindex >= source.length) {
                    newindex = 0;
                  }
                  setState(() {
                    index = newindex;
                  });
                  video.store.setSource(VideoDataSource.network(src));
                  // video.store.setAutoplay(true);
                  // video.store.showVideoCtrl(false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
