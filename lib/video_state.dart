import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' show DataSourceType;

class VideoState {
  VideoState({
    this.dataSource,
    this.dataSourceType,
    this.size,
    this.isLooping,
    this.isPlaying,
    this.autoplay,
    this.volume,
    this.initPosition,
    this.position,
    this.duration,
    this.skiptime,
    this.positionText,
    this.durationText,
    this.sliderValue,
    this.aspectRatio,
  });

  final String dataSource;
  final DataSourceType dataSourceType;
  final Size size;
  final bool autoplay;
  final bool isLooping;
  final bool isPlaying;
  final double volume;
  final Duration initPosition;
  final Duration position;
  final Duration duration;
  final Duration skiptime;
  final String positionText;
  final String durationText;
  final double sliderValue;
  final double aspectRatio;

  Map<String, dynamic> toMap() {
    return {
      "dataSource": dataSource,
      "dataSourceType": dataSourceType,
      "size": size,
      "autoplay": autoplay,
      "isLooping": isLooping,
      "isPlaying": isPlaying,
      "volume": volume,
      "initPosition": initPosition,
      "position": position,
      "duration": duration,
      "skiptime": skiptime,
      "positionText": positionText,
      "durationText": durationText,
      "sliderValue": sliderValue,
      "aspectRatio": aspectRatio
    };
  }

  @override
  String toString() {
    return """
    {
      "dataSource": $dataSource,
      "dataSourceType": $dataSourceType,
      "size": $size,
      "autoplay": $autoplay,
      "isLooping": $isLooping,
      "isPlaying": $isPlaying,
      "volume": $volume,
      "initPosition": $initPosition,
      "position": $position,
      "duration": $duration,
      "skiptime": $skiptime,
      "positionText": $positionText,
      "durationText": $durationText,
      "sliderValue": $sliderValue,
      "aspectRatio": $aspectRatio
    }
    """;
  }
}
