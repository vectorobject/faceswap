import 'dart:async';
import 'dart:io';

import 'package:faceswap/toolbar.dart';
import 'package:faceswap/util.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'generated/l10n.dart';

class FileSelectView extends StatefulWidget {
  final String dir;
  final ValueNotifier<File?> selectedFile;
  final bool onlyImg;
  const FileSelectView({
    super.key,
    required this.dir,
    required this.selectedFile,
    this.onlyImg = false,
  });

  @override
  State<FileSelectView> createState() => FileSelectViewState();
}

enum FileType { all, img, gifAndVideo }

extension FileTypeEx on FileType {
  String getDesc(BuildContext context) {
    switch (this) {
      case FileType.all:
        return S.of(context).file_filter_type_all;
      case FileType.img:
        return S.of(context).file_filter_type_img;
      case FileType.gifAndVideo:
        return S.of(context).file_filter_type_gif_video;
    }
  }

  IconData get icon {
    switch (this) {
      case FileType.all:
        return Icons.filter_alt_off_outlined;
      case FileType.img:
        return Icons.image_outlined;
      case FileType.gifAndVideo:
        return Icons.videocam_outlined;
    }
  }

  FileType get next {
    return FileType.values[(index + 1) % FileType.values.length];
  }
}

class FileSelectViewState extends State<FileSelectView> {
  late Directory dir;
  List<FileSystemEntity?> files = [];
  FileSystemEntity? tempSelectedFile;
  late ThemeData theme;

  StreamSubscription<FileSystemEvent>? watchListener;
  StreamSubscription<FileSystemEntity>? listListener;

  FileType type = FileType.all;
  @override
  void initState() {
    setDir(widget.dir);
    super.initState();
  }

  @override
  void dispose() {
    watchListener?.cancel();
    listListener?.cancel();
    super.dispose();
  }

  setDir(path) {
    dir = path is Directory ? path : Directory(path);
    watchListener?.cancel();
    watchListener = dir.watch().listen((event) {
      refreshDir();
    });
    refreshDir();
  }

  refreshDir() {
    files.clear();
    /*if (dir.path != Uri.file(widget.dir).toFilePath()) {
      files.add(null);
    }*/
    listListener?.cancel();
    listListener = dir.list().listen((f) {
      if (f is File) {
        if ((widget.onlyImg || type == FileType.img) && !f.isImg ||
            type == FileType.gifAndVideo && !f.isGifOrVideo) {
          return;
        }
        files.add(f);
      } else {
        files.insert(0, f);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: widget.selectedFile,
      builder: (BuildContext context, value, Widget? child) {
        Widget child = Column(
          children: [
            Toolbar(
              children: [
                Expanded(
                    child: Tooltip(
                  message: dir.path,
                  child: Text(
                    dir.path,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                )),
                if (!widget.onlyImg)
                  IconButton(
                    tooltip: type.getDesc(context),
                    onPressed: () {
                      type = type.next;
                      refreshDir();
                    },
                    icon: Icon(type.icon),
                  ),
                IconButton(
                  tooltip: S.of(context).add_folder,
                  icon: const Icon(
                    Icons.add_link,
                  ),
                  onPressed: () async {
                    String? source = await getDirectoryPath();
                    if (source == null) {
                      return;
                    }
                    String basePath =
                        path.join(dir.path, path.split(source).last);
                    String target = basePath;
                    int i = 1;
                    while (true) {
                      if (i > 1) {
                        target = "${basePath}_$i";
                      }
                      if (!await Directory(target).exists()) {
                        break;
                      }
                      i++;
                    }
                    try {
                      await Process.start('mklink', ["/D", target, source]);
                      debugPrint("Finished");
                    } catch (err) {
                      debugPrint("Err:$err");
                    }
                  },
                ),
                IconButton(
                  tooltip: S.of(context).parent_folder,
                  icon: const Icon(
                    Icons.arrow_upward,
                  ),
                  onPressed: !dir.parent.path.startsWith(widget.dir)
                      ? null
                      : () {
                          setState(() {
                            setDir(dir.parent);
                          });
                        },
                ),
                IconButton(
                  tooltip: S.of(context).reveal_in_file_explorer,
                  icon: const Icon(
                    Icons.folder_open,
                  ),
                  onPressed: () {
                    Util.revealInExplorer(dir, widget.selectedFile.value);
                  },
                ),
                IconButton(
                  tooltip: S.of(context).refresh,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    setState(() {
                      refreshDir();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(
                  color: theme.colorScheme.background,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 126),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      var f = files[index];
                      bool isTempSelected = tempSelectedFile == f;
                      bool isSelected = f != null &&
                          widget.selectedFile.value?.path == f.path;
                      Widget child;
                      String fName;
                      if (f == null) {
                        child = Icon(
                          Icons.folder_outlined,
                          size: 60,
                          color: theme.colorScheme.secondary,
                        );
                        fName = S.of(context).parent_folder;
                      } else {
                        if (f is File) {
                          fName = f.uri.pathSegments.last;
                          if (f.isImgOrGif) {
                            child = Image.file(f);
                          } else {
                            child = Icon(
                              Icons.video_file_outlined,
                              size: 60,
                              color: theme.colorScheme.secondary,
                            );
                          }
                        } else {
                          child = Icon(
                            Icons.folder,
                            size: 60,
                            color: theme.colorScheme.secondary,
                          );
                          fName = f.uri.pathSegments
                              .elementAt(f.uri.pathSegments.length - 2);
                        }
                      }
                      child = GestureDetector(
                          onDoubleTap: () {
                            if (f is File) {
                              widget.selectedFile.value = f;
                            } else {
                              setState(() {
                                setDir(dir =
                                    f == null ? dir.parent : f as Directory);
                              });
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                              ),
                              color: isTempSelected
                                  ? theme.colorScheme.secondaryContainer
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.all(2),
                            child: Column(
                              children: [
                                Expanded(
                                  child: child,
                                ),
                                Text(
                                  fName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: theme.colorScheme.onBackground),
                                )
                              ],
                            ),
                          ));
                      child = Listener(
                        onPointerDown: (v) {
                          setState(() {
                            tempSelectedFile = f;
                          });
                        },
                        child: child,
                      );
                      child = Tooltip(
                        waitDuration: const Duration(seconds: 1),
                        message: fName,
                        child: child,
                      );
                      return child;
                    },
                  )),
            )
          ],
        );
        return child;
      },
    );
  }
}
