import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' show DataSourceType;

class VideoState {
  const VideoState({
    required this.dataSource,
    required this.dataSourceType,
    required this.size,
    required this.isLooping,
    required this.isPlaying,
    required this.autoplay,
    required this.volume,
    required this.initPosition,
    required this.position,
    required this.duration,
    required this.skiptime,
    required this.positionText,
    required this.durationText,
    required this.sliderValue,
    required this.playbackSpeed,
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
      "playbackSpeed": playbackSpeed,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
