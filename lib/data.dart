import 'dart:io';

import 'package:flutter/material.dart';

class SourceFaceLib {
  static ValueNotifier<List<RectData>> faces = ValueNotifier([]);
  static bool has(RectData face) {
    if (faces.value.contains(face)) {
      return true;
    }
    for (var f in faces.value) {
      if (f.equals(face)) {
        return true;
      }
    }
    return false;
  }

  static void add(RectData face) {
    if (!has(face)) {
      faces.value.add(face);
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      faces.notifyListeners();
    }
  }
}

class SwapData {
  ValueNotifier<List<RectData>> source = ValueNotifier([]);
  ValueNotifier<List<RectData>> target = ValueNotifier([]);

  bool hasSource(RectData face) {
    if (source.value.contains(face)) {
      return true;
    }
    for (var f in source.value) {
      if (f.equals(face)) {
        return true;
      }
    }
    return false;
  }

  bool hasTarget(RectData face) {
    if (target.value.contains(face)) {
      return true;
    }
    for (var f in target.value) {
      if (f.equals(face)) {
        return true;
      }
    }
    return false;
  }

  void addSource(RectData face) {
    source.value.add(face);
    source.notifyListeners();
  }

  void addTarget(RectData face) {
    if (!hasTarget(face)) {
      target.value.add(face);
      target.notifyListeners();
    }
  }

  void clearTargets() {
    target.value.clear();
    target.notifyListeners();
  }
}

class TargetData {
  List<ValueNotifier<FrameData>> frames = [];

  int add(FrameData frame) {
    frames.add(ValueNotifier(frame));
    return frames.length - 1;
  }

  int getFramePositionIndex(String framePosition) {
    for (var i = 0; i < frames.length; i++) {
      if (frames[i].value.framePosition == framePosition) {
        return i;
      }
    }
    return -1;
  }
}

class FrameData {
  File file;
  String? framePosition;
  File? frameFile;

  get fileForShow => frameFile ?? file;

  final List<RectData> _rects = [];
  List<RectData> get rects => _rects;

  FrameData(this.file);

  addRect(RectData rect) {
    rect.parent = this;
    _rects.add(rect);
  }

  FrameData fromServerData(dynamic serverData) {
    if (serverData.length > 0) {
      _rects.clear();
      for (var i = 0; i < serverData.length; i++) {
        addRect(RectData(Rect.fromLTRB(
            serverData[i]["bbox"][0],
            serverData[i]["bbox"][1],
            serverData[i]["bbox"][2],
            serverData[i]["bbox"][3])));
      }
    }
    return this;
  }
}

class RectData {
  Rect rect;
  late FrameData parent;
  bool selected = false;

  RectData(this.rect);
  int get index => parent.rects.indexOf(this);

  bool equals(RectData t) {
    return parent.file.path == t.parent.file.path &&
        index == t.index &&
        parent.framePosition == t.parent.framePosition;
  }
}
