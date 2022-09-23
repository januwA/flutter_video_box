import 'package:flutter/material.dart';

import '../video_box.dart';

typedef BottomViewBuilder = Widget Function(
  BuildContext context,
  VideoController controller,
);

mixin CustomViewMixin {
  /// to [VideoBox.children]
  List<Widget>? children;

  /// to [VideoBox.beforeChildren]
  List<Widget>? beforeChildren;

  /// to [VideoBox.afterChildren]
  List<Widget>? afterChildren;

  /// to [VideoBox.customLoadingWidget]
  Widget? customLoadingWidget;

  /// to [VideoBox.customBufferedWidget]
  Widget? customBufferedWidget;

  /// to [VideoBox.customFullScreen]
  CustomFullScreen? customFullScreen;

  /// to [VideoBox.bottomViewBuilder]
  BottomViewBuilder? bottomViewBuilder;

  /// to [VideoBox.background]
  Widget? background;

  /// to [VideoBox.bottomPadding]
  EdgeInsets? bottomPadding;

  /// to [VideoBox.cover]
  Widget? cover;

  /// to [VideoBox.theme]
  ThemeData? theme;

  /// to [VideoBox.barrierColor]
  Color? barrierColor;
}
