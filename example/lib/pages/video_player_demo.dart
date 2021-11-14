import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../globals.dart';

class VideoPlayerDemo extends StatefulWidget {
  const VideoPlayerDemo({Key? key}) : super(key: key);

  @override
  _VideoPlayerDemoState createState() => _VideoPlayerDemoState();
}

class _VideoPlayerDemoState extends State<VideoPlayerDemo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(src1)
      ..initialize().then((_) {
        setState(() {});
      })
      ..addListener(() {
        // ignore: avoid_print
        print(_controller.value.isBuffering);
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Center(child: Text('loading')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
