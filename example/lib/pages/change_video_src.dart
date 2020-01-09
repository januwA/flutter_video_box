import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import '../globals.dart';

class ChangeVideoSrc extends StatefulWidget {
  @override
  _ChangeVideoSrcState createState() => _ChangeVideoSrcState();
}

class _ChangeVideoSrcState extends State<ChangeVideoSrc> {
  List<String> source = [src1, src2, src3];

  int index = 0;

  String get src => source[index];

  VideoController vc;

  @override
  void initState() {
    super.initState();
    vc = VideoController(source: VideoPlayerController.network(src))
      ..initialize();
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
        title: Text('change src'),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              child: VideoBox(controller: vc),
            ),
          ),
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
                  vc.setAutoplay(false);
                  vc.setControllerLayer(show: true);
                  vc.setSource(VideoPlayerController.network(src));
                  vc.initialize();
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
                  vc.setSource(VideoPlayerController.network(src));
                  vc.initialize();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
