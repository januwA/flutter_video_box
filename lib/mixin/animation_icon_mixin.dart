import 'package:flutter/material.dart';
import '../video.controller.dart';

mixin AnimationIconMixin on BaseVideoController {
  AnimationController? animetedIconController;
  Animation<double>? animetedIconTween;
  AnimationController? arrowIconLtRController;
  AnimationController? arrowIconRtLController;

  Duration _arrowIconDuration = Duration(milliseconds: 800);

  /// 动画icon的初始化
  ///
  /// Initialization of the animation icon
  void initAnimetedIconController(TickerProvider vsync) {
    arrowIconLtRController = AnimationController(
      duration: _arrowIconDuration,
      vsync: vsync,
    );

    arrowIconRtLController = AnimationController(
      duration: _arrowIconDuration,
      vsync: vsync,
    );

    animetedIconController = AnimationController(
      duration: animetedIconDuration,
      vsync: vsync,
    );

    animetedIconTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animetedIconController!);
    updateAnimetedIconState();
  }

  Future<void> updateAnimetedIconState() async {
    // ignore: unnecessary_null_comparison
    if (animetedIconController == null) return;
    if (videoCtrl.value.isPlaying) {
      await animetedIconController!.forward();
    } else {
      await animetedIconController!.reverse();
    }
  }
}
