import 'package:faceswap/global.dart';
import 'package:faceswap/server.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'settings_view.dart';

class OutputMsg {
  bool isErr;
  String msg;
  OutputMsg(this.msg, this.isErr);
}

class StatusBar extends StatefulWidget {
  static final ValueNotifier<List<OutputMsg>> output = ValueNotifier([]);

  static appendOutput(String msg, [bool isErr = false]) {
    output.value.add(OutputMsg(msg, isErr));
    output.notifyListeners();
  }

  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  bool isLogViewShow = false;
  late ThemeData theme;
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    Widget child = SizedBox(
      height: 30,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isLogViewShow = !isLogViewShow;
              });
            },
            icon: const Icon(
              Icons.output,
            ),
            label: Text(
              S.of(context).log,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              SettingsView.show(context);
            },
            icon: Icon(
              Icons.settings,
            ),
            label: Text(
              S.of(context).settings,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: Server.waitingCount,
            builder: (context, value, child) {
              if (value == 0) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.onSurfaceVariant,
                          strokeWidth: 2,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).executing,
                      style:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: Global.themeMode,
            builder: (context, child) {
              return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Global.themeMode.value =
                        Global.themeMode.value == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                  },
                  icon: Icon(
                    Global.themeMode.value == ThemeMode.dark
                        ? Icons.nightlight_rounded
                        : Icons.wb_sunny_rounded,
                    size: 23,
                  ));
            },
          )
        ],
      ),
    );
    if (isLogViewShow) {
      //log view
      child = Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            height: 100,
            color: Colors.black,
            child: ValueListenableBuilder(
              valueListenable: StatusBar.output,
              builder: (context, value, child) {
                return ScrollbarTheme(
                    data: ScrollbarThemeData(
                        thumbVisibility: const MaterialStatePropertyAll(true),
                        thumbColor: MaterialStatePropertyAll(
                            Colors.white.withOpacity(0.5))),
                    child: ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                            height: 16,
                            child: Text(
                              value[index].msg,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: value[index].isErr
                                      ? Colors.red
                                      : Colors.white),
                            ));
                      },
                    ));
              },
            ),
          ),
          child
        ],
      );
    }
    child = TextButtonTheme(
      data: TextButtonThemeData(
          style: theme.textButtonTheme.style?.copyWith(
              foregroundColor: MaterialStatePropertyAll(
                  theme.colorScheme.onSurfaceVariant))),
      child: child,
    );
    child = IconButtonTheme(
        data: IconButtonThemeData(
            style: theme.iconButtonTheme.style?.copyWith(
                foregroundColor: MaterialStatePropertyAll(
                    theme.colorScheme.onSurfaceVariant))),
        child: child);
    return child;
  }
}
