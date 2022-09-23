import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_box/video_box.dart';

import '../globals.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late VideoController vc;

  @override
  void initState() {
    super.initState();
    vc = VideoController(
      source: VideoPlayerController.network(src1),
    )..initialize();
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  void _changeSource(String src) async {
    vc.setSource(VideoPlayerController.network(src));
    vc.cover =
        Center(child: Text(src, style: const TextStyle(color: Colors.white)));
    vc.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('videos')),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(
              controller: vc,
              cover: const Text(
                'init cover',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                child: const Text('第一集'),
                onPressed: () => _changeSource(src1),
              ),
              ElevatedButton(
                child: const Text('第二集'),
                onPressed: () => _changeSource(src2),
              ),
              ElevatedButton(
                child: const Text('第三集'),
                onPressed: () => _changeSource(src3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
