import 'dart:io';

import 'package:crc32_checksum/crc32_checksum.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as pathlib;

extension FileExt on File {
  bool get isGifOrVideo {
    return Util.isGifOrVideo(path);
  }

  bool get isGif {
    return Util.isGif(path);
  }

  bool get isVideo {
    return Util.isVideo(path);
  }

  bool get isImg {
    return Util.isImg(path);
  }

  bool get isImgOrGif {
    return Util.isImgOrGif(path);
  }

  String get ext {
    return Util.getExt(path);
  }
}

class Util {
  static const imageFormats = [
    "png",
    "jpg",
    "jpeg",
    "webp",
    "bmp",
  ];

  static const videoFormats = [
    "mp4",
    "mov",
    "avi",
    "mkv",
    "webm",
    "flv",
    "wmv",
    "ogv",
    "mpg",
    "mpeg",
    "3gp",
    "rm",
    "dv"
  ];

  static String getExt(String path) {
    var t = pathlib.split(path);
    var tArr = t.last.split(".");
    if (tArr.length < 2) {
      return "";
    }
    return tArr.last.toLowerCase();
  }

  static bool isImgOrGif(String path) {
    var t = getExt(path);
    return "gif" == t || imageFormats.contains(t);
  }

  static bool isGifOrVideo(String path) {
    var t = getExt(path);
    return "gif" == t || videoFormats.contains(t);
  }

  static bool isGif(String path) {
    return "gif" == getExt(path);
  }

  static bool isVideo(String path) {
    return videoFormats.contains(getExt(path));
  }

  static bool isImg(String path) {
    return imageFormats.contains(getExt(path));
  }

  static Future<String> getFileCrc32(File file) async {
    var str = await file.readAsBytes();
    return Crc32.calculate(str).toString();
  }

  static Future<void> revealInExplorer(Directory dir,
      [File? selectFile]) async {
    try {
      String? selectPath;
      if (selectFile != null && selectFile.path.contains(dir.path)) {
        selectPath = selectFile.path.replaceAll('/', '\\\\');
      }
      await Process.start("explorer.exe",
          selectPath != null ? ["/select,", selectPath] : [dir.path],
          runInShell: true);
    } catch (err) {
      debugPrint("$err");
    }
  }
}
