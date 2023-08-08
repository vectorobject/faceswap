import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:faceswap/data.dart';
import 'package:faceswap/frame_view.dart';
import 'package:faceswap/util.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:faceswap/file_select_view.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:process_run/process_run.dart';

import 'file_preview.dart';
import 'gif/gif_controller.dart';
import 'server.dart';
import 'status_bar.dart';
import 'generated/l10n.dart';

var imagesPath = Directory(path.join(Directory.current.parent.path, "images"));
var resultDir = Directory(path.join(Directory.current.parent.path, "output"));
var tempDir = Directory(path.join(Directory.current.parent.path, "temp"));

void main() async {
  if (!(await imagesPath.exists())) {
    await imagesPath.create();
  }
  WidgetsFlutterBinding.ensureInitialized();
  initMeeduPlayer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<Object>>[
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var item in supportedLocales) {
            if (item.toLanguageTag() == locale.toLanguageTag()) {
              return item;
            }
          }
          for (var item in supportedLocales) {
            if (item.languageCode == locale.languageCode &&
                item.countryCode == locale.countryCode) {
              return item;
            }
          }
          for (var item in supportedLocales) {
            if (item.languageCode == locale.languageCode) {
              return item;
            }
          }
        }
        return const Locale('en', '');
      },
      supportedLocales: S.delegate.supportedLocales,
      title: 'FaceSwap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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

  late LinkedScrollControllerGroup _swapListScrollControllers;
  late ScrollController _swapListScrollController_source;
  late ScrollController _swapListScrollController_arrow;
  late ScrollController _swapListScrollController_target;

  @override
  void initState() {
    Server.init();

    _swapListScrollControllers = LinkedScrollControllerGroup();
    _swapListScrollController_source = _swapListScrollControllers.addAndGet();
    _swapListScrollController_arrow = _swapListScrollControllers.addAndGet();
    _swapListScrollController_target = _swapListScrollControllers.addAndGet();

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

  void dispose() {
    _swapListScrollController_source.dispose();
    _swapListScrollController_arrow.dispose();
    _swapListScrollController_target.dispose();
    super.dispose();
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

    var resultPath =
        path.join(resultDir.path, "${Random().nextInt(100000)}.$outputExt");
    var file = File.fromUri(Uri.file(resultPath));
    if (await file.exists()) {
      return file;
    }
    try {
      var len = min(swapData.source.value.length, swapData.target.value.length);
      List<dynamic> sourceFaceInfos = [];
      for (var i = 0; i < len; i++) {
        var t = swapData.source.value[i];
        sourceFaceInfos.add({"file": t.parent.file.path, "face": t.index});
      }
      if (isImg) {
        List<int> targetFaceIndexs = [];
        for (var i = 0; i < len; i++) {
          var t = swapData.target.value[i];
          targetFaceIndexs.add(t.index);
        }
        await Server.swapImage(
            sourceFaceInfos, targetFaceIndexs, targetFile.path, resultPath);
      } else {
        List<dynamic> targetFaceInfos = [];
        for (var i = 0; i < len; i++) {
          var t = swapData.target.value[i];
          targetFaceInfos
              .add({"file": t.parent.frameFile!.path, "face": t.index});
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

  Widget _buildVerticalSplitView(List<Widget> children, [Widget? bottomBar]) {
    return Column(
      children: [
        Expanded(
            child: MultiSplitView(
          axis: Axis.vertical,
          children: children,
        )),
        if (bottomBar != null)
          Theme(
              data: ThemeData(
                  iconTheme: const IconThemeData(color: Colors.white),
                  textButtonTheme: const TextButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white)))),
              child: Container(
                height: 50,
                color: Colors.lightBlue,
                child: bottomBar,
              )),
      ],
    );
  }

  Widget _buildFaceListItem(RectData item, void Function() onDelTap) {
    return Stack(
      children: [
        FittedBox(
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
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: onDelTap,
              child: const Icon(
                Icons.close,
                color: Colors.red,
              )),
        )
      ],
    );
  }

  Widget _buildSwapList() {
    return ValueListenableBuilder(
        valueListenable: swapData.source,
        builder: (context, _, child) => ValueListenableBuilder(
            valueListenable: swapData.target,
            builder: (context, _, child) {
              var count = max(
                  swapData.source.value.length, swapData.target.value.length);
              var itemMargin = const EdgeInsets.only(bottom: 5);
              return Row(children: [
                Flexible(
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          scrollController: _swapListScrollController_source,
                          footer: SizedBox(
                            height:
                                100.0 * (count - swapData.source.value.length),
                          ),
                          onReorder: (int oldIndex, int newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex--;
                            }
                            var old = swapData.source.value.removeAt(oldIndex);
                            swapData.source.value.insert(newIndex, old);
                            swapData.source.notifyListeners();
                          },
                          children: [
                            for (var i = 0;
                                i < swapData.source.value.length;
                                i++)
                              ReorderableDragStartListener(
                                  index: i,
                                  key: GlobalKey(),
                                  child: Container(
                                    color: Colors.white,
                                    width: 100,
                                    height: 100,
                                    margin: itemMargin,
                                    child: _buildFaceListItem(
                                        swapData.source.value[i], () {
                                      swapData.source.value.removeAt(i);
                                      swapData.source.notifyListeners();
                                    }),
                                  ))
                          ],
                        ))),
                SizedBox(
                    width: 50,
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ListView.builder(
                          controller: _swapListScrollController_arrow,
                          itemCount: count,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              margin: itemMargin,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${index + 1}",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white)
                                ],
                              ),
                            );
                          },
                        ))),
                Flexible(
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    scrollController: _swapListScrollController_target,
                    footer: SizedBox(
                      height: 100.0 * (count - swapData.target.value.length),
                    ),
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex--;
                      }
                      var old = swapData.target.value.removeAt(oldIndex);
                      swapData.target.value.insert(newIndex, old);
                      swapData.target.notifyListeners();
                    },
                    children: [
                      for (var i = 0; i < swapData.target.value.length; i++)
                        ReorderableDragStartListener(
                            index: i,
                            key: GlobalKey(),
                            child: Container(
                              color: Colors.white,
                              width: 100,
                              height: 100,
                              margin: itemMargin.copyWith(right: 12),
                              child: _buildFaceListItem(
                                  swapData.target.value[i], () {
                                swapData.target.value.removeAt(i);
                                swapData.target.notifyListeners();
                              }),
                            ))
                    ],
                  ),
                )
              ]);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          children: [
            Expanded(
                child: MultiSplitView(initialAreas: const [], children: [
              _buildVerticalSplitView(
                [
                  FileSelectView(
                    dir: imagesPath.path,
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
                  TextButton.icon(
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
              ),
              _buildVerticalSplitView(
                [
                  FileSelectView(
                    dir: imagesPath.path,
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
                                            gifController:
                                                targetImg.value!.isGif
                                                    ? targetGifController
                                                    : null,
                                            videoController:
                                                targetImg.value!.isVideo
                                                    ? targetVideoController
                                                    : null,
                                          ),
                                          if (value != null &&
                                              value.frames.isNotEmpty)
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
                                            controller: targetTabController,
                                            tabs: [
                                              for (var i = 0;
                                                  i <
                                                      1 +
                                                          (value?.frames
                                                                  .length ??
                                                              0);
                                                  i++)
                                                Tab(
                                                  text: i == 0
                                                      ? S.of(context).video
                                                      : value!
                                                              .frames[i - 1]
                                                              .value
                                                              .framePosition ??
                                                          '--',
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
                  TextButton.icon(
                      onPressed: () async {
                        if (targetImg.value != null) {
                          String? framePosition;
                          File? frameFile;
                          dynamic faces;
                          if (targetImg.value!.isGif) {
                            if (targetGifController!.status !=
                                GifStatus.paused) {
                              targetGifController!.pause();
                            }
                            framePosition =
                                targetGifController!.currentIndex.toString();
                            if (targetData.value != null) {
                              var index = targetData.value!
                                  .getFramePositionIndex(framePosition);
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
                            if (!(await tempDir.exists())) {
                              await tempDir.create();
                            }
                            frameFile = File(path.join(tempDir.path,
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
                            if (!(await tempDir.exists())) {
                              await tempDir.create();
                            }
                            frameFile = File(path.join(tempDir.path,
                                "${DateTime.now().microsecondsSinceEpoch ~/ 1000}.png"));
                            if (await Server.videoScreenshot(position,
                                targetImg.value!.path, frameFile.path)) {
                              framePosition = position.toString();
                              faces = await Server.getFaces(frameFile.path);
                            }
                          } else {
                            faces =
                                await Server.getFaces(targetImg.value!.path);
                          }
                          if (faces != null) {
                            targetData.value ??= TargetData();
                            var index = targetData.value!.add(
                                FrameData(targetImg.value!)
                                    .fromServerData(faces)
                                  ..framePosition = framePosition
                                  ..frameFile = frameFile);

                            targetTabController?.dispose();
                            targetTabController = TabController(
                                length: 1 + targetData.value!.frames.length,
                                vsync: this);

                            targetData.notifyListeners();
                            targetTabController?.index = index + 1;
                          }
                        }
                      },
                      icon: const Icon(Icons.face),
                      label: Text(S.of(context).detect_faces)),
                ]),
              ),
              _buildVerticalSplitView(
                [
                  FilePreview(fileNotifier: resultImg),
                  _buildSwapList(),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton.icon(
                        onPressed: () async {
                          if (!await resultDir.exists()) {
                            await resultDir.create();
                          }
                          try {
                            (await Shell().run("start ${resultDir.path}"))
                                .first;
                          } catch (err) {}
                        },
                        icon: const Icon(Icons.folder_open),
                        label: Text(S.of(context).open_folder)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: isRunning
                          ? null
                          : () async {
                              if (sourceImg.value == null ||
                                  targetImg.value == null) {
                                return;
                              }
                              setState(() {
                                isRunning = true;
                              });
                              if (!await resultDir.exists()) {
                                await resultDir.create();
                              }
                              resultImg.value = await run();
                              setState(() {
                                isRunning = false;
                              });
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(isRunning
                          ? S.of(context).generating
                          : S.of(context).generate),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ])),
            const StatusBar()
          ],
        ));
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
