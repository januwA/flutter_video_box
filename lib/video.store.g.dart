// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$VideoStore on _VideoStore, Store {
  Computed<bool> _$isShowCoverComputed;

  @override
  bool get isShowCover =>
      (_$isShowCoverComputed ??= Computed<bool>(() => super.isShowCover)).value;
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

  final _$coverAtom = Atom(name: '_VideoStore.cover');

  @override
  Widget get cover {
    _$coverAtom.reportObserved();
    return super.cover;
  }

  @override
  set cover(Widget value) {
    _$coverAtom.context.checkIfStateModificationsAreAllowed(_$coverAtom);
    super.cover = value;
    _$coverAtom.reportChanged();
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

  final _$initPositionAtom = Atom(name: '_VideoStore.initPosition');

  @override
  Duration get initPosition {
    _$initPositionAtom.reportObserved();
    return super.initPosition;
  }

  @override
  set initPosition(Duration value) {
    _$initPositionAtom.context
        .checkIfStateModificationsAreAllowed(_$initPositionAtom);
    super.initPosition = value;
    _$initPositionAtom.reportChanged();
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
  Future<void> initVideoPlaer(VideoDataSource videoDataSource) {
    return _$initVideoPlaerAsyncAction
        .run(() => super.initVideoPlaer(videoDataSource));
  }

  final _$seekToAsyncAction = AsyncAction('seekTo');

  @override
  Future<void> seekTo(Duration d) {
    return _$seekToAsyncAction.run(() => super.seekTo(d));
  }

  final _$_VideoStoreActionController = ActionController(name: '_VideoStore');

  @override
  void setCover(Widget newCover) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setCover(newCover);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsAutoplay(bool autoplay) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setIsAutoplay(autoplay);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsLooping(bool loop) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setIsLooping(loop);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVolume(double v) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setVolume(v);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInitPosition(Duration p) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setInitPosition(p);
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
  void setSkiptime(Duration st) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setSkiptime(st);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

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
  void setSource([VideoDataSource videoDataSource]) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setSource(videoDataSource);
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
  void setLandscape() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setLandscape();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPortrait() {
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
