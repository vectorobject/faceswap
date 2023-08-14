// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(path) => "Try to read service port from file:${path}";

  static String m1(port) => "Using port read from file：${port}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_folder": MessageLookupByLibrary.simpleMessage("Add Folder"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "connection_failed_and_restart": MessageLookupByLibrary.simpleMessage(
            "Connection failed, restarting server"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "detect_faces": MessageLookupByLibrary.simpleMessage("Detect Faces"),
        "executing": MessageLookupByLibrary.simpleMessage("Executing"),
        "face_enhance": MessageLookupByLibrary.simpleMessage("Enhance"),
        "file_filter_type_all": MessageLookupByLibrary.simpleMessage("All"),
        "file_filter_type_gif_video":
            MessageLookupByLibrary.simpleMessage("GIF and Video"),
        "file_filter_type_img": MessageLookupByLibrary.simpleMessage("Image"),
        "generate": MessageLookupByLibrary.simpleMessage("Generate"),
        "generating": MessageLookupByLibrary.simpleMessage("Generating"),
        "log": MessageLookupByLibrary.simpleMessage("Log"),
        "parent_folder": MessageLookupByLibrary.simpleMessage("Parent Folder"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "result": MessageLookupByLibrary.simpleMessage("Result"),
        "reveal_in_file_explorer":
            MessageLookupByLibrary.simpleMessage("Show in File Explorer"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "source": MessageLookupByLibrary.simpleMessage("Source"),
        "target": MessageLookupByLibrary.simpleMessage("Target"),
        "try_to_read_service_port_from_file": m0,
        "using_port_read_from_file": m1,
        "video": MessageLookupByLibrary.simpleMessage("Video")
      };
}
