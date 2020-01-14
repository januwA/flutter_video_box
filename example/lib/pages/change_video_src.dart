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
  VideoController vc;

  int _index = 0;

  int get index => _index;

  set index(int nv) {
    if (nv > _index) {
      // +
      nv = nv % source.length;
      vc.autoplay = true;
      vc.setSource(VideoPlayerController.network(source[nv]));
      vc.initialize();
    } else {
      // -
      nv = (nv + source.length) % source.length;
      vc.autoplay = false;
      vc.setControllerLayer(show: true);
      vc.setSource(VideoPlayerController.network(source[nv]));
      vc.initialize();
    }
    _index = nv;
  }

  @override
  void initState() {
    super.initState();
    vc = VideoController(source: VideoPlayerController.network(source[index]))
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
                  setState(() {
                    index--;
                  });
                },
              ),
              RaisedButton(
                child: Text('Next'),
                onPressed: () {
                  setState(() {
                    index++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
