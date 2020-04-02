import 'package:flutter/material.dart';

class AnimatedArrowIcon extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final double iconSize;

  final Animation<double> _oneIconOpacityAnimation;
  final Animation<double> _twoIconOpacityAnimation;
  final Animation<double> _threeIconOpacityAnimation;

  static final double _begin = 0.0;
  static final double _end = 2.0;
  static final Curve _curve = Curves.easeInQuad;

  AnimatedArrowIcon({
    Key key,
    @required this.controller,
    this.color = Colors.black,
    this.iconSize = 24.0,
  })  : _oneIconOpacityAnimation =
            Tween<double>(begin: _begin, end: _end).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.7, curve: _curve),
          ),
        ),
        _twoIconOpacityAnimation =
            Tween<double>(begin: _begin, end: _end).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.2, 0.8, curve: _curve),
          ),
        ),
        _threeIconOpacityAnimation =
            Tween<double>(begin: _begin, end: _end).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.5, 1.0, curve: _curve),
          ),
        ),
        super(key: key);
  @override
  _AnimatedArrowIconState createState() => _AnimatedArrowIconState();
}

class _AnimatedArrowIconState extends State<AnimatedArrowIcon> {
  double get _oneValue => _edge(_lerp(widget._oneIconOpacityAnimation.value));
  double get _twoValue => _edge(_lerp(widget._twoIconOpacityAnimation.value));
  double get _threeValue =>
      _edge(_lerp(widget._threeIconOpacityAnimation.value));

  double _edge(double v) => v > 1.0 ? 1.0 : v < 0 ? 0 : v;
  double _lerp(double v) => v >= 1 ? (v - AnimatedArrowIcon._end).abs() : v;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.iconSize * 3.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment(-0.6, 0),
                    child: Opacity(
                      opacity: _oneValue,
                      child: child,
                    ),
                  ),
                  Opacity(
                    opacity: _twoValue,
                    child: child,
                  ),
                  Align(
                    alignment: Alignment(0.6, 0),
                    child: Opacity(
                      opacity: _threeValue,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      child: Icon(
        Icons.play_arrow,
        color: widget.color,
        size: widget.iconSize,
      ),
    );
  }
}
