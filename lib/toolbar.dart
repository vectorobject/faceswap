import 'package:flutter/material.dart';

class Toolbar extends StatefulWidget {
  final List<Widget> children;
  const Toolbar({super.key, required this.children});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return IconButtonTheme(
        data: IconButtonThemeData(
            style: theme.iconButtonTheme.style?.copyWith(
                iconSize: MaterialStatePropertyAll(20),
                padding: MaterialStatePropertyAll(EdgeInsets.zero))),
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 25,
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
              //color: theme.colorScheme.primaryContainer,
            ),
            child: Row(children: widget.children)));
  }
}
