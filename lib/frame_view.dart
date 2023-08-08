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
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.frameData,
        builder: (context, value, child) {
          List<Widget>? overlays;
          if (value == null) {
            overlays = null;
          } else {
            overlays = [];
            for (var t in value.rects) {
              bool isSelected = t.selected;
              overlays.add(Positioned(
                left: t.rect.left,
                top: t.rect.top,
                width: t.rect.width,
                height: t.rect.height,
                child: Listener(
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
                              width: isSelected ? 10 : 6,
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.8)
                                  : Colors.red.withOpacity(0.6),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(10)),
                              color: Colors.blue.withOpacity(0.8),
                            ),
                            child: Text(
                              "${t.index + 1}",
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.white),
                            ),
                          ),
                        ))),
              ));
            }
          }
          return FilePreview(
            file: value?.fileForShow,
            imgOverlays: overlays,
          );
        });
  }
}
