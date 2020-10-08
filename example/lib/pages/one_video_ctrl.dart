import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video_box.dart';
// import 'package:video_box/widgets/buffer_slider.dart';

import '../globals.dart';

class MyFullScreen implements CustomFullScreen {
  const MyFullScreen();
  @override
  void close(BuildContext context, VideoController controller) {
    print('pop...');
    Navigator.of(context).pop(controller.value.positionText);
  }

  @override
  Future open(BuildContext context, VideoController controller) async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            body: Center(child: VideoBox(controller: controller)),
          );
        },
      ),
    ).then(print);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}

class CustomLoading extends StatelessWidget {
  final String text;

  const CustomLoading(this.text, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.pink,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}

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

    vc = VideoController(
      source: VideoPlayerController.network(src1),
      looping: true,
      bottomPadding: EdgeInsets.only(bottom: 10),
      customFullScreen: const MyFullScreen(),
      // controllerLiveDuration: Duration(seconds: 10),
      // bottomViewBuilder: (context, c) {
      //   var theme = Theme.of(context);
      //   return Positioned(
      //     left: c.bottomPadding.left,
      //     bottom: 0,
      //     right: 0,
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Column(
      //         children: <Widget>[
      //           Row(
      //             children: <Widget>[
      //               Text(
      //                 c.initialized
      //                     ? "${c.positionText}/${c.durationText}"
      //                     : '00:00/00:00',
      //                 style: TextStyle(color: Colors.white),
      //               ),
      //               Spacer(),
      //               Text(
      //                 c.options["name"].toString(),
      //                 style: TextStyle(color: Colors.white),
      //               ),
      //             ],
      //           ),
      //           Theme(
      //             data: theme.copyWith(
      //               sliderTheme: theme.sliderTheme.copyWith(
      //                 trackHeight: 6, // line的高度
      //                 overlayShape: SliderComponentShape.noThumb,
      //               ),
      //             ),
      //             child: BufferSlider(
      //               pointWidget: const SizedBox(),
      //               value: c.sliderValue,
      //               bufferValue: c.sliderBufferValue,
      //               onChanged: (double v) => c.seekTo(Duration(
      //                   seconds: (v * c.duration.inSeconds).toInt())),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   );
      // }
    )
      ..addListener(() {
        //
      })
      ..addFullScreenChangeListener((c, isFullScreen) async {})
      ..addPlayEndListener((c) {
        /*play end*/
      })
      ..addAccelerometerEventsListenner((controller, event) {
        if (!controller.isFullScreen) return;
        bool isHorizontal = event.x.abs() > event.y.abs();
        if (!isHorizontal) return;

        if (Platform.isIOS) {
          if (event.x > 1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeRight]);
          } else if (event.x < -1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft]);
          }
        } else {
          if (event.x > 1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft]);
          } else if (event.x < -1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeRight]);
          }
        }
      })
      ..initialize().then((_) {
        // initialized
      })
      ..setPlaybackSpeed(1.25);
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
              RaisedButton(
                child: Text('play'),
                onPressed: () {
                  vc.play();
                },
              ),
              RaisedButton(
                child: Text('pause'),
                onPressed: () {
                  vc.pause();
                },
              ),
              RaisedButton(
                child: Text('full screen'),
                onPressed: () => vc.onFullScreenSwitch(context),
              ),
              RaisedButton(
                child: Text('print'),
                onPressed: () {
                  print(vc);
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

  const VideoBar({Key key, @required this.vc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('test'),
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
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text('0.5'),
                                    onTap: () => Navigator.of(context).pop(0.5),
                                  ),
                                  ListTile(
                                    title: Text('0.75'),
                                    onTap: () =>
                                        Navigator.of(context).pop(0.75),
                                  ),
                                  ListTile(
                                    title: Text('1.0'),
                                    onTap: () => Navigator.of(context).pop(1.0),
                                  ),
                                  ListTile(
                                    title: Text('1.25'),
                                    onTap: () =>
                                        Navigator.of(context).pop(1.25),
                                  ),
                                  ListTile(
                                    title: Text('1.5'),
                                    onTap: () => Navigator.of(context).pop(1.5),
                                  ),
                                ],
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
