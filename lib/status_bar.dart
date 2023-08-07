import 'package:faceswap/server.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';

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
  List<bool> isSelected = [false];
  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: 30,
      child: Row(
        children: [
          ToggleButtons(
              fillColor: Colors.black.withOpacity(0.2),
              selectedColor: Colors.white,
              color: Colors.white,
              selectedBorderColor: Colors.black.withOpacity(0.02),
              borderColor: Colors.black.withOpacity(0.02),
              onPressed: (int index) {
                setState(() {
                  isSelected[index] = !isSelected[index];
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(Icons.output),
                      Text(S.of(context).log),
                    ],
                  ),
                )
              ],
              isSelected: isSelected),
          ValueListenableBuilder(
            valueListenable: Server.waitingCount,
            builder: (context, value, child) {
              if (value == 0) {
                return SizedBox();
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).executing,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
    if (isSelected[0]) {
      child = Column(
        children: [
          Container(
            padding: EdgeInsets.all(3),
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
    return child;
  }
}
