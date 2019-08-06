# video_box

 A control that plays video in flutter, I make the control as flexible as possible, can play a single video, video list on the page.

note:
* Only tested on android
* No ios test
* Development api may change at any time

## Install
```
dependencies:
  video_box:
```

android: AndroidManifest.xml
```
<manifest>
    ...
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    ...
</manifest>
```

ios: Info.plist
```
<plist>
    ...
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</plist>
```

## Usage
```dart
import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

class ListVideo extends StatefulWidget {
  @override
  _ListVideoState createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  List<Video> videos = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      videos.add(
        Video(
          store: VideoStore(source: VideoPlayerController.network(src1)),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var v in videos) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('list video'),
      ),
      body: ListView(
        children: <Widget>[
          for (var v in videos)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: v.videoBox,
            ),
        ],
      ),
    );
  }
}
```

For details, see /example or source code.

show:
![](https://i.loli.net/2019/07/07/5d22104b8690b94290.jpg)