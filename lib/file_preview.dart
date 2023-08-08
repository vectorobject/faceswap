import 'dart:io';

import 'package:faceswap/measure_size.dart';
import 'package:faceswap/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

import 'gif/gif_controller.dart';
import 'gif/gif_view.dart';
import 'video_view.dart';

class FilePreview extends StatefulWidget {
  final ValueNotifier<File?>? fileNotifier;
  final File? file;
  final List<Widget>? imgOverlays;
  final MeeduPlayerController? videoController;
  final GifController? gifController;
  const FilePreview({
    super.key,
    this.file,
    this.fileNotifier,
    this.imgOverlays,
    this.videoController,
    this.gifController,
  }) : assert(file != null && fileNotifier == null || file == null);

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.gifController != null) {
          var file = widget.file;
          file ??= widget.fileNotifier?.value;
          if (file == null) {
            return;
          }
          if (file.isGif) {
            if (widget.gifController!.status == GifStatus.loading) {
              return;
            }
            if (widget.gifController!.status == GifStatus.playing) {
              widget.gifController!.pause();
              /*if (widget.gifController!.currentIndex >=
                  widget.gifController!.countFrames - 1) {
                print(0);
              } else {
                print(widget.gifController!.currentIndex + 1);
              }*/
            } else {
              widget.gifController!
                  .play(initialFrame: widget.gifController!.currentIndex);
            }
          }
        }
      },
      child: Stack(
        children: [
          SizedBox.expand(
              child: CustomPaint(
            painter: BackgroundPainter(),
          )),
          if (!(widget.file == null && widget.fileNotifier == null))
            Center(
              child: widget.file != null
                  ? _buildContent(widget.file)
                  : ValueListenableBuilder(
                      valueListenable: widget.fileNotifier!,
                      builder: (context, value, child) {
                        return _buildContent(value);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(File? value) {
    if (value == null) {
      return const SizedBox();
    }

    if (value.isImgOrGif) {
      Widget child;
      if (widget.gifController != null && value.isGif) {
        child = Stack(
          alignment: Alignment.center,
          children: [
            GifView(
              image: FileImage(value),
              controller: widget.gifController!,
            ),
            AnimatedBuilder(
              animation: widget.gifController!,
              builder: (context, child) {
                if (widget.gifController?.status == GifStatus.paused) {
                  return const Icon(
                    Icons.play_circle_outline,
                    size: 50,
                    color: Colors.white54,
                  );
                }
                return const SizedBox();
              },
            )
          ],
        );
      } else {
        child = Image.file(value);
      }
      if (widget.imgOverlays != null) {
        child = FittedBox(
          child: Stack(
            children: [SizedHolder(child: child), ...widget.imgOverlays!],
          ),
        );
      }
      return child;
    }
    return VideoView(
      controller: widget.videoController,
      file: value,
    );
  }
}

class SizedHolder extends StatefulWidget {
  final Widget child;
  const SizedHolder({super.key, required this.child});

  @override
  State<SizedHolder> createState() => _SizedHolderState();
}

class _SizedHolderState extends State<SizedHolder> {
  double? _width;
  double? _height;
  Widget? _curChild;
  @override
  Widget build(BuildContext context) {
    if (_curChild != widget.child) {
      _curChild = widget.child;
      _width = null;
      _height = null;
    }
    if (_width == null) {
      return SizedOverflowBox(
          size: const Size(10, 10),
          child: MeasureSize(
              child: widget.child,
              onChange: (size) {
                if (size == null) {
                  return;
                }
                if (size.width <= 0 || size.height <= 0) {
                  return;
                }
                setState(() {
                  _width = size.width;
                  _height = size.height;
                });
              }));
    }
    return SizedBox(
      width: _width,
      height: _height,
      child: widget.child,
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = 20;
    double eHeight = 20;
    int xCount = (size.width / eWidth).ceil();
    int yCount = (size.height / eHeight).ceil();

    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(Offset.zero & size, paint);

    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xffcccccc);

    for (int i = 0; i <= xCount; ++i) {
      for (int j = 0; j <= yCount; ++j) {
        if (i % 2 == 0 && j % 2 == 0 || i % 2 != 0 && j % 2 != 0) {
          double dx = eWidth * i;
          double dy = eHeight * j;
          canvas.drawRect(Rect.fromLTWH(dx, dy, eWidth, eHeight), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
