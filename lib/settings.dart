import 'dart:convert';
import 'package:faceswap/server.dart';
import 'package:faceswap/status_bar.dart';

import 'field.dart';
import 'global.dart';

class ProviderItem {
  bool selected;
  String name;
  ProviderItem(this.name, this.selected);
  toJsonObj() {
    return {"name": name, "selected": selected};
  }
}

class ExecutionProvider extends Field<List<ProviderItem>> {
  List<String>? choices;
  ExecutionProvider(String fieldName) : super(fieldName, []);
  Future<void> init(Map<String, dynamic>? obj) async {
    List<ProviderItem> tempProviders = [];
    try {
      for (var item in obj?[fieldName]) {
        tempProviders.add(ProviderItem(item["name"], item["selected"]));
      }
    } catch (err) {
      print(err);
    }
    choices = await Server.getAvailableProviders();
    if (tempProviders.isEmpty) {
      tempProviders = [
        ProviderItem("CUDAExecutionProvider", true),
        ProviderItem("CPUExecutionProvider", true)
      ];
    }
    value.clear();
    for (var provider in tempProviders) {
      if (choicesContains(provider.name)) {
        value.add(provider);
      }
    }
    for (var provider in choices!) {
      if (!contains(provider)) {
        value.add(ProviderItem(provider, false));
      }
    }
    notifyListeners();
  }

  bool choicesContains(String providerName) {
    if (choices != null) {
      for (var item in choices!) {
        if (item == providerName) {
          return true;
        }
      }
    }
    return false;
  }

  bool contains(String providerName) {
    for (var item in value) {
      if (item.name == providerName) {
        return true;
      }
    }
    return false;
  }

  toJsonObj() {
    var arr = [];
    for (var item in value) {
      arr.add(item.toJsonObj());
    }
    return arr;
  }

  List<String> getSelectedNames() {
    List<String> arr = [];
    for (var item in value) {
      if (item.selected) {
        arr.add(item.name);
      }
    }
    return arr;
  }
}

class Settings {
  static ExecutionProvider executionProvider =
      ExecutionProvider("execution-provider");
  static RangedIntField executionThreads =
      RangedIntField("execution-threads", 1, min: 1, max: 50);
  static Field<bool> darkTheme = Field<bool>("dark-theme", true);
  static final List<Field> _all = [
    executionProvider,
    executionThreads,
    darkTheme
  ];

  static init() async {
    Map<String, dynamic>? obj;
    if (await Global.settingsFile.exists()) {
      var str = await Global.settingsFile.readAsString();
      try {
        obj = jsonDecode(str);
      } catch (err) {
        StatusBar.appendOutput(
            "Read ${Global.settingsFile.path} err:$err", true);
      }
    }
    darkTheme.readFromObj(obj);
    var hasThreads = executionThreads.readFromObj(obj);
    executionProvider.init(obj).then((_) {
      if (!hasThreads) {
        if (executionProvider.value.first.name == "CUDAExecutionProvider") {
          executionThreads.value = 8;
        }
      }
    });
  }

  static Future<void> save() async {
    var obj = {};
    for (var item in _all) {
      if (item is ExecutionProvider) {
        obj[item.fieldName] = item.toJsonObj();
      } else {
        obj[item.fieldName] = item.value;
      }
    }
    await Global.settingsFile.writeAsString(jsonEncode(obj));
  }
}
