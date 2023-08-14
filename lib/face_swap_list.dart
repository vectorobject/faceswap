import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'data.dart';
import 'generated/l10n.dart';

class FaceSwapList extends StatefulWidget {
  final SwapData swapData;
  const FaceSwapList({super.key, required this.swapData});

  @override
  State<FaceSwapList> createState() => _FaceSwapListState();
}

class _FaceSwapListState extends State<FaceSwapList> {
  late LinkedScrollControllerGroup _swapListScrollControllers;
  late ScrollController _swapListScrollController_source;
  late ScrollController _swapListScrollController_arrow;
  late ScrollController _swapListScrollController_target;

  late ThemeData theme;

  @override
  void initState() {
    _swapListScrollControllers = LinkedScrollControllerGroup();
    _swapListScrollController_source = _swapListScrollControllers.addAndGet();
    _swapListScrollController_arrow = _swapListScrollControllers.addAndGet();
    _swapListScrollController_target = _swapListScrollControllers.addAndGet();
    super.initState();
  }

  @override
  void dispose() {
    _swapListScrollController_source.dispose();
    _swapListScrollController_arrow.dispose();
    _swapListScrollController_target.dispose();
    super.dispose();
  }

  Widget _buildFaceListItem(RectData item, void Function() onDelTap,
      [List<Widget>? trailings]) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          color: theme.cardColor,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 3,
                ),
                Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      child: FittedBox(
                          child: SizedOverflowBox(
                        size: Size(item.rect.width, item.rect.height),
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset: Offset(-item.rect.left, -item.rect.top),
                          child: ClipRect(
                            clipper: FaceCliper(item.rect),
                            child: Image.file(
                              item.parent.fileForShow,
                              fit: BoxFit.none,
                              alignment: Alignment.topLeft,
                            ),
                          ),
                        ),
                      )),
                    ),
                    Tooltip(
                        message: S.of(context).delete,
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: RawMaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fillColor: theme.colorScheme.secondaryContainer
                                .withOpacity(0.6),
                            child: Icon(
                              Icons.delete_forever,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed: onDelTap,
                          ),
                        )),
                  ],
                ),
                if (trailings != null) ...trailings,
              ],
            )));
  }

  Widget _buildThreeStateCheckBox(
    bool? isSelected,
    void Function() onTap,
  ) {
    if (isSelected != null) {
      return Checkbox(
        value: isSelected,
        onChanged: (value) {
          onTap();
        },
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          color: theme.primaryColor,
        ),
        Checkbox(
          onChanged: (bool? value) {
            onTap();
          },
          value: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Column(children: [
      Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            //color: theme.colorScheme.primaryContainer,
          ),
          height: 30,
          child: Row(
            children: [
              const Spacer(
                flex: 2,
              ),
              Flexible(
                  flex: 3,
                  child: Row(children: [
                    const SizedBox(width: 80 - 20),
                    ListenableBuilder(
                      listenable: widget.swapData.target,
                      builder: (context, child) {
                        var isAllEnhance = true;
                        var isAllNoEnhance = true;
                        for (var item in widget.swapData.target.value) {
                          if (item.enhance) {
                            isAllNoEnhance = false;
                          } else {
                            isAllEnhance = false;
                          }
                        }
                        return _buildThreeStateCheckBox(
                            isAllEnhance
                                ? true
                                : (isAllNoEnhance ? false : null), () {
                          if (isAllNoEnhance) {
                            for (var item in widget.swapData.target.value) {
                              item.enhance = true;
                            }
                          } else {
                            for (var item in widget.swapData.target.value) {
                              item.enhance = false;
                            }
                          }
                          widget.swapData.target.notifyListeners();
                        });
                      },
                    ),
                    Text(
                      S.of(context).face_enhance,
                      style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer),
                    )
                  ])),
            ],
          )),
      Expanded(
          child: ValueListenableBuilder(
              valueListenable: widget.swapData.source,
              builder: (context, _, child) => ValueListenableBuilder(
                  valueListenable: widget.swapData.target,
                  builder: (context, _, child) {
                    var count = max(widget.swapData.source.value.length,
                        widget.swapData.target.value.length);
                    return Row(children: [
                      Flexible(
                          flex: 2,
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ReorderableListView(
                                proxyDecorator: (child, index, animation) {
                                  return Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: theme.primaryColor),
                                        child: child,
                                      ));
                                },
                                buildDefaultDragHandles: false,
                                scrollController:
                                    _swapListScrollController_source,
                                footer: SizedBox(
                                  height: 100.0 *
                                      (count -
                                          widget.swapData.source.value.length),
                                ),
                                onReorder: (int oldIndex, int newIndex) {
                                  if (newIndex > oldIndex) {
                                    newIndex--;
                                  }
                                  var old = widget.swapData.source.value
                                      .removeAt(oldIndex);
                                  widget.swapData.source.value
                                      .insert(newIndex, old);
                                  widget.swapData.source.notifyListeners();
                                },
                                children: [
                                  for (var i = 0;
                                      i < widget.swapData.source.value.length;
                                      i++)
                                    ReorderableDragStartListener(
                                        index: i,
                                        key: ValueKey(
                                            widget.swapData.source.value[i].id),
                                        child: Container(
                                          height: 100,
                                          child: _buildFaceListItem(
                                              widget.swapData.source.value[i],
                                              () {
                                            widget.swapData.source.value
                                                .removeAt(i);
                                            widget.swapData.source
                                                .notifyListeners();
                                          }),
                                        ))
                                ],
                              ))),
                      SizedBox(
                          width: 40,
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ListView.builder(
                                controller: _swapListScrollController_arrow,
                                itemCount: count,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("${index + 1}",
                                            style: TextStyle(
                                                color: theme
                                                    .colorScheme.secondary)),
                                        Icon(Icons.arrow_forward,
                                            color: theme.colorScheme.secondary)
                                      ],
                                    ),
                                  );
                                },
                              ))),
                      Flexible(
                        flex: 3,
                        child: ReorderableListView(
                          padding: const EdgeInsets.only(right: 12),
                          proxyDecorator: (child, index, animation) {
                            return Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: theme.primaryColor),
                                  child: child,
                                ));
                          },
                          buildDefaultDragHandles: false,
                          scrollController: _swapListScrollController_target,
                          footer: SizedBox(
                            height: 100.0 *
                                (count - widget.swapData.target.value.length),
                          ),
                          onReorder: (int oldIndex, int newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex--;
                            }
                            var old =
                                widget.swapData.target.value.removeAt(oldIndex);
                            widget.swapData.target.value.insert(newIndex, old);
                            widget.swapData.target.notifyListeners();
                          },
                          children: [
                            for (var i = 0;
                                i < widget.swapData.target.value.length;
                                i++)
                              ReorderableDragStartListener(
                                  index: i,
                                  key: ValueKey(
                                      widget.swapData.target.value[i].id),
                                  child: SizedBox(
                                    height: 100,
                                    child: _buildFaceListItem(
                                        widget.swapData.target.value[i], () {
                                      widget.swapData.target.value.removeAt(i);
                                      widget.swapData.target.notifyListeners();
                                    }, [
                                      SizedOverflowBox(
                                        size: const Size(30, 30),
                                        child: Checkbox(
                                          onChanged: (v) {
                                            widget.swapData.target.value[i]
                                                .enhance = v!;
                                            widget.swapData.target
                                                .notifyListeners();
                                          },
                                          value: widget
                                              .swapData.target.value[i].enhance,
                                        ),
                                      ),
                                    ]),
                                  ))
                          ],
                        ),
                      ),
                    ]);
                  })))
    ]);
  }
}

class FaceCliper extends CustomClipper<Rect> {
  final Rect rect;
  FaceCliper(this.rect);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
