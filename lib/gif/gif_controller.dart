///Code modification from https://github.com/RafaelBarbosatec/gif_view

import 'dart:async';

import 'package:flutter/material.dart';

import 'git_frame.dart';

enum GifStatus { loading, playing, stoped, paused, reversing }

class GifController extends ChangeNotifier {
  List<GifFrame> _frames = [];
  int currentIndex = 0;
  GifStatus status = GifStatus.loading;

  final bool autoPlay;
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final ValueChanged<int>? onFrame;

  bool loop;
  bool _inverted;

  Timer? _curTimer;

  GifController({
    this.autoPlay = true,
    this.loop = true,
    bool inverted = false,
    this.onStart,
    this.onFinish,
    this.onFrame,
  }) : _inverted = inverted;

  void _run() {
    switch (status) {
      case GifStatus.playing:
      case GifStatus.reversing:
        _runNextFrame();
        break;

      case GifStatus.stoped:
        onFinish?.call();
        currentIndex = 0;
        break;
      case GifStatus.loading:
      case GifStatus.paused:
    }
  }

  void _runNextFrame() async {
    _curTimer?.cancel();
    _curTimer = Timer(_frames[currentIndex].duration, () {
      if (status == GifStatus.stoped) {
        onFinish?.call();
        currentIndex = 0;
        return;
      }
      if (status == GifStatus.paused) {
        return;
      }
      if (status == GifStatus.reversing) {
        if (currentIndex > 0) {
          currentIndex--;
        } else if (loop) {
          currentIndex = _frames.length - 1;
        } else {
          status = GifStatus.stoped;
        }
      } else {
        if (currentIndex < _frames.length - 1) {
          currentIndex++;
        } else if (loop) {
          currentIndex = 0;
        } else {
          status = GifStatus.stoped;
        }
      }

      onFrame?.call(currentIndex);
      notifyListeners();
      _run();
    });
  }

  GifFrame get currentFrame => _frames[currentIndex];
  int get countFrames => _frames.length;

  void play({bool? inverted, int? initialFrame}) {
    if (status == GifStatus.loading) return;
    _inverted = inverted ?? _inverted;

    if (status == GifStatus.stoped || status == GifStatus.paused) {
      status = _inverted ? GifStatus.reversing : GifStatus.playing;

      bool isValidInitialFrame = initialFrame != null &&
          initialFrame > 0 &&
          initialFrame < _frames.length - 1;

      if (isValidInitialFrame) {
        currentIndex = initialFrame;
      } else {
        currentIndex = status == GifStatus.reversing ? _frames.length - 1 : 0;
      }
      onStart?.call();
      _run();
    } else {
      status = _inverted ? GifStatus.reversing : GifStatus.playing;
    }
  }

  void stop() {
    status = GifStatus.stoped;
    notifyListeners();
  }

  void pause() {
    status = GifStatus.paused;
    notifyListeners();
  }

  void seek(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void configure(List<GifFrame> frames, {bool updateFrames = false}) {
    _curTimer?.cancel();
    _curTimer = null;
    _frames = frames;
    switch (status) {
      case GifStatus.loading:
        status = GifStatus.stoped;
        if (autoPlay) {
          play();
        }
        notifyListeners();
        break;
      case GifStatus.playing:
        status = GifStatus.stoped;
        play();
        notifyListeners();
        break;
      case GifStatus.stoped:
        notifyListeners();
        break;
      case GifStatus.paused:
        notifyListeners();
        break;
      case GifStatus.reversing:
        notifyListeners();
        break;
    }
  }

  void clear() {
    status = GifStatus.loading;
    currentIndex = 0;
    _frames = [];
    _curTimer?.cancel();
    _curTimer = null;
  }
}
