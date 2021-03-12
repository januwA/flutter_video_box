import 'package:flutter/material.dart';
import 'package:video_box/video_box.dart';

import '../globals.dart';

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl> {
  VideoController vc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    vc = VideoController(
      source: VideoPlayerController.network(src1),
      autoplay: true,
    )
      ..initialize().then((e) {
        if (e != null) {
          print('[video box init] error: ' + e.message);
        } else {
          print('[video box init] success');
        }
      })
      ..addListener(() {
        if (vc.videoCtrl.value.isBuffering) {
          print('==============================');
          print('isBuffering');
          print('==============================');
        }
      });
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: controller,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(
              controller: vc,
              children: <Widget>[
                VideoBar(vc: vc),
                Align(
                  alignment: Alignment(0.5, 0),
                  child: IconButton(
                    iconSize: VideoBox.centerIconSize,
                    disabledColor: Colors.white60,
                    icon: Icon(Icons.skip_next),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                child: Text('play'),
                onPressed: () {
                  vc.play();
                },
              ),
              ElevatedButton(
                child: Text('pause'),
                onPressed: () {
                  vc.pause();
                },
              ),
              ElevatedButton(
                child: Text('full screen'),
                onPressed: () => vc.onFullScreenSwitch(context),
              ),
              ElevatedButton(
                child: Text('print'),
                onPressed: () {
                  print(vc);
                  print(vc.value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoBar extends StatelessWidget {
  final VideoController vc;
  final List<double> speeds;

  const VideoBar({
    Key key,
    @required this.vc,
    this.speeds = const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('test'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.slow_motion_video),
                        title: Text('play speed'),
                        onTap: () {
                          showModalBottomSheet<double>(
                            context: context,
                            builder: (context) {
                              return ListView(
                                children: speeds
                                    .map((e) => ListTile(
                                          title: Text(e.toString()),
                                          onTap: () =>
                                              Navigator.of(context).pop(e),
                                        ))
                                    .toList(),
                              );
                            },
                          ).then((value) {
                            if (value != null) vc.setPlaybackSpeed(value);
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
