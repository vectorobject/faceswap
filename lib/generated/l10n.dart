// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `All`
  String get file_filter_type_all {
    return Intl.message(
      'All',
      name: 'file_filter_type_all',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get file_filter_type_img {
    return Intl.message(
      'Image',
      name: 'file_filter_type_img',
      desc: '',
      args: [],
    );
  }

  /// `GIF and Video`
  String get file_filter_type_gif_video {
    return Intl.message(
      'GIF and Video',
      name: 'file_filter_type_gif_video',
      desc: '',
      args: [],
    );
  }

  /// `Add Folder`
  String get add_folder {
    return Intl.message(
      'Add Folder',
      name: 'add_folder',
      desc: '',
      args: [],
    );
  }

  /// `Parent Folder`
  String get parent_folder {
    return Intl.message(
      'Parent Folder',
      name: 'parent_folder',
      desc: '',
      args: [],
    );
  }

  /// `Show in File Explorer`
  String get reveal_in_file_explorer {
    return Intl.message(
      'Show in File Explorer',
      name: 'reveal_in_file_explorer',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Detect Faces`
  String get detect_faces {
    return Intl.message(
      'Detect Faces',
      name: 'detect_faces',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Executing`
  String get executing {
    return Intl.message(
      'Executing',
      name: 'executing',
      desc: '',
      args: [],
    );
  }

  /// `Try to read service port from file:{path}`
  String try_to_read_service_port_from_file(Object path) {
    return Intl.message(
      'Try to read service port from file:$path',
      name: 'try_to_read_service_port_from_file',
      desc: '',
      args: [path],
    );
  }

  /// `Using port read from file：{port}`
  String using_port_read_from_file(Object port) {
    return Intl.message(
      'Using port read from file：$port',
      name: 'using_port_read_from_file',
      desc: '',
      args: [port],
    );
  }

  /// `Connection failed, restarting server`
  String get connection_failed_and_restart {
    return Intl.message(
      'Connection failed, restarting server',
      name: 'connection_failed_and_restart',
      desc: '',
      args: [],
    );
  }

  /// `Log`
  String get log {
    return Intl.message(
      'Log',
      name: 'log',
      desc: '',
      args: [],
    );
  }

  /// `Generating`
  String get generating {
    return Intl.message(
      'Generating',
      name: 'generating',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get generate {
    return Intl.message(
      'Generate',
      name: 'generate',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Enhance`
  String get face_enhance {
    return Intl.message(
      'Enhance',
      name: 'face_enhance',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get source {
    return Intl.message(
      'Source',
      name: 'source',
      desc: '',
      args: [],
    );
  }

  /// `Target`
  String get target {
    return Intl.message(
      'Target',
      name: 'target',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
