import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'file_preview.dart';

class FrameView extends StatefulWidget {
  final ValueNotifier<FrameData?> frameData;
  final void Function(RectData face) onFaceDoubleTap;
  const FrameView(
      {super.key, required this.frameData, required this.onFaceDoubleTap});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> {
  late ThemeData theme;
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return ValueListenableBuilder(
        valueListenable: widget.frameData,
        builder: (context, value, child) {
          return FilePreview(
            file: value?.fileForShow,
            imgBuilder: (imgFile) {
              if (value == null) {
                return const SizedBox();
              } else {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    List<Widget> overlays = [
                      Image.file(
                        imgFile,
                      )
                    ];
                    if (value.width != null) {
                      var scale = min(constraints.maxWidth / value.width!,
                          constraints.maxHeight / value.height!);
                      if (scale > 1) {
                        scale = 1;
                      }
                      for (var t in value.rects) {
                        overlays.add(Positioned(
                          left: t.rect.left * scale,
                          top: t.rect.top * scale,
                          width: t.rect.width * scale,
                          height: t.rect.height * scale,
                          child: _buildFaceMarker(t),
                        ));
                      }
                    }
                    return Stack(
                      children: overlays,
                    );
                  },
                );
              }
            },
          );
        });
  }

  Widget _buildFaceMarker(RectData t) {
    bool isSelected = t.selected;
    return Listener(
        onPointerDown: (event) {
          if (event.buttons == kPrimaryMouseButton) {
            if (!t.selected) {
              t.selected = true;
              setState(() {});
            }
          } else if (event.buttons == kSecondaryMouseButton) {
            if (t.selected) {
              t.selected = false;
              setState(() {});
            }
          }
        },
        child: GestureDetector(
            onDoubleTap: () {
              widget.onFaceDoubleTap(t);
            },
            child: Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border.all(
                  width: isSelected ? 7 : 5,
                  color: isSelected
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.red.withOpacity(0.6),
                ),
              ),
              child: FittedBox(
                child: Container(
                    alignment: Alignment.center,
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10)),
                      color: Colors.blue.withOpacity(0.5),
                    ),
                    child: Text(
                      "${t.index + 1}",
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    )),
              ),
            )));
  }
}
