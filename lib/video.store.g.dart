// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$VideoStore on _VideoStore, Store {
  Computed<String> _$durationTextComputed;

  @override
  String get durationText =>
      (_$durationTextComputed ??= Computed<String>(() => super.durationText))
          .value;
  Computed<String> _$positionTextComputed;

  @override
  String get positionText =>
      (_$positionTextComputed ??= Computed<String>(() => super.positionText))
          .value;
  Computed<double> _$sliderValueComputed;

  @override
  double get sliderValue =>
      (_$sliderValueComputed ??= Computed<double>(() => super.sliderValue))
          .value;

  final _$srcAtom = Atom(name: '_VideoStore.src');

  @override
  String get src {
    _$srcAtom.reportObserved();
    return super.src;
  }

  @override
  set src(String value) {
    _$srcAtom.context.checkIfStateModificationsAreAllowed(_$srcAtom);
    super.src = value;
    _$srcAtom.reportChanged();
  }

  final _$isAutoplayAtom = Atom(name: '_VideoStore.isAutoplay');

  @override
  bool get isAutoplay {
    _$isAutoplayAtom.reportObserved();
    return super.isAutoplay;
  }

  @override
  set isAutoplay(bool value) {
    _$isAutoplayAtom.context
        .checkIfStateModificationsAreAllowed(_$isAutoplayAtom);
    super.isAutoplay = value;
    _$isAutoplayAtom.reportChanged();
  }

  final _$isLoopingAtom = Atom(name: '_VideoStore.isLooping');

  @override
  bool get isLooping {
    _$isLoopingAtom.reportObserved();
    return super.isLooping;
  }

  @override
  set isLooping(bool value) {
    _$isLoopingAtom.context
        .checkIfStateModificationsAreAllowed(_$isLoopingAtom);
    super.isLooping = value;
    _$isLoopingAtom.reportChanged();
  }

  final _$volumeAtom = Atom(name: '_VideoStore.volume');

  @override
  double get volume {
    _$volumeAtom.reportObserved();
    return super.volume;
  }

  @override
  set volume(double value) {
    _$volumeAtom.context.checkIfStateModificationsAreAllowed(_$volumeAtom);
    super.volume = value;
    _$volumeAtom.reportChanged();
  }

  final _$videoCtrlAtom = Atom(name: '_VideoStore.videoCtrl');

  @override
  VideoPlayerController get videoCtrl {
    _$videoCtrlAtom.reportObserved();
    return super.videoCtrl;
  }

  @override
  set videoCtrl(VideoPlayerController value) {
    _$videoCtrlAtom.context
        .checkIfStateModificationsAreAllowed(_$videoCtrlAtom);
    super.videoCtrl = value;
    _$videoCtrlAtom.reportChanged();
  }

  final _$isVideoLoadingAtom = Atom(name: '_VideoStore.isVideoLoading');

  @override
  bool get isVideoLoading {
    _$isVideoLoadingAtom.reportObserved();
    return super.isVideoLoading;
  }

  @override
  set isVideoLoading(bool value) {
    _$isVideoLoadingAtom.context
        .checkIfStateModificationsAreAllowed(_$isVideoLoadingAtom);
    super.isVideoLoading = value;
    _$isVideoLoadingAtom.reportChanged();
  }

  final _$positionAtom = Atom(name: '_VideoStore.position');

  @override
  Duration get position {
    _$positionAtom.reportObserved();
    return super.position;
  }

  @override
  set position(Duration value) {
    _$positionAtom.context.checkIfStateModificationsAreAllowed(_$positionAtom);
    super.position = value;
    _$positionAtom.reportChanged();
  }

  final _$durationAtom = Atom(name: '_VideoStore.duration');

  @override
  Duration get duration {
    _$durationAtom.reportObserved();
    return super.duration;
  }

  @override
  set duration(Duration value) {
    _$durationAtom.context.checkIfStateModificationsAreAllowed(_$durationAtom);
    super.duration = value;
    _$durationAtom.reportChanged();
  }

  final _$isShowVideoCtrlAtom = Atom(name: '_VideoStore.isShowVideoCtrl');

  @override
  bool get isShowVideoCtrl {
    _$isShowVideoCtrlAtom.reportObserved();
    return super.isShowVideoCtrl;
  }

  @override
  set isShowVideoCtrl(bool value) {
    _$isShowVideoCtrlAtom.context
        .checkIfStateModificationsAreAllowed(_$isShowVideoCtrlAtom);
    super.isShowVideoCtrl = value;
    _$isShowVideoCtrlAtom.reportChanged();
  }

  final _$isFullScreenAtom = Atom(name: '_VideoStore.isFullScreen');

  @override
  bool get isFullScreen {
    _$isFullScreenAtom.reportObserved();
    return super.isFullScreen;
  }

  @override
  set isFullScreen(bool value) {
    _$isFullScreenAtom.context
        .checkIfStateModificationsAreAllowed(_$isFullScreenAtom);
    super.isFullScreen = value;
    _$isFullScreenAtom.reportChanged();
  }

  final _$skiptimeAtom = Atom(name: '_VideoStore.skiptime');

  @override
  Duration get skiptime {
    _$skiptimeAtom.reportObserved();
    return super.skiptime;
  }

  @override
  set skiptime(Duration value) {
    _$skiptimeAtom.context.checkIfStateModificationsAreAllowed(_$skiptimeAtom);
    super.skiptime = value;
    _$skiptimeAtom.reportChanged();
  }

  final _$initVideoPlaerAsyncAction = AsyncAction('initVideoPlaer');

  @override
  Future<void> initVideoPlaer() {
    return _$initVideoPlaerAsyncAction.run(() => super.initVideoPlaer());
  }

  final _$_VideoStoreActionController = ActionController(name: '_VideoStore');

  @override
  void _videoListenner() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super._videoListenner();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePlay() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.togglePlay();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showVideoCtrl(bool show) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.showVideoCtrl(show);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setLandscape() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setLandscape();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setPortrait() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setPortrait();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void play() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.play();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void pause() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.pause();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }
}
