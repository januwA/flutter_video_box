import 'package:flutter/material.dart';
import 'pages/video_player_demo.dart';
import 'pages/videos.dart';
import 'pages/change_video_src.dart';
import 'pages/list_video.dart';
import 'pages/one_video_ctrl.dart';
import 'pages/pip.dart';

const oneVideoCtrl = '/one-video-ctrl';
const listVideo = '/list-video';
const changeVideoSrc = '/change-video-src';
const videos = '/videos';
const videoPlayerDemo = '/video-player-demo';
const piPDemo = '/pip-demo';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        oneVideoCtrl: (BuildContext context) => OneVideoCtrl(),
        listVideo: (BuildContext context) => ListVideo(),
        changeVideoSrc: (BuildContext context) => ChangeVideoSrc(),
        videos: (BuildContext context) => Videos(),
        videoPlayerDemo: (BuildContext context) => VideoPlayerDemo(),
        piPDemo: (BuildContext context) => PipPage(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('video_box example')),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                child: Text('one video ctrl'),
                onPressed: () => Navigator.of(context).pushNamed(oneVideoCtrl),
              ),
              RaisedButton(
                child: Text('list video'),
                onPressed: () {
                  Navigator.of(context).pushNamed(listVideo);
                },
              ),
              RaisedButton(
                child: Text('change video src'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(changeVideoSrc),
              ),
              RaisedButton(
                child: Text('videos'),
                onPressed: () => Navigator.of(context).pushNamed(videos),
              ),
              RaisedButton(
                child: Text('VideoPlayerDemo'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(videoPlayerDemo),
              ),
              RaisedButton(
                child: Text('PiP'),
                onPressed: () => Navigator.of(context).pushNamed(piPDemo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
