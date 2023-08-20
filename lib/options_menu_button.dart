import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:faceswap/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'field.dart';
import 'options.dart';

class OptionsMenuButton extends StatefulWidget {
  const OptionsMenuButton({super.key});

  @override
  State<OptionsMenuButton> createState() => _OptionsMenuButtonState();
}

class _OptionsMenuButtonState extends State<OptionsMenuButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        final RenderBox button = context.findRenderObject()! as RenderBox;
        final RenderBox overlay = Navigator.of(context)
            .overlay!
            .context
            .findRenderObject()! as RenderBox;
        final Offset position =
            button.localToGlobal(const Offset(-60, 0), ancestor: overlay);
        Navigator.push(context,
            OptionsPopupRoute(position: position, child: const OptionsMenu()));
      },
      icon: const Icon(Icons.list),
      label: Text(S.of(context).options),
    );
  }
}

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({super.key});

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  late ThemeData theme;
  Widget _buildCheckItem(String label, ValueNotifier<bool> value) {
    return SizedBox(
        width: double.infinity,
        height: 45,
        child: InkWell(
          onTap: () {
            value.value = !value.value;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                valueListenable: value,
                builder: (context, v, child) {
                  return IgnorePointer(
                    child: Checkbox(
                      onChanged: (_) {},
                      value: v,
                    ),
                  );
                },
              ),
              Text(
                label,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: theme.colorScheme.onSurface),
              )
            ],
          ),
        ));
  }

  Widget _buildSliderItem(String label, RangedIntField value) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10)),
      child: ValueListenableBuilder(
        valueListenable: value,
        builder: (context, v, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 7, right: 7, top: 7),
                child: Text(
                  "$label $v",
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
              Slider(
                min: value.min.toDouble(),
                max: value.max.toDouble(),
                onChanged: (t) {
                  value.value = t.floor();
                },
                value: v.toDouble(),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownListItem(String label, ChoicesField<String> value) {
    return ValueListenableBuilder(
      valueListenable: value,
      builder: (context, v, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text(
                label,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
            Expanded(
                child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                items: [
                  for (var item in value.choices)
                    DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                      ),
                    )
                ],
                value: v,
                onChanged: (t) {
                  if (t != null) {
                    value.value = t;
                  }
                },
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 35,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 35,
                ),
              ),
            )),
            const SizedBox(width: 6)
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
      ),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckItem(S.of(context).keep_fps, Options.keepFPS),
              _buildCheckItem(S.of(context).audio, Options.audio),
              _buildCheckItem(S.of(context).keep_frames, Options.keepFrames),
              _buildSliderItem(
                  S.of(context).min_similarity, Options.minSimilarity),
              _buildDropdownListItem(S.of(context).output_video_encoder,
                  Options.outputVideoEncoder),
              _buildSliderItem(S.of(context).output_video_quality,
                  Options.outputVideoQuality),
              _buildDropdownListItem(
                  S.of(context).temp_frame_format, Options.tempFrameFormat),
              _buildSliderItem(
                  S.of(context).temp_frame_quality, Options.tempFrameQuality),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      Options.save();
                      Navigator.of(context).pop();
                    },
                    child: Text(S.of(context).set_as_default)),
              )
            ],
          )),
    );
  }
}

class OptionsPopupRoute extends PopupRoute {
  final _duration = const Duration(milliseconds: 100);
  Offset position;
  Widget child;
  OptionsPopupRoute({required this.child, required this.position});

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, 2 / 3),
    );
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return OptionsPopup(route: this, position: position, child: child);
  }

  @override
  Duration get transitionDuration => _duration;
}

class OptionsPopup extends StatelessWidget {
  final Widget child;
  final Offset position;
  final OptionsPopupRoute route;
  const OptionsPopup(
      {super.key,
      required this.child,
      required this.position,
      required this.route});

  @override
  Widget build(BuildContext context) {
    final CurveTween opacity =
        CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    final CurveTween height = CurveTween(curve: const Interval(0.0, 1));
    Widget t = Material(elevation: 6, color: Colors.transparent, child: child);
    return CustomSingleChildLayout(
      delegate: _PopupMenuRouteLayout(position),
      child: AnimatedBuilder(
          animation: route.animation!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
                opacity: opacity.animate(route.animation!),
                child: Align(
                  widthFactor: 1,
                  heightFactor: 0.9 + 0.1 * height.evaluate(route.animation!),
                  child: t,
                ));
          }),
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  final Offset position;
  _PopupMenuRouteLayout(
    this.position,
  );

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(10),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double padding = 10;
    double x = position.dx;
    double y = position.dy - childSize.height;
    var screen = Rect.fromLTWH(0, 0, size.width, size.height);
    if (x < screen.left + padding) {
      x = screen.left + padding;
    } else if (x + childSize.width > screen.right - padding) {
      x = screen.right - childSize.width - padding;
    }
    if (y < screen.top + padding) {
      y = padding;
    } else if (y + childSize.height > screen.bottom - padding) {
      y = screen.bottom - childSize.height - padding;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return false;
  }
}
