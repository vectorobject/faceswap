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
  final Widget Function(File imgFile)? imgBuilder;
  final MeeduPlayerController? videoController;
  final GifController? gifController;
  const FilePreview({
    super.key,
    this.file,
    this.fileNotifier,
    this.imgBuilder,
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

    Widget child;
    if (value.isImgOrGif) {
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
        if (widget.imgBuilder != null) {
          child = widget.imgBuilder!(value);
        } else {
          child = Image.file(value);
        }
      }
    } else {
      child = VideoView(
        controller: widget.videoController,
        file: value,
      );
    }
    return child;
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

    paint.color = const Color(0xffcccccc);

    for (int i = 0; i < xCount; ++i) {
      for (int j = 0; j < yCount; ++j) {
        if (i % 2 == 0 && j % 2 == 0 || i % 2 != 0 && j % 2 != 0) {
          double dx = eWidth * i;
          double dy = eHeight * j;
          double dx2 = dx + eWidth;
          double dy2 = dy + eHeight;
          if (dx2 > size.width) {
            dx2 = size.width;
          }
          if (dy2 > size.height) {
            dy2 = size.height;
          }
          canvas.drawRect(Rect.fromLTRB(dx, dy, dx2, dy2), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
