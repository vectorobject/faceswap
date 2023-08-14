import 'dart:io';

import 'package:flutter/foundation.dart';
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
  int idCount = 0;

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
    if (source.value.contains(face)) {
      face = face.copy();
    }
    face.id = idCount++;
    source.value.add(face);
    source.notifyListeners();
  }

  void addTarget(RectData face) {
    if (!hasTarget(face)) {
      face.id = idCount++;
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
  int? width;
  int? height;

  get fileForShow => frameFile ?? file;

  final List<RectData> _rects = [];
  List<RectData> get rects => _rects;

  FrameData(this.file);

  _addRect(RectData rect) {
    rect.parent = this;
    _rects.add(rect);
  }

  FrameData fromServerData(dynamic serverData) {
    if (serverData != null) {
      width = serverData["width"];
      height = serverData["height"];
      var faces = serverData["faces"];
      _rects.clear();
      for (var face in faces) {
        _addRect(RectData(Rect.fromLTRB(face[0], face[1], face[2], face[3])));
      }
    }
    return this;
  }
}

class RectData {
  int? id;
  Rect rect;
  late FrameData parent;
  bool selected = false;
  bool enhance = false;

  RectData(this.rect);
  int get index => parent.rects.indexOf(this);

  bool equals(RectData t) {
    return parent.file.path == t.parent.file.path &&
        index == t.index &&
        parent.framePosition == t.parent.framePosition;
  }

  RectData copy() {
    var t = RectData(rect);
    t.parent = parent;
    t.selected = selected;
    t.enhance = enhance;
    return t;
  }
}
