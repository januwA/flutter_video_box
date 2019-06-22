# video_box

## 一个在flutter中播放视频的控件

注意：
* 只在android上面测试过
* 没有ios测试
* 开发中api随时可能更改

## 安装配置
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

## 使用
```dart
import 'package:flutter/material.dart';
import 'package:video_box/video.store.dart';
import 'package:video_box/video_box.dart';

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
          store: VideoStore(src: src),
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


详情可以看下/example或则源码