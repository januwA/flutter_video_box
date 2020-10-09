import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../_util.dart';

typedef ValueChanged<T> = void Function(T value);

class BufferSlider extends StatefulWidget {
  final double value;
  final double bufferValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;
  final BorderRadiusGeometry borderRadius;
  final Widget pointWidget;

  final double min;
  final double max;

  static const double _defaultTrackHeight = 2;
  static const SliderTrackShape _defaultTrackShape =
      RoundedRectSliderTrackShape();
  static const SliderTickMarkShape _defaultTickMarkShape =
      RoundSliderTickMarkShape();
  static const SliderComponentShape _defaultOverlayShape =
      RoundSliderOverlayShape();

  /// 设置指标大小
  static const SliderComponentShape _defaultThumbShape =
      RoundSliderThumbShape();
  static const SliderComponentShape _defaultValueIndicatorShape =
      PaddleSliderValueIndicatorShape();
  static const ShowValueIndicator _defaultShowValueIndicator =
      ShowValueIndicator.onlyForDiscrete;

  const BufferSlider({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.bufferValue,
    this.onChangeStart,
    this.onChangeEnd,
    this.max = 1.0,
    this.min = 0.0,
    this.borderRadius,
    this.pointWidget,
  }) : super(key: key);

  @override
  _BufferSliderState createState() => _BufferSliderState();
}

class _BufferSliderState extends State<BufferSlider> {
  double _innerMinWidth = 0;

  double _innerMaxWidth = 0;

  double _constraintsX(double x) {
    if (x <= _innerMinWidth) return _innerMinWidth;
    if (x >= _innerMaxWidth) return _innerMaxWidth;
    return x;
  }

  double _lerpValue(double x) {
    return map(x, _innerMinWidth, _innerMaxWidth, widget.min, widget.max);
  }

  void _onPanDown(DragDownDetails d) {
    double _value = _lerpValue(_constraintsX(d.localPosition.dx));
    if (_value != widget.value) {
      widget.onChanged(_value);
    }
  }

  void _onPanStart(DragStartDetails d) {
    double _value = _lerpValue(_constraintsX(d.localPosition.dx));
    if (widget.onChangeStart != null) widget.onChangeStart(_value);
    if (_value != widget.value) {
      widget.onChanged(_value);
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    double _value = _lerpValue(_constraintsX(d.localPosition.dx));
    widget.onChanged(_value);
  }

  void _onPanEnd(DragEndDetails d) {
    double _value = _lerpValue(widget.value);
    if (widget.onChangeEnd != null) widget.onChangeEnd(_value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    SliderThemeData sliderTheme = SliderTheme.of(context);

    sliderTheme = sliderTheme.copyWith(
      trackHeight: sliderTheme.trackHeight ?? BufferSlider._defaultTrackHeight,
      activeTrackColor:
          sliderTheme.activeTrackColor ?? theme.colorScheme.primary,
      inactiveTrackColor: sliderTheme.inactiveTrackColor ??
          theme.colorScheme.primary.withOpacity(0.24),
      disabledActiveTrackColor: sliderTheme.disabledActiveTrackColor ??
          theme.colorScheme.onSurface.withOpacity(0.32),
      disabledInactiveTrackColor: sliderTheme.disabledInactiveTrackColor ??
          theme.colorScheme.onSurface.withOpacity(0.12),
      activeTickMarkColor: sliderTheme.activeTickMarkColor ??
          theme.colorScheme.onPrimary.withOpacity(0.54),
      inactiveTickMarkColor: sliderTheme.inactiveTickMarkColor ??
          theme.colorScheme.primary.withOpacity(0.54),
      disabledActiveTickMarkColor: sliderTheme.disabledActiveTickMarkColor ??
          theme.colorScheme.onPrimary.withOpacity(0.12),
      disabledInactiveTickMarkColor:
          sliderTheme.disabledInactiveTickMarkColor ??
              theme.colorScheme.onSurface.withOpacity(0.12),
      thumbColor: sliderTheme.thumbColor ?? theme.colorScheme.primary,
      disabledThumbColor: sliderTheme.disabledThumbColor ??
          theme.colorScheme.onSurface.withOpacity(0.38),
      overlayColor: sliderTheme.overlayColor ??
          theme.colorScheme.primary.withOpacity(0.12),
      valueIndicatorColor:
          sliderTheme.valueIndicatorColor ?? theme.colorScheme.primary,
      trackShape: sliderTheme.trackShape ?? BufferSlider._defaultTrackShape,
      tickMarkShape: sliderTheme.tickMarkShape ?? BufferSlider._defaultTickMarkShape,
      thumbShape: sliderTheme.thumbShape ?? BufferSlider._defaultThumbShape,
      overlayShape: sliderTheme.overlayShape ?? BufferSlider._defaultOverlayShape,
      valueIndicatorShape:
          sliderTheme.valueIndicatorShape ?? BufferSlider._defaultValueIndicatorShape,
      showValueIndicator:
          sliderTheme.showValueIndicator ?? BufferSlider._defaultShowValueIndicator,
      valueIndicatorTextStyle: sliderTheme.valueIndicatorTextStyle ??
          theme.textTheme.bodyText1.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
    );

    Size pointSize = sliderTheme.thumbShape.getPreferredSize(true, true);
    BorderRadiusGeometry _borderRadius =
        widget.borderRadius ?? BorderRadius.circular(10);
    return Container(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints size) => Container(
          width: size.maxWidth - pointSize.width / 2,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints size) {
              _innerMaxWidth = size.maxWidth;
              double _currentVlaue =
                  map(widget.value, widget.min, widget.max, _innerMinWidth, _innerMaxWidth);
              double _bufferValue = widget.bufferValue != null
                  ? map(widget.bufferValue, widget.min, widget.max, _innerMinWidth, _innerMaxWidth)
                  : 0;

              return GestureDetector(
                onPanDown: _onPanDown,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  color: Colors.transparent,
                  height: math.max(pointSize.height, sliderTheme.trackHeight),
                  child: Stack(
                    overflow: Overflow.visible,
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      // 背景
                      Container(
                        height: sliderTheme.trackHeight,
                        width: _innerMaxWidth,
                        decoration: BoxDecoration(
                          color: sliderTheme.inactiveTrackColor,
                          borderRadius: _borderRadius,
                        ),
                      ),

                      // 缓冲区
                      if (_bufferValue != null)
                        Positioned(
                          left: 0,
                          child: Container(
                            height: sliderTheme.trackHeight,
                            width: math.min(_bufferValue, _innerMaxWidth),
                            decoration: BoxDecoration(
                              color:
                                  sliderTheme.activeTrackColor.withOpacity(0.5),
                              borderRadius: _borderRadius,
                            ),
                          ),
                        ),

                      // current valu
                      Positioned(
                        left: 0,
                        child: Container(
                          height: sliderTheme.trackHeight,
                          width: _currentVlaue,
                          decoration: BoxDecoration(
                            color: sliderTheme.activeTrackColor,
                            borderRadius: _borderRadius,
                          ),
                        ),
                      ),

                      widget.pointWidget != null
                          ? widget.pointWidget
                          : Positioned(
                              left: _currentVlaue - pointSize.width / 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: pointSize.width,
                                  height: pointSize.height,
                                  decoration: BoxDecoration(
                                    color: sliderTheme.thumbColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
