import 'dart:convert';

import 'package:faceswap/status_bar.dart';

import 'field.dart';
import 'global.dart';

class Options {
  static Field<bool> keepFPS = Field("keepFPS", true);
  static Field<bool> audio = Field("audio", true);
  static Field<bool> keepFrames = Field("keepFrames", false);
  static RangedIntField minSimilarity = RangedIntField("minSimilarity", 30);
  static ChoicesField<String> tempFrameFormat =
      ChoicesField("tempFrameFormat", "PNG", ["PNG", "JPG"]);
  static RangedIntField tempFrameQuality =
      RangedIntField("tempFrameQuality", 0);
  static ChoicesField<String> outputVideoEncoder = ChoicesField(
      "outputVideoEncoder",
      "libx264",
      ['libx264', 'libx265', 'libvpx-vp9', 'h264_nvenc', 'hevc_nvenc']);
  static RangedIntField outputVideoQuality =
      RangedIntField("outputVideoQuality", 35);
  static final List<Field> _all = [
    keepFPS,
    audio,
    keepFrames,
    minSimilarity,
    tempFrameFormat,
    tempFrameQuality,
    outputVideoEncoder,
    outputVideoQuality
  ];
  static read() async {
    if (await Global.optionsFile.exists()) {
      var str = await Global.optionsFile.readAsString();
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(str);
      } catch (err) {
        StatusBar.appendOutput(
            "Read ${Global.optionsFile.path} err:$err", true);
        return;
      }
      for (var item in _all) {
        item.readFromObj(obj);
      }
    }
  }

  static save() async {
    var obj = {};
    for (var item in _all) {
      obj[item.fieldName] = item.value;
    }
    await Global.optionsFile.writeAsString(jsonEncode(obj));
  }
}
