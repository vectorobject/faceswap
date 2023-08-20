import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:faceswap/field.dart';
import 'package:faceswap/settings.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';

class SettingsView extends StatefulWidget {
  static show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(child: SettingsView()),
    ).then((_) {
      Settings.save();
    });
  }

  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late ThemeData theme;

  var _selectedIndex = 0;

  Widget _item({required String title, String? desc, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, color: theme.colorScheme.onSecondaryContainer),
        ),
        const SizedBox(
          height: 10,
        ),
        if (desc != null)
          Text(desc,
              style: TextStyle(
                  fontSize: 12,
                  color:
                      theme.colorScheme.onSecondaryContainer.withOpacity(0.8))),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: child,
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _dropdownlist(String selectedItem, List<String> items,
      void Function(String? value) onChange) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        items: [
          for (var item in items)
            DropdownMenuItem(
              value: item,
              child: Text(
                item,
              ),
            )
        ],
        value: selectedItem,
        onChanged: onChange,
        buttonStyleData: const ButtonStyleData(
          height: 35,
          width: 160,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 3,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 35,
        ),
      ),
    );
  }

  Widget _slider(RangedIntField value) {
    return Row(
      children: [
        const SizedBox(
          width: 5,
        ),
        Text(value.min.toString()),
        const SizedBox(
          width: 2,
        ),
        Expanded(
            child: Slider(
          min: value.min.toDouble(),
          max: value.max.toDouble(),
          onChanged: (t) {
            value.value = t.floor();
          },
          value: value.value.toDouble(),
        )),
        const SizedBox(
          width: 2,
        ),
        Text(value.max.toString()),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    const tabs = ["ROOP"];
    return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Material(
            color: theme.colorScheme.secondaryContainer,
            child: SizedBox(
              width: 600,
              height: 500,
              child: Row(
                children: [
                  Container(
                    width: 100,
                    color: theme.colorScheme.surface,
                    child: ListView(
                      children: [
                        for (var i = 0; i < tabs.length; i++)
                          Material(
                              color: Colors.transparent,
                              child: ListTile(
                                title: Text(tabs[i]),
                                selected: _selectedIndex == i,
                                selectedColor: theme.colorScheme.primary,
                                textColor: theme.colorScheme.onSurface
                                    .withOpacity(0.64),
                                titleTextStyle: theme.textTheme.titleMedium,
                                selectedTileColor:
                                    theme.colorScheme.secondaryContainer,
                                onTap: _selectedIndex == i
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedIndex = i;
                                        });
                                      },
                              )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: _buildContent(),
                          )),
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.bottomRight,
                              child: FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.of(context).close))),
                        ]),
                  )
                ],
              ),
            )));
  }

  Widget _buildProvider() {
    var provider = Settings.executionProvider.value;
    return SizedBox(
        height: 40,
        child: provider.isEmpty
            ? null
            : ReorderableListView(
                scrollDirection: Axis.horizontal,
                proxyDecorator: (child, index, animation) {
                  return Material(
                      color: Colors.transparent,
                      child: Stack(children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 3, color: theme.colorScheme.outline),
                              borderRadius: BorderRadius.circular(10),
                              color: theme.colorScheme.secondaryContainer),
                        ),
                        child
                      ]));
                },
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex--;
                  }
                  var old = provider.removeAt(oldIndex);
                  provider.insert(newIndex, old);
                  Settings.executionProvider.notifyListeners();
                },
                children: [
                  for (var i = 0; i < provider.length; i++)
                    ReorderableDragStartListener(
                        index: i,
                        key: ValueKey(provider[i].name),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          width: 100,
                          child: Row(children: [
                            Checkbox(
                                value: provider[i].selected,
                                onChanged: (v) {
                                  provider[i].selected = v!;
                                  Settings.executionProvider.notifyListeners();
                                }),
                            Text(
                              provider[i]
                                  .name
                                  .replaceAll("ExecutionProvider", ""),
                              strutStyle: const StrutStyle(
                                forceStrutHeight: true,
                                height: 1.2,
                              ),
                              style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      theme.colorScheme.onSecondaryContainer),
                            )
                          ]),
                        ))
                ],
              ));
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListenableBuilder(
              listenable: Settings.executionProvider,
              builder: (context, child) {
                return _item(
                  title: S.of(context).execution_providers,
                  desc: Settings.executionProvider.value.length <= 1
                      ? null
                      : S.of(context).provider_desc,
                  child: _buildProvider(),
                );
              },
            ),
            ListenableBuilder(
                listenable: Settings.executionThreads,
                builder: (context, child) {
                  return _item(
                    title:
                        "${S.of(context).execution_threads} ${Settings.executionThreads.value}",
                    child: _slider(Settings.executionThreads),
                  );
                }),
          ],
        );
    }
    return const SizedBox();
  }
}
