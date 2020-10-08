import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' show DataSourceType;

class VideoState {
  const VideoState({
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
    this.playbackSpeed,
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
  final double playbackSpeed;

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
      "aspectRatio": aspectRatio,
      "playbackSpeed": playbackSpeed,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
