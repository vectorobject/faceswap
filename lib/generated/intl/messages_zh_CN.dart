// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
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
  String get localeName => 'zh_CN';

  static String m0(path) => "尝试从文件读取服务端口:${path}";

  static String m1(port) => "使用从文件读取到的端口：${port}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_folder": MessageLookupByLibrary.simpleMessage("添加文件夹"),
        "close": MessageLookupByLibrary.simpleMessage("关闭"),
        "connection_failed_and_restart":
            MessageLookupByLibrary.simpleMessage("连接失败，重启服务中"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "detect_faces": MessageLookupByLibrary.simpleMessage("识别人脸"),
        "executing": MessageLookupByLibrary.simpleMessage("执行中"),
        "face_enhance": MessageLookupByLibrary.simpleMessage("增强"),
        "file_filter_type_all": MessageLookupByLibrary.simpleMessage("全部"),
        "file_filter_type_gif_video":
            MessageLookupByLibrary.simpleMessage("GIF和视频"),
        "file_filter_type_img": MessageLookupByLibrary.simpleMessage("图片"),
        "generate": MessageLookupByLibrary.simpleMessage("生成"),
        "generating": MessageLookupByLibrary.simpleMessage("生成中"),
        "log": MessageLookupByLibrary.simpleMessage("日志"),
        "parent_folder": MessageLookupByLibrary.simpleMessage("上层文件夹"),
        "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "result": MessageLookupByLibrary.simpleMessage("结果"),
        "reveal_in_file_explorer":
            MessageLookupByLibrary.simpleMessage("在资源管理器中显示"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "source": MessageLookupByLibrary.simpleMessage("源"),
        "target": MessageLookupByLibrary.simpleMessage("目标"),
        "try_to_read_service_port_from_file": m0,
        "using_port_read_from_file": m1,
        "video": MessageLookupByLibrary.simpleMessage("视频")
      };
}
