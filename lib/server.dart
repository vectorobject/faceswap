import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:faceswap/status_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;

import 'generated/l10n.dart';

class Server {
  static final ValueNotifier<Uri?> _baseUrl = ValueNotifier(null);
  static bool _isIniting = false;
  static bool _isFirstInited = false;

  static final ValueNotifier<int> waitingCount = ValueNotifier(0);

  static Process? curProcess;

  static init([bool isFirst = true]) async {
    if (isFirst) {
      if (_isFirstInited) {
        return;
      }
      _isFirstInited = true;
    }
    if (_isIniting) {
      return;
    }
    _isIniting = true;
    var file =
        File(path.join(Directory.current.parent.path, "server_port.txt"));
    StatusBar.appendOutput(
        S.current.try_to_read_service_port_from_file(file.path));
    if (await file.exists()) {
      int? port = int.tryParse(await file.readAsString());
      if (port != null) {
        StatusBar.appendOutput(S.current.using_port_read_from_file(port));
        _baseUrl.value = Uri.parse("http://127.0.0.1:$port/");
      }
    }
    if (_baseUrl.value == null) {
      var port = await _getPort();
      _runServer(port);
      var url = Uri.parse("http://127.0.0.1:$port/");
      var maxCount = 10;
      while (true) {
        HttpClient client = HttpClient();
        try {
          await client.getUrl(url);
          break;
        } catch (err) {
          debugPrint("$err");
          maxCount--;
          if (maxCount <= 0) {
            break;
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      _baseUrl.value = url;
    }
    _isIniting = false;
  }

  static Future<int> _getPort() async {
    var process =
        await Process.start("chcp 65001>nul&netstat -an", [], runInShell: true);
    List<int> ports = [];
    process.stdout.listen((binaryData) {
      String? decodedString;
      try {
        decodedString = utf8.decode(binaryData);
      } catch (e) {
        debugPrint('Not UTF-8 encoding:$binaryData');
        return;
      }
      var lines = decodedString.split("\n");
      final re = RegExp(r'\t\s');
      for (var line in lines) {
        var items = line.split(re);
        try {
          var port = int.parse(items[1].split(":").last);
          ports.add(port);
        } on RangeError {
        } catch (err) {
          debugPrint("$err");
        }
      }
    });
    await process.exitCode;
    var r = Random();
    while (true) {
      var t = 49152 + r.nextInt(16383);
      if (!ports.contains(t)) {
        return t;
      }
    }
  }

  static _runServer([int port = 0]) async {
    StatusBar.appendOutput("start server on $port");
    Process process = await Process.start(
      "start",
      [
        path.join(Directory.current.parent.path, "runServer.bat"),
        port.toString(),
      ],
      workingDirectory: Directory.current.parent.path,
      runInShell: true,
    );
    curProcess = process;
    int exitCode = await process.exitCode;
    debugPrint('Exit Code: $exitCode');
  }

  static Future<void> _waitBaseUrl() async {
    if (_baseUrl.value != null) {
      return;
    }
    var com = Completer();
    late Function() onChange;
    onChange = () {
      if (_baseUrl.value != null) {
        _baseUrl.removeListener(onChange);
        if (!com.isCompleted) {
          com.complete();
        }
      }
    };
    _baseUrl.addListener(onChange);
    return com.future;
  }

  static String _py(dynamic obj) {
    if (obj is bool) {
      return obj ? "True" : "False";
    }
    if (obj is int) {
      return "$obj";
    }
    if (obj is double) {
      return "$obj";
    }
    if (obj is String) {
      return "r'$obj'";
    }
    if (obj is List) {
      List<String> strArr = [];
      for (var i in obj) {
        strArr.add(_py(i));
      }
      return '[${strArr.join(",")}]';
    }
    if (obj is Map) {
      List<String> strArr = [];
      for (var k in obj.keys) {
        strArr.add("'$k':${_py(obj[k])}");
      }
      return '{${strArr.join(",")}}';
    }
    throw "unknow type $obj";
  }

  static Future<dynamic> _callFunc(
    String func,
  ) async {
    waitingCount.value++;
    StatusBar.appendOutput("call $func");
    await _waitBaseUrl();
    HttpClient client = HttpClient();
    HttpClientRequest req;
    try {
      req = await client.postUrl(_baseUrl.value!);
    } on SocketException {
      _baseUrl.value = null;
      StatusBar.appendOutput(S.current.connection_failed_and_restart);
      waitingCount.value--;
      init(false);
      return _callFunc(func);
    } catch (err) {
      StatusBar.appendOutput("$err");
      waitingCount.value--;
      return null;
    }
    var body = utf8.encode(func);
    req.headers.set(HttpHeaders.contentLengthHeader, body.length.toString());
    req.add(body);
    var rsp = await req.close();
    if (rsp.statusCode != HttpStatus.ok) {
      waitingCount.value--;
      return null;
    }
    String rspBody = await rsp.transform(utf8.decoder).join();
    try {
      var obj = json.decode(rspBody);
      if (obj["code"] == 0) {
        waitingCount.value--;
        return obj["result"];
      }
    } catch (err) {}
    waitingCount.value--;
    return null;
  }

  static Future<void> swapVideo(
      List<dynamic> sourceFaceInfos,
      List<dynamic> targetFaceInfos,
      String targetPath,
      String outputPath,
      bool keepFPS,
      double minSimilarity) async {
    await _callFunc(
        'swap_video(${_py(sourceFaceInfos)},${_py(targetFaceInfos)},${_py(targetPath)},${_py(outputPath)},${_py(keepFPS)},${_py(minSimilarity)})');
  }

  static Future<void> swapImage(List<dynamic> sourceFaceInfos,
      List<int> targetFaceIndexs, String targetPath, String outputPath) async {
    await _callFunc(
        'swap_image(${_py(sourceFaceInfos)},${_py(targetFaceIndexs)},${_py(targetPath)},${_py(outputPath)})');
  }

  static Future<dynamic> getFaces(String path) async {
    return _callFunc('get_faces(r"$path")');
  }

  static Future<bool> videoScreenshot(
      Duration duration, String input, String output) async {
    var r = await _callFunc(
        'video_screenshot(${_py(duration.toString())},${_py(input)},${_py(output)})');
    return r == "succ";
  }
}
