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
  Computed<String> _$videoBoxTimeTextComputed;

  @override
  String get videoBoxTimeText => (_$videoBoxTimeTextComputed ??=
          Computed<String>(() => super.videoBoxTimeText))
      .value;
  Computed<double> _$sliderValueComputed;

  @override
  double get sliderValue =>
      (_$sliderValueComputed ??= Computed<double>(() => super.sliderValue))
          .value;
  Computed<IconData> _$volumeIconComputed;

  @override
  IconData get volumeIcon =>
      (_$volumeIconComputed ??= Computed<IconData>(() => super.volumeIcon))
          .value;

  final _$isPlayEndAtom = Atom(name: '_VideoStore.isPlayEnd');

  @override
  bool get isPlayEnd {
    _$isPlayEndAtom.context.enforceReadPolicy(_$isPlayEndAtom);
    _$isPlayEndAtom.reportObserved();
    return super.isPlayEnd;
  }

  @override
  set isPlayEnd(bool value) {
    _$isPlayEndAtom.context.conditionallyRunInAction(() {
      super.isPlayEnd = value;
      _$isPlayEndAtom.reportChanged();
    }, _$isPlayEndAtom, name: '${_$isPlayEndAtom.name}_set');
  }

  final _$coverAtom = Atom(name: '_VideoStore.cover');

  @override
  Widget get cover {
    _$coverAtom.context.enforceReadPolicy(_$coverAtom);
    _$coverAtom.reportObserved();
    return super.cover;
  }

  @override
  set cover(Widget value) {
    _$coverAtom.context.conditionallyRunInAction(() {
      super.cover = value;
      _$coverAtom.reportChanged();
    }, _$coverAtom, name: '${_$coverAtom.name}_set');
  }

  final _$isBfLoadingAtom = Atom(name: '_VideoStore.isBfLoading');

  @override
  bool get isBfLoading {
    _$isBfLoadingAtom.context.enforceReadPolicy(_$isBfLoadingAtom);
    _$isBfLoadingAtom.reportObserved();
    return super.isBfLoading;
  }

  @override
  set isBfLoading(bool value) {
    _$isBfLoadingAtom.context.conditionallyRunInAction(() {
      super.isBfLoading = value;
      _$isBfLoadingAtom.reportChanged();
    }, _$isBfLoadingAtom, name: '${_$isBfLoadingAtom.name}_set');
  }

  final _$autoplayAtom = Atom(name: '_VideoStore.autoplay');

  @override
  bool get autoplay {
    _$autoplayAtom.context.enforceReadPolicy(_$autoplayAtom);
    _$autoplayAtom.reportObserved();
    return super.autoplay;
  }

  @override
  set autoplay(bool value) {
    _$autoplayAtom.context.conditionallyRunInAction(() {
      super.autoplay = value;
      _$autoplayAtom.reportChanged();
    }, _$autoplayAtom, name: '${_$autoplayAtom.name}_set');
  }

  final _$loopAtom = Atom(name: '_VideoStore.loop');

  @override
  bool get loop {
    _$loopAtom.context.enforceReadPolicy(_$loopAtom);
    _$loopAtom.reportObserved();
    return super.loop;
  }

  @override
  set loop(bool value) {
    _$loopAtom.context.conditionallyRunInAction(() {
      super.loop = value;
      _$loopAtom.reportChanged();
    }, _$loopAtom, name: '${_$loopAtom.name}_set');
  }

  final _$volumeAtom = Atom(name: '_VideoStore.volume');

  @override
  double get volume {
    _$volumeAtom.context.enforceReadPolicy(_$volumeAtom);
    _$volumeAtom.reportObserved();
    return super.volume;
  }

  @override
  set volume(double value) {
    _$volumeAtom.context.conditionallyRunInAction(() {
      super.volume = value;
      _$volumeAtom.reportChanged();
    }, _$volumeAtom, name: '${_$volumeAtom.name}_set');
  }

  final _$videoCtrlAtom = Atom(name: '_VideoStore.videoCtrl');

  @override
  VideoPlayerController get videoCtrl {
    _$videoCtrlAtom.context.enforceReadPolicy(_$videoCtrlAtom);
    _$videoCtrlAtom.reportObserved();
    return super.videoCtrl;
  }

  @override
  set videoCtrl(VideoPlayerController value) {
    _$videoCtrlAtom.context.conditionallyRunInAction(() {
      super.videoCtrl = value;
      _$videoCtrlAtom.reportChanged();
    }, _$videoCtrlAtom, name: '${_$videoCtrlAtom.name}_set');
  }

  final _$isVideoLoadingAtom = Atom(name: '_VideoStore.isVideoLoading');

  @override
  bool get isVideoLoading {
    _$isVideoLoadingAtom.context.enforceReadPolicy(_$isVideoLoadingAtom);
    _$isVideoLoadingAtom.reportObserved();
    return super.isVideoLoading;
  }

  @override
  set isVideoLoading(bool value) {
    _$isVideoLoadingAtom.context.conditionallyRunInAction(() {
      super.isVideoLoading = value;
      _$isVideoLoadingAtom.reportChanged();
    }, _$isVideoLoadingAtom, name: '${_$isVideoLoadingAtom.name}_set');
  }

  final _$initPositionAtom = Atom(name: '_VideoStore.initPosition');

  @override
  Duration get initPosition {
    _$initPositionAtom.context.enforceReadPolicy(_$initPositionAtom);
    _$initPositionAtom.reportObserved();
    return super.initPosition;
  }

  @override
  set initPosition(Duration value) {
    _$initPositionAtom.context.conditionallyRunInAction(() {
      super.initPosition = value;
      _$initPositionAtom.reportChanged();
    }, _$initPositionAtom, name: '${_$initPositionAtom.name}_set');
  }

  final _$positionAtom = Atom(name: '_VideoStore.position');

  @override
  Duration get position {
    _$positionAtom.context.enforceReadPolicy(_$positionAtom);
    _$positionAtom.reportObserved();
    return super.position;
  }

  @override
  set position(Duration value) {
    _$positionAtom.context.conditionallyRunInAction(() {
      super.position = value;
      _$positionAtom.reportChanged();
    }, _$positionAtom, name: '${_$positionAtom.name}_set');
  }

  final _$durationAtom = Atom(name: '_VideoStore.duration');

  @override
  Duration get duration {
    _$durationAtom.context.enforceReadPolicy(_$durationAtom);
    _$durationAtom.reportObserved();
    return super.duration;
  }

  @override
  set duration(Duration value) {
    _$durationAtom.context.conditionallyRunInAction(() {
      super.duration = value;
      _$durationAtom.reportChanged();
    }, _$durationAtom, name: '${_$durationAtom.name}_set');
  }

  final _$isShowVideoCtrlAtom = Atom(name: '_VideoStore.isShowVideoCtrl');

  @override
  bool get isShowVideoCtrl {
    _$isShowVideoCtrlAtom.context.enforceReadPolicy(_$isShowVideoCtrlAtom);
    _$isShowVideoCtrlAtom.reportObserved();
    return super.isShowVideoCtrl;
  }

  @override
  set isShowVideoCtrl(bool value) {
    _$isShowVideoCtrlAtom.context.conditionallyRunInAction(() {
      super.isShowVideoCtrl = value;
      _$isShowVideoCtrlAtom.reportChanged();
    }, _$isShowVideoCtrlAtom, name: '${_$isShowVideoCtrlAtom.name}_set');
  }

  final _$isFullScreenAtom = Atom(name: '_VideoStore.isFullScreen');

  @override
  bool get isFullScreen {
    _$isFullScreenAtom.context.enforceReadPolicy(_$isFullScreenAtom);
    _$isFullScreenAtom.reportObserved();
    return super.isFullScreen;
  }

  @override
  set isFullScreen(bool value) {
    _$isFullScreenAtom.context.conditionallyRunInAction(() {
      super.isFullScreen = value;
      _$isFullScreenAtom.reportChanged();
    }, _$isFullScreenAtom, name: '${_$isFullScreenAtom.name}_set');
  }

  final _$skiptimeAtom = Atom(name: '_VideoStore.skiptime');

  @override
  Duration get skiptime {
    _$skiptimeAtom.context.enforceReadPolicy(_$skiptimeAtom);
    _$skiptimeAtom.reportObserved();
    return super.skiptime;
  }

  @override
  set skiptime(Duration value) {
    _$skiptimeAtom.context.conditionallyRunInAction(() {
      super.skiptime = value;
      _$skiptimeAtom.reportChanged();
    }, _$skiptimeAtom, name: '${_$skiptimeAtom.name}_set');
  }

  final _$setSourceAsyncAction = AsyncAction('setSource');

  @override
  Future<void> setSource(VideoPlayerController videoDataSource) {
    return _$setSourceAsyncAction.run(() => super.setSource(videoDataSource));
  }

  final _$initVideoPlaerAsyncAction = AsyncAction('initVideoPlaer');

  @override
  Future<void> initVideoPlaer(VideoPlayerController videoDataSource) {
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
  void _setIsBfLoading() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super._setIsBfLoading();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

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
  void setAutoplay(bool autoplay) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setAutoplay(autoplay);
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoop(bool loop) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setLoop(loop);
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
  void setVideoLoading(bool v) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setVideoLoading(v);
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
  void setOnSoundOrOff() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.setOnSoundOrOff();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setLandscape() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super._setLandscape();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setPortrait() {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super._setPortrait();
    } finally {
      _$_VideoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePlay(AnimationController controller) {
    final _$actionInfo = _$_VideoStoreActionController.startAction();
    try {
      return super.togglePlay(controller);
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
