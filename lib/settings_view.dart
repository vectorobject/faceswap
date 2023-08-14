import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';

class SettingsView extends StatefulWidget {
  static show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(child: SettingsView()),
    );
  }

  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late ThemeData theme;

  var _selectedIndex = 0;

  Widget _dropdownlist(String title, String selectedItem, List<String> items) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
        //const Spacer(),
        const SizedBox(height: 10),
        DropdownButtonHideUnderline(
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
            onChanged: (value) {},
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    const tabs = ["roop"];
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            _dropdownlist("Execution Provider", "CPU", ["CPU", "GPU"]),
          ],
        );
    }
    return const SizedBox();
  }
}
