// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoController on _VideoController, Store {
  Computed<bool>? _$isShowCoverComputed;

  @override
  bool get isShowCover =>
      (_$isShowCoverComputed ??= Computed<bool>(() => super.isShowCover,
              name: '_VideoController.isShowCover'))
          .value;
  Computed<String>? _$durationTextComputed;

  @override
  String get durationText =>
      (_$durationTextComputed ??= Computed<String>(() => super.durationText,
              name: '_VideoController.durationText'))
          .value;
  Computed<String>? _$positionTextComputed;

  @override
  String get positionText =>
      (_$positionTextComputed ??= Computed<String>(() => super.positionText,
              name: '_VideoController.positionText'))
          .value;
  Computed<double>? _$sliderValueComputed;

  @override
  double get sliderValue =>
      (_$sliderValueComputed ??= Computed<double>(() => super.sliderValue,
              name: '_VideoController.sliderValue'))
          .value;
  Computed<double>? _$sliderBufferValueComputed;

  @override
  double get sliderBufferValue => (_$sliderBufferValueComputed ??=
          Computed<double>(() => super.sliderBufferValue,
              name: '_VideoController.sliderBufferValue'))
      .value;

  final _$controllerWidgetsAtom =
      Atom(name: '_VideoController.controllerWidgets');

  @override
  bool get controllerWidgets {
    _$controllerWidgetsAtom.reportRead();
    return super.controllerWidgets;
  }

  @override
  set controllerWidgets(bool value) {
    _$controllerWidgetsAtom.reportWrite(value, super.controllerWidgets, () {
      super.controllerWidgets = value;
    });
  }

  final _$isBfLoadingAtom = Atom(name: '_VideoController.isBfLoading');

  @override
  bool get isBfLoading {
    _$isBfLoadingAtom.reportRead();
    return super.isBfLoading;
  }

  @override
  set isBfLoading(bool value) {
    _$isBfLoadingAtom.reportWrite(value, super.isBfLoading, () {
      super.isBfLoading = value;
    });
  }

  final _$volumeAtom = Atom(name: '_VideoController.volume');

  @override
  double get volume {
    _$volumeAtom.reportRead();
    return super.volume;
  }

  @override
  set volume(double value) {
    _$volumeAtom.reportWrite(value, super.volume, () {
      super.volume = value;
    });
  }

  final _$initializedAtom = Atom(name: '_VideoController.initialized');

  @override
  bool get initialized {
    _$initializedAtom.reportRead();
    return super.initialized;
  }

  @override
  set initialized(bool value) {
    _$initializedAtom.reportWrite(value, super.initialized, () {
      super.initialized = value;
    });
  }

  final _$positionAtom = Atom(name: '_VideoController.position');

  @override
  Duration get position {
    _$positionAtom.reportRead();
    return super.position;
  }

  @override
  set position(Duration value) {
    _$positionAtom.reportWrite(value, super.position, () {
      super.position = value;
    });
  }

  final _$durationAtom = Atom(name: '_VideoController.duration');

  @override
  Duration get duration {
    _$durationAtom.reportRead();
    return super.duration;
  }

  @override
  set duration(Duration value) {
    _$durationAtom.reportWrite(value, super.duration, () {
      super.duration = value;
    });
  }

  final _$controllerLayerAtom = Atom(name: '_VideoController.controllerLayer');

  @override
  bool get controllerLayer {
    _$controllerLayerAtom.reportRead();
    return super.controllerLayer;
  }

  @override
  set controllerLayer(bool value) {
    _$controllerLayerAtom.reportWrite(value, super.controllerLayer, () {
      super.controllerLayer = value;
    });
  }

  final _$isFullScreenAtom = Atom(name: '_VideoController.isFullScreen');

  @override
  bool get isFullScreen {
    _$isFullScreenAtom.reportRead();
    return super.isFullScreen;
  }

  @override
  set isFullScreen(bool value) {
    _$isFullScreenAtom.reportWrite(value, super.isFullScreen, () {
      super.isFullScreen = value;
    });
  }

  final _$initializeAsyncAction = AsyncAction('_VideoController.initialize');

  @override
  Future<dynamic> initialize([bool isReconnect = false]) {
    return _$initializeAsyncAction.run(() => super.initialize(isReconnect));
  }

  final _$_VideoControllerActionController =
      ActionController(name: '_VideoController');

  @override
  void setControllerWidgets(bool v) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController.setControllerWidgets');
    try {
      return super.setControllerWidgets(v);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsBfLoading(bool v) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController.setIsBfLoading');
    try {
      return super.setIsBfLoading(v);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVolume(double v) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController.setVolume');
    try {
      return super.setVolume(v);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setControllerLayer(bool v) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController.setControllerLayer');
    try {
      return super.setControllerLayer(v);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSource(VideoPlayerController source) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController.setSource');
    try {
      return super.setSource(source);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _videoListenner() {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController._videoListenner');
    try {
      return super._videoListenner();
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setFullScreen(bool v) {
    final _$actionInfo = _$_VideoControllerActionController.startAction(
        name: '_VideoController._setFullScreen');
    try {
      return super._setFullScreen(v);
    } finally {
      _$_VideoControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
controllerWidgets: ${controllerWidgets},
isBfLoading: ${isBfLoading},
volume: ${volume},
initialized: ${initialized},
position: ${position},
duration: ${duration},
controllerLayer: ${controllerLayer},
isFullScreen: ${isFullScreen},
isShowCover: ${isShowCover},
durationText: ${durationText},
positionText: ${positionText},
sliderValue: ${sliderValue},
sliderBufferValue: ${sliderBufferValue}
    ''';
  }
}
