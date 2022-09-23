import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

import '../globals.dart';

class VideoPlayerDemo extends StatefulWidget {
  const VideoPlayerDemo({Key? key}) : super(key: key);

  @override
  createState() => _VideoPlayerDemoState();
}

class _VideoPlayerDemoState extends State<VideoPlayerDemo> {
  late VideoPlayerController _controller;
  var aspectRatio = 19 / 6;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(src1)
      ..initialize().then((_) {
        setState(() {
          aspectRatio = _controller.value.aspectRatio;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _controller.value.isInitialized
            ? ListView(
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Center(
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                ],
              )
            : const Center(child: Text('loading')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }
}
