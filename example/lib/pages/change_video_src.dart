import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_box/video_box.dart';

import '../globals.dart';

class ChangeVideoSrc extends StatefulWidget {
  const ChangeVideoSrc({Key? key}) : super(key: key);

  @override
  createState() => _ChangeVideoSrcState();
}

class _ChangeVideoSrcState extends State<ChangeVideoSrc> {
  List<String> source = [src1, src2, src3];
  late VideoController vc;

  int _index = 0;

  int get index => _index;

  set index(int nv) {
    if (nv > _index) {
      // +
      nv = nv % source.length;
    } else {
      // -
      nv = (nv + source.length) % source.length;
    }
    vc.pause();
    vc.autoplay = true;
    vc.setSource(VideoPlayerController.network(source[nv]));
    vc.initialize().then((_) {
      // ignore: avoid_print
      print(vc);
    });
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
        title: const Text('change src'),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: SizedBox(
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
              ElevatedButton(
                child: const Text('Prev'),
                onPressed: () => setState(() => index--),
              ),
              ElevatedButton(
                child: const Text('Next'),
                onPressed: () => setState(() => index++),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
