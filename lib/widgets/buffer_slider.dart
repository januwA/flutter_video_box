import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../util/map.dart';

typedef ValueChanged<T> = void Function(T value);

class BufferSlider extends StatelessWidget {
  final double value;
  final double bufferValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;
  final BorderRadiusGeometry borderRadius;
  final Widget pointWidget;

  final double min;
  final double max;

  final Color activeColor;
  final Color inactiveColor;
  final Color bufferColor;

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
    this.activeColor,
    this.inactiveColor,
    this.bufferColor,
    this.borderRadius,
    this.pointWidget,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    SliderThemeData sliderTheme = SliderTheme.of(context);

    sliderTheme = sliderTheme.copyWith(
      trackHeight: sliderTheme.trackHeight ?? _defaultTrackHeight,
      activeTrackColor: activeColor ??
          sliderTheme.activeTrackColor ??
          theme.colorScheme.primary,
      inactiveTrackColor: inactiveColor ??
          sliderTheme.inactiveTrackColor ??
          theme.colorScheme.primary.withOpacity(0.24),
      disabledActiveTrackColor: sliderTheme.disabledActiveTrackColor ??
          theme.colorScheme.onSurface.withOpacity(0.32),
      disabledInactiveTrackColor: sliderTheme.disabledInactiveTrackColor ??
          theme.colorScheme.onSurface.withOpacity(0.12),
      activeTickMarkColor: inactiveColor ??
          sliderTheme.activeTickMarkColor ??
          theme.colorScheme.onPrimary.withOpacity(0.54),
      inactiveTickMarkColor: activeColor ??
          sliderTheme.inactiveTickMarkColor ??
          theme.colorScheme.primary.withOpacity(0.54),
      disabledActiveTickMarkColor: sliderTheme.disabledActiveTickMarkColor ??
          theme.colorScheme.onPrimary.withOpacity(0.12),
      disabledInactiveTickMarkColor:
          sliderTheme.disabledInactiveTickMarkColor ??
              theme.colorScheme.onSurface.withOpacity(0.12),
      thumbColor:
          activeColor ?? sliderTheme.thumbColor ?? theme.colorScheme.primary,
      disabledThumbColor: sliderTheme.disabledThumbColor ??
          theme.colorScheme.onSurface.withOpacity(0.38),
      overlayColor: activeColor?.withOpacity(0.12) ??
          sliderTheme.overlayColor ??
          theme.colorScheme.primary.withOpacity(0.12),
      valueIndicatorColor: activeColor ??
          sliderTheme.valueIndicatorColor ??
          theme.colorScheme.primary,
      trackShape: sliderTheme.trackShape ?? _defaultTrackShape,
      tickMarkShape: sliderTheme.tickMarkShape ?? _defaultTickMarkShape,
      thumbShape: sliderTheme.thumbShape ?? _defaultThumbShape,
      overlayShape: sliderTheme.overlayShape ?? _defaultOverlayShape,
      valueIndicatorShape:
          sliderTheme.valueIndicatorShape ?? _defaultValueIndicatorShape,
      showValueIndicator:
          sliderTheme.showValueIndicator ?? _defaultShowValueIndicator,
      valueIndicatorTextStyle: sliderTheme.valueIndicatorTextStyle ??
          theme.textTheme.bodyText1.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
    );

    Size pointSize = sliderTheme.thumbShape.getPreferredSize(true, true);
    BorderRadiusGeometry _borderRadius =
        borderRadius ?? BorderRadius.circular(10);
    return Container(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints size) => Container(
          width: size.maxWidth - pointSize.width / 2,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints size) {
              double _innerMinWidth = 0;
              double _innerMaxWidth = size.maxWidth;
              double _currentVlaue =
                  map(value, min, max, _innerMinWidth, _innerMaxWidth);
              double _bufferValue = bufferValue != null
                  ? map(bufferValue, min, max, _innerMinWidth, _innerMaxWidth)
                  : null;

              double _constraintsX(double x) {
                if (x <= _innerMinWidth) return _innerMinWidth;
                if (x >= _innerMaxWidth) return _innerMaxWidth;
                return x;
              }

              double _lerpValue(double x) {
                return map(x, _innerMinWidth, _innerMaxWidth, min, max);
              }

              return GestureDetector(
                onPanDown: (DragDownDetails d) {
                  double x = _constraintsX(d.localPosition.dx);
                  double _value = _lerpValue(x);
                  if (_value != value) {
                    onChanged(_value);
                  }
                },
                onPanStart: (DragStartDetails d) {
                  double x = _constraintsX(d.localPosition.dx);
                  double _value = _lerpValue(x);
                  if (onChangeStart != null) onChangeStart(_value);
                  if (_value != value) {
                    onChanged(_value);
                  }
                },
                onPanUpdate: (DragUpdateDetails d) {
                  double x = _constraintsX(d.localPosition.dx);
                  double _value = _lerpValue(x);
                  onChanged(_value);
                },
                onPanEnd: (DragEndDetails d) {
                  double _value = _lerpValue(value);
                  if (onChangeEnd != null) onChangeEnd(_value);
                },
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
                              color: bufferColor ??
                                  theme.primaryColor.withOpacity(0.5),
                              borderRadius: _borderRadius,
                            ),
                          ),
                        ),

                      // current value
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

                      pointWidget ??
                          Positioned(
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
