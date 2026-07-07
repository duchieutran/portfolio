import 'package:intl/intl.dart';

import '../config/app_config.dart';

/// Tiện ích format 1 entry log thành chuỗi đẹp, dễ grep.
///
/// Format:
/// ```
/// ═══════════════════════════════════════════════════════════
/// [ERROR] 2026-07-05 14:33:21.123  |  Source: UI | Build
/// Tag: SubmitForm
/// Message: SocketException: Failed host lookup
/// ───────────────────────────────────────────────────────────
/// #0  UserRepository.fetchUser (...user_repository.dart:42:7)
/// #1  _MyHomePageState._onRefresh (...home_page.dart:78:5)
/// ═══════════════════════════════════════════════════════════
/// ```
class LogFormatter {
  LogFormatter._(); // private constructor — chỉ static methods

  static const String _topBorder =
      '═══════════════════════════════════════════════════════════';
  static const String _midBorder =
      '───────────────────────────────────────────────────────────';

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  /// Format 1 entry. Trả về chuỗi đã có \n ở cuối (sẵn sàng append vào file).
  static String format({
    required String level,    // DEBUG / INFO / WARN / ERROR / FATAL
    required String source,   // 'UI | Build', 'Isolate', v.v.
    required String tag,      // tag do caller cung cấp (vd: 'SubmitForm')
    required Object error,    // exception object
    StackTrace? stack,        // stack trace (có thể null)
  }) {
    final buffer = StringBuffer()
      ..writeln(_topBorder)
      ..writeln(
        '[$level] ${_dateFormat.format(DateTime.now())}  |  '
        'Source: $source',
      )
      ..writeln('Tag: $tag');

    // Cắt message nếu quá dài (AppConfig.maxErrorLines)
    final message = error.toString();
    final lines = message.split('\n');
    final truncated = lines.length > AppConfig.maxErrorLines
        ? '${lines.take(AppConfig.maxErrorLines).join('\n')}\n... (truncated)'
        : message;
    buffer.writeln('Message: $truncated');

    // Stack trace: chỉ giữ N dòng đầu
    if (stack != null) {
      buffer.writeln(_midBorder);
      final stackLines = stack.toString().split('\n');
      final max = AppConfig.maxTraceLines;
      final stackTruncated = stackLines.length > max
          ? '${stackLines.take(max).join('\n')}\n... (${stackLines.length - max} more lines)'
          : stack.toString();
      buffer.writeln(stackTruncated);
    }

    buffer.writeln(_topBorder);
    return buffer.toString();
  }
}
