import 'package:flutter/widgets.dart';
import 'package:multi_split_view/multi_split_view.dart';

class MyDividerPainter extends DividerPainter {
  MyDividerPainter(
      {super.backgroundColor,
      super.highlightedBackgroundColor,
      super.animationEnabled = DividerPainter.defaultAnimationEnabled,
      super.animationDuration = DividerPainter.defaultAnimationDuration});

  @override
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required Map<int, dynamic> animatedValues}) {
    Color? color = backgroundColor;
    if (animationEnabled &&
        animatedValues.containsKey(DividerPainter.backgroundKey)) {
      color = animatedValues[DividerPainter.backgroundKey];
    } else if (highlighted && highlightedBackgroundColor != null) {
      color = highlightedBackgroundColor;
    }

    if (color != null) {
      var paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color
        ..isAntiAlias = true;
      canvas.drawRRect(
          RRect.fromLTRBR(1, 0, dividerSize.width - 1, dividerSize.height,
              const Radius.circular(10)),
          paint);
    }
  }
}
