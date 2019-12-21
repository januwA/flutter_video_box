import 'package:flutter/material.dart';
import 'video_player_demo.dart';
import 'videos.dart';
import 'change_video_src.dart';
import 'list_video.dart';
import 'one_video_ctrl.dart';

const oneVideoCtrl = '/one-video-ctrl';
const listVideo = '/list-video';
const changeVideoSrc = '/change-video-src';
const videos = '/videos';
const videoPlayerDemo = '/video-player-demo';

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
            ],
          ),
        ),
      ),
    );
  }
}
