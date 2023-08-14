import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Global {
  static var imagesPath =
      Directory(path.join(Directory.current.parent.path, "images"));
  static var resultDir =
      Directory(path.join(Directory.current.parent.path, "output"));
  static var tempDir =
      Directory(path.join(Directory.current.parent.path, "temp"));

  static var themeMode = ValueNotifier(ThemeMode.dark);
}
