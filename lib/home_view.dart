import 'dart:io';
import 'dart:ui';

import 'package:faceswap/face_swap_list.dart';
import 'package:faceswap/my_divider_painter.dart';
import 'package:faceswap/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path/path.dart' as path;

import 'data.dart';
import 'file_preview.dart';
import 'file_select_view.dart';
import 'frame_view.dart';
import 'generated/l10n.dart';
import 'gif/gif_controller.dart';
import 'global.dart';
import 'server.dart';
import 'package:intl/intl.dart';

import 'status_bar.dart';
import 'toolbar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeView> with TickerProviderStateMixin {
  ValueNotifier<File?> sourceImg = ValueNotifier(null);
  ValueNotifier<File?> targetImg = ValueNotifier(null);
  ValueNotifier<File?> resultImg = ValueNotifier(null);
  ValueNotifier<FrameData?> sourceFrameData = ValueNotifier(null);
  ValueNotifier<TargetData?> targetData = ValueNotifier(null);
  TabController? targetTabController;
  int curTargetIndex = 0;
  SwapData swapData = SwapData();
  bool isRunning = false;
  GifController? targetGifController;
  late MeeduPlayerController targetVideoController;

  late ThemeData theme;

  @override
  void initState() {
    Server.init();

    targetGifController = GifController();
    targetVideoController =
        MeeduPlayerController(controlsStyle: ControlsStyle.primary);
    sourceImg.addListener(() {
      sourceFrameData.value =
          sourceImg.value == null ? null : FrameData(sourceImg.value!);
    });
    targetImg.addListener(() {
      targetGifController?.clear();
      targetData.value = null;
      swapData.clearTargets();
    });
    super.initState();
  }

  Future<File?> run() async {
    var targetFile = swapData.target.value.first.parent.file;
    var isImg = targetFile.isImg;
    var isGif = targetFile.isGif;
    String outputExt;
    if (isGif) {
      outputExt = "gif";
    } else {
      outputExt = isImg ? 'jpg' : 'mp4';
    }

    var basePath = path.join(
        Global.resultDir.path, DateFormat('yMd_hms').format(DateTime.now()));
    var resultPath = "$basePath.$outputExt";
    int count = 1;
    while (true) {
      if (await File(resultPath).exists()) {
        resultPath = "${basePath}_${count++}.$outputExt";
      } else {
        break;
      }
    }
    try {
      List<dynamic> sourceFaceInfos = [];
      for (var t in swapData.source.value) {
        sourceFaceInfos
            .add({"file": t.parent.file.path, "face_index": t.index});
      }
      if (isImg) {
        List<dynamic> targetFaceInfos = [];
        for (var t in swapData.target.value) {
          targetFaceInfos.add({"face_index": t.index, "enhance": t.enhance});
        }
        await Server.swapImage(
            sourceFaceInfos, targetFaceInfos, targetFile.path, resultPath);
      } else {
        List<dynamic> targetFaceInfos = [];
        for (var t in swapData.target.value) {
          targetFaceInfos.add({
            "file": t.parent.frameFile!.path,
            "face_index": t.index,
            "enhance": t.enhance
          });
        }
        await Server.swapVideo(sourceFaceInfos, targetFaceInfos,
            targetFile.path, resultPath, false, 0.3);
      }
      print("Finished");
      await Future.delayed(const Duration(milliseconds: 1000));
      var file = File.fromUri(Uri.file(resultPath));
      if (await file.exists()) {
        print("Success");
        return file;
      } else {
        print("Fail");
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Widget _buildVerticalSplitView(String title, List<Widget> children,
      [Widget? bottomBar]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 25,
            child: Text(
              title,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
              child: MultiSplitView(
            axis: Axis.vertical,
            children: [
              for (var item in children)
                Container(
                  decoration: BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withOpacity(0.5)))),
                  child: item,
                )
            ],
          )),
          if (bottomBar != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: bottomBar,
            ),
        ],
      ),
    );
  }

  Widget _buildSourceView() {
    return _buildVerticalSplitView(
      S.of(context).source,
      [
        FileSelectView(
          dir: Global.imagesPath.path,
          selectedFile: sourceImg,
          onlyImg: true,
        ),
        FrameView(
          frameData: sourceFrameData,
          onFaceDoubleTap: (RectData face) {
            swapData.addSource(face);
          },
        ),
      ],
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FilledButton.icon(
            onPressed: () async {
              if (sourceFrameData.value == null) {
                return;
              }
              if (sourceImg.value != null) {
                var t = await Server.getFaces(sourceImg.value!.path);
                if (t != null) {
                  sourceFrameData.value!.fromServerData(t);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  sourceFrameData.notifyListeners();
                }
              }
            },
            icon: const Icon(Icons.face),
            label: Text(S.of(context).detect_faces)),
      ]),
    );
  }

  Widget _buildTargetView() {
    return _buildVerticalSplitView(
      S.of(context).target,
      [
        FileSelectView(
          dir: Global.imagesPath.path,
          selectedFile: targetImg,
        ),
        ValueListenableBuilder(
            valueListenable: targetImg,
            builder: (context, _, child) => ValueListenableBuilder(
                  valueListenable: targetData,
                  builder: (context, value, child) {
                    if (targetImg.value == null) {
                      return const FilePreview();
                    }
                    if (targetImg.value!.isGifOrVideo) {
                      if (targetData.value == null ||
                          targetData.value!.frames.isEmpty) {
                        return FilePreview(
                          file: targetImg.value,
                          gifController: targetImg.value!.isGif
                              ? targetGifController
                              : null,
                          videoController: targetImg.value!.isVideo
                              ? targetVideoController
                              : null,
                        );
                      }
                      return Column(
                        children: [
                          Expanded(
                              child: TabBarView(
                                  controller: targetTabController,
                                  children: [
                                FilePreview(
                                  file: targetImg.value,
                                  gifController: targetImg.value!.isGif
                                      ? targetGifController
                                      : null,
                                  videoController: targetImg.value!.isVideo
                                      ? targetVideoController
                                      : null,
                                ),
                                if (value != null && value.frames.isNotEmpty)
                                  for (var frameData in value.frames)
                                    FrameView(
                                      frameData: frameData,
                                      onFaceDoubleTap: (face) {
                                        swapData.addTarget(face);
                                      },
                                    )
                              ])),
                          SizedBox(
                              height: 50,
                              child: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  controller: targetTabController,
                                  tabs: [
                                    for (var i = 0;
                                        i < 1 + (value?.frames.length ?? 0);
                                        i++)
                                      Tooltip(
                                        waitDuration:
                                            const Duration(milliseconds: 300),
                                        message: i == 0
                                            ? S.of(context).video
                                            : value!.frames[i - 1].value
                                                    .framePosition ??
                                                '--',
                                        child: Tab(
                                          text: i == 0
                                              ? S.of(context).video
                                              : value!.frames[i - 1].value
                                                      .framePosition ??
                                                  '--',
                                        ),
                                      ),
                                  ])),
                        ],
                      );
                    }
                    if (targetImg.value!.isImg) {
                      if (value == null) {
                        return FilePreview(file: targetImg.value);
                      }
                      return FrameView(
                        frameData: value.frames.first,
                        onFaceDoubleTap: (face) {
                          swapData.addTarget(face);
                        },
                      );
                    }
                    return FilePreview(
                      file: targetImg.value,
                    );
                  },
                ))
      ],
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FilledButton.icon(
            onPressed: () async {
              if (targetImg.value != null) {
                String? framePosition;
                File? frameFile;
                dynamic faces;
                if (targetImg.value!.isGif) {
                  if (targetGifController!.status != GifStatus.paused) {
                    targetGifController!.pause();
                  }
                  framePosition = targetGifController!.currentIndex.toString();
                  if (targetData.value != null) {
                    var index =
                        targetData.value!.getFramePositionIndex(framePosition);
                    if (index >= 0) {
                      targetTabController?.index = index + 1;
                      return;
                    }
                  }
                  var frameImgData = await targetGifController!
                      .currentFrame.imageInfo.image
                      .toByteData(format: ImageByteFormat.png);
                  if (frameImgData == null) {
                    return;
                  }
                  if (!(await Global.tempDir.exists())) {
                    await Global.tempDir.create();
                  }
                  frameFile = File(path.join(Global.tempDir.path,
                      "${DateTime.now().microsecondsSinceEpoch ~/ 1000}.png"));
                  await frameFile.writeAsBytes(
                      frameImgData.buffer.asUint8List(),
                      flush: true);
                  faces = await Server.getFaces(frameFile.path);
                } else if (targetImg.value!.isVideo) {
                  await targetVideoController.pause();
                  Duration? position = await targetVideoController
                      .videoPlayerController?.position;
                  if (position == null) {
                    return;
                  }
                  if (targetData.value != null) {
                    var index = targetData.value!
                        .getFramePositionIndex(position.toString());
                    if (index >= 0) {
                      targetTabController?.index = index + 1;
                      return;
                    }
                  }
                  if (!(await Global.tempDir.exists())) {
                    await Global.tempDir.create();
                  }
                  frameFile = File(path.join(Global.tempDir.path,
                      "${DateTime.now().microsecondsSinceEpoch ~/ 1000}.png"));
                  if (await Server.videoScreenshot(
                      position, targetImg.value!.path, frameFile.path)) {
                    framePosition = position.toString();
                    faces = await Server.getFaces(frameFile.path);
                  }
                } else {
                  faces = await Server.getFaces(targetImg.value!.path);
                }
                if (faces != null) {
                  targetData.value ??= TargetData();
                  var index = targetData.value!
                      .add(FrameData(targetImg.value!).fromServerData(faces)
                        ..framePosition = framePosition
                        ..frameFile = frameFile);

                  targetTabController?.dispose();
                  targetTabController = TabController(
                      length: 1 + targetData.value!.frames.length, vsync: this);

                  targetData.notifyListeners();
                  targetTabController?.index = index + 1;
                }
              }
            },
            icon: const Icon(Icons.face),
            label: Text(S.of(context).detect_faces)),
      ]),
    );
  }

  Widget _buildResultView() {
    return _buildVerticalSplitView(
      S.of(context).result,
      [
        Column(
          children: [
            Toolbar(children: [
              const Spacer(),
              IconButton(
                tooltip: S.of(context).reveal_in_file_explorer,
                onPressed: () async {
                  if (!await Global.resultDir.exists()) {
                    await Global.resultDir.create();
                  }
                  Util.revealInExplorer(
                      Global.resultDir,
                      (resultImg.value != null &&
                              await resultImg.value!.exists())
                          ? resultImg.value
                          : null);
                },
                icon: const Icon(Icons.folder_open),
              ),
            ]),
            Expanded(child: FilePreview(fileNotifier: resultImg)),
          ],
        ),
        FaceSwapList(swapData: swapData),
      ],
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          FilledButton.icon(
            onPressed: isRunning
                ? null
                : () async {
                    if (targetImg.value == null ||
                        swapData.target.value.isEmpty) {
                      return;
                    }
                    setState(() {
                      isRunning = true;
                    });
                    if (!await Global.resultDir.exists()) {
                      await Global.resultDir.create();
                    }
                    resultImg.value = await run();
                    setState(() {
                      isRunning = false;
                    });
                  },
            icon: const Icon(Icons.play_arrow),
            label: Text(
                isRunning ? S.of(context).generating : S.of(context).generate),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
          dividerThickness: 6,
          dividerPainter:
              MyDividerPainter(highlightedBackgroundColor: theme.dividerColor)),
      child: Scaffold(
          body: Column(
        children: [
          Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: MultiSplitView(initialAreas: [
                    Area(minimalSize: 10),
                    Area(),
                    Area(size: 360, minimalSize: 10)
                  ], children: [
                    _buildSourceView(),
                    _buildTargetView(),
                    _buildResultView(),
                  ]))),
          const StatusBar()
        ],
      )),
    );
  }
}
