import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  });

  String dataSource;
  DataSourceType dataSourceType;
  Size size;
  bool autoplay;
  bool isLooping;
  bool isPlaying;
  double volume;
  Duration initPosition;
  Duration position;
  Duration duration;
  Duration skiptime;
  String positionText;
  String durationText;
  double sliderValue;

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
    }
    """;
  }
}
