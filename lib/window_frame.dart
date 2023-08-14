import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowFrame extends StatefulWidget {
  const WindowFrame({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The [child] contained by the VirtualWindowFrame.
  final Widget child;

  @override
  State<StatefulWidget> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  bool _isFocused = true;
  bool _isMaximized = false;
  bool _isFullScreen = false;

  late ThemeData theme;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            (_isMaximized || _isFullScreen) ? 0 : 10,
          ),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3))),
      child: DragToResizeArea(
        resizeEdgeSize: 5,
        enableResizeEdges: (_isMaximized || _isFullScreen) ? [] : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            (_isMaximized || _isFullScreen) ? 0 : 10,
          ),
          child: Column(
            children: [
              SizedBox(
                height: kWindowCaptionHeight,
                child: WindowCaption(
                  backgroundColor: theme.appBarTheme.backgroundColor,
                  brightness: theme.brightness,
                  title: Text(
                    'Faceswap',
                    style: TextStyle(
                      fontFamily: theme.textTheme.titleMedium?.fontFamily,
                      color: theme.appBarTheme.foregroundColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onWindowFocus() {
    setState(() {
      _isFocused = true;
    });
  }

  @override
  void onWindowBlur() {
    setState(() {
      _isFocused = false;
    });
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
  }
}
