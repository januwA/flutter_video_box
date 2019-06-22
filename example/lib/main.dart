import 'package:flutter/material.dart';

import 'list_video.dart';
import 'one_video.dart';
import 'one_video_ctrl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/oneVideo': (BuildContext context) => OneVideo(),
        '/oneVideoCtrl': (BuildContext context) => OneVideoCtrl(),
        '/listVideo': (BuildContext context) => ListVideo(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('video_box example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('one video'),
              onPressed: () {
                Navigator.of(context).pushNamed('/oneVideo');
              },
            ),
            RaisedButton(
              child: Text('one video ctrl'),
              onPressed: () {
                Navigator.of(context).pushNamed('/oneVideoCtrl');
              },
            ),
            RaisedButton(
              child: Text('list video'),
              onPressed: () {
                Navigator.of(context).pushNamed('/listVideo');
              },
            ),
          ],
        ),
      ),
    );
  }
}
