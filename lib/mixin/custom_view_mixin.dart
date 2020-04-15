import 'package:flutter/material.dart';

import '../video.controller.dart';
import '../video_box.dart';

typedef BottomViewBuilder = Widget Function(
  BuildContext context,
  VideoController controller,
);

mixin CustomViewMixin {
  List<Widget> children;
  List<Widget> beforeChildren;
  List<Widget> afterChildren;

  /// 当video首次加载时将显示这个widget。
  ///
  /// This widget will be displayed when the video is first loaded.
  ///
  /// Example:
  /// ```dart
  /// vc = VideoController(
  ///   ...
  ///   customLoadingWidget: Center(
  ///     child: Container(
  ///       color: Colors.pink,
  ///       padding: const EdgeInsets.all(12),
  ///       child: Column(
  ///         mainAxisSize: MainAxisSize.min,
  ///         children: <Widget>[
  ///           CircularProgressIndicator(),
  ///           SizedBox(height: 12),
  ///           Text("Lading..."),
  ///         ],
  ///       ),
  ///     ),
  ///   ),
  /// )
  /// ```
  Widget customLoadingWidget;

  /// 当video进入缓冲时将显示这个widget。
  /// 类似[customLoadingWidget]那样设置
  ///
  /// This widget will be displayed when the video enters the buffer.
  /// Set like [customLoadingWidget]
  Widget customBufferedWidget;

  ///
  ///Example
  ///```dart
  ///class MyFullScreen extends CustomFullScreen {
  ///   @override
  ///   void close(BuildContext context, VideoController controller) {
  ///     Navigator.of(context).pop(controller.value.positionText);
  ///   }
  ///
  ///   @override
  ///   Future open(BuildContext context, VideoController controller) async {
  ///     setLandscape();
  ///     SystemChrome.setEnabledSystemUIOverlays([]);
  ///     await Navigator.of(context)
  ///         .push<String>(
  ///           PageRouteBuilder(
  ///             transitionDuration: Duration(seconds: 2),
  ///             pageBuilder: (context, animation, secondaryAnimation) {
  ///               return Scaffold(
  ///                   body: Center(child: VideoBox(controller: controller)));
  ///             },
  ///             transitionsBuilder:
  ///                 (context, animation, secondaryAnimation, child) {
  ///               return ScaleTransition(
  ///                 scale: Tween<double>(begin: 0.0, end: 1.0).animate(
  ///                   CurvedAnimation(
  ///                     parent: animation,
  ///                     curve: Curves.ease,
  ///                   ),
  ///                 ),
  ///                 child: child,
  ///               );
  ///             },
  ///           ),
  ///         )
  ///         .then(print);
  ///     setPortrait();
  ///     SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  ///   }
  /// }
  ///```
  CustomFullScreen customFullScreen;

  /// 如果您想自定义底部控制器视图，那么可以使用这个api来实施
  ///
  /// 当然，您可能会编写更多的代码，具体的实施可以参考源码的默认实现，或则看下面的Example
  ///
  /// ---
  ///
  /// If you want to customize the bottom controller view, you can use this api to implement
  ///
  /// Of course, you may write more code, the specific implementation can refer to the default implementation of the source code, or see the following Example
  ///
  /// ## bottomViewBuilder Example
  /// ```dart
  /// import 'package:video_player/video_player.dart';
  /// import 'package:video_box/video_box.dart';
  /// import 'package:video_box/video.controller.dart';
  /// import 'package:video_box/widgets/buffer_slider.dart';
  ///
  /// vc = VideoController(
  ///   source: VideoPlayerController.network(src1),
  ///   bottomViewBuilder: (context, c) {
  ///     var theme = Theme.of(context);
  ///     return Positioned(
  ///       left: c.bottomPadding.left,
  ///       bottom: c.bottomPadding.bottom,
  ///       right: c.bottomPadding.right,
  ///       child: Column(
  ///         children: <Widget>[
  ///           Row(
  ///             children: <Widget>[
  ///               Text(
  ///                 c.initialized
  ///                     ? "${c.positionText}/${c.durationText}"
  ///                     : '00:00/00:00',
  ///                 style: TextStyle(color: Colors.white),
  ///               )
  ///             ],
  ///           ),
  ///           Theme(
  ///             data: theme.copyWith(
  ///               sliderTheme: theme.sliderTheme.copyWith(
  ///                 trackHeight: 6, // line的高度
  ///                 overlayShape: SliderComponentShape.noThumb,
  ///               ),
  ///             ),
  ///             child: Padding(
  ///               padding: const EdgeInsets.all(8.0),
  ///               child: BufferSlider(
  ///                 pointWidget: const SizedBox(),
  ///                 value: c.sliderValue,
  ///                 bufferValue: c.sliderBufferValue,
  ///                 onChanged: (double v) => c.seekTo(
  ///                     Duration(seconds: (v * c.duration.inSeconds).toInt())),
  ///               ),
  ///             ),
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   },
  /// );
  /// ```
  BottomViewBuilder bottomViewBuilder;

  Color background;

  /// icons和文字的颜色
  Color color;
  
  Color bufferColor;
  Color inactiveColor;
  Color circularProgressIndicatorColor;

  /// 底部控制器的padding
  ///
  /// Padding of bottom controller
  EdgeInsets bottomPadding;
}
