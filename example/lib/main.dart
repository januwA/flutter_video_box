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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        oneVideoCtrl: (BuildContext context) => const OneVideoCtrl(),
        listVideo: (BuildContext context) => const ListVideo(),
        changeVideoSrc: (BuildContext context) => const ChangeVideoSrc(),
        videos: (BuildContext context) => const Videos(),
        videoPlayerDemo: (BuildContext context) => const VideoPlayerDemo(),
        // pipDemo: (BuildContext context) => PipPage(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void push(String url) => Navigator.of(context).restorablePushNamed(url);

    return Scaffold(
      appBar: AppBar(title: const Text('video_box example')),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                child: const Text('one video ctrl'),
                onPressed: () => push(oneVideoCtrl),
              ),
              ElevatedButton(
                child: const Text('list video'),
                onPressed: () => push(listVideo),
              ),
              ElevatedButton(
                child: const Text('change video src'),
                onPressed: () => push(changeVideoSrc),
              ),
              ElevatedButton(
                child: const Text('videos'),
                onPressed: () => push(videos),
              ),
              ElevatedButton(
                child: const Text('VideoPlayerDemo'),
                onPressed: () => push(videoPlayerDemo),
              ),
              ElevatedButton(
                child: const Text('PiP'),
                onPressed: () => push(pipDemo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
