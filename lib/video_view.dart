import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoView extends StatefulWidget {
  late final String url;
  final MeeduPlayerController? controller;

  VideoView({super.key, required File file, this.controller}) {
    url = file.path;
  }

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late MeeduPlayerController _controller;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    if (widget.controller == null) {
      _controller = MeeduPlayerController(controlsStyle: ControlsStyle.primary);
    } else {
      _controller = widget.controller!;
    }
    _controller.enabledButtons = const EnabledButtons(videoFit: false);
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('fit')) {
      _controller.videoFit.value = BoxFit.contain;
      _controller.setUserPreferenceForFit();
    }

    _setDataSource(widget.url);
  }

  _setDataSource(String url) async {
    if (_controller.videoPlayerController?.dataSource != widget.url) {
      await _controller.setDataSource(
        DataSource(
          source: url,
          type: DataSourceType.network,
        ),
        autoplay: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _setDataSource(widget.url);
    Widget child = MeeduVideoPlayer(
      controller: _controller,
    );
    child = TextButtonTheme(
      data: const TextButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent),
              padding: MaterialStatePropertyAll(EdgeInsets.zero))),
      child: child,
    );
    return child;
  }
}
