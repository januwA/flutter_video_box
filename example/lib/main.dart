import 'package:flutter/material.dart';
import 'pages/video_player_demo.dart';
import 'pages/videos.dart';
import 'pages/change_video_src.dart';
import 'pages/list_video.dart';
import 'pages/one_video_ctrl.dart';
// import 'pages/pip.dart';

const oneVideoCtrl = '/one-video-ctrl';
const listVideo = '/list-video';
const changeVideoSrc = '/change-video-src';
const videos = '/videos';
const videoPlayerDemo = '/video-player-demo';
const pipDemo = '/pip-demo';

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
        // pipDemo: (BuildContext context) => PipPage(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _push(String url) {
      Navigator.of(context).pushNamed(url);
    }

    return Scaffold(
      appBar: AppBar(title: Text('video_box example')),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                child: Text('one video ctrl'),
                onPressed: () => _push(oneVideoCtrl),
              ),
              ElevatedButton(
                child: Text('list video'),
                onPressed: () => _push(listVideo),
              ),
              ElevatedButton(
                child: Text('change video src'),
                onPressed: () => _push(changeVideoSrc),
              ),
              ElevatedButton(
                child: Text('videos'),
                onPressed: () => _push(videos),
              ),
              ElevatedButton(
                child: Text('VideoPlayerDemo'),
                onPressed: () => _push(videoPlayerDemo),
              ),
              ElevatedButton(
                child: Text('PiP'),
                onPressed: () => _push(pipDemo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
