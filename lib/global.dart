import 'dart:io';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:path/path.dart' as path;

import 'options.dart';
import 'server.dart';
import 'settings.dart';

class Global {
  static var imagesPath =
      Directory(path.join(Directory.current.parent.path, "images"));
  static var resultDir =
      Directory(path.join(Directory.current.parent.path, "output"));
  static var tempDir =
      Directory(path.join(Directory.current.parent.path, "temp"));
  static var optionsFile =
      File(path.join(Directory.current.parent.path, "options.json"));
  static var settingsFile =
      File(path.join(Directory.current.parent.path, "settings.json"));
  static var _isInited = false;
  static Future<void> init() async {
    if (_isInited) {
      return;
    }
    _isInited = true;
    initMeeduPlayer();
    if (!(await Global.imagesPath.exists())) {
      await Global.imagesPath.create();
    }
    await Settings.init();
    Options.read();
  }
}
