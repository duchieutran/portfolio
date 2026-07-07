/// Phân chia thành các phần
///
/// I. Xử lý lỗi: Tập trung các hằng số cấu hình của hệ thống xử lý lỗi.

class AppConfig {
  AppConfig._(); // private constructor - không cho phép tạo instance

  // ────────── Hằng số Xử lý lỗi ───────────────────────────
  /// tên file name
  static const String logFileName = 'portfolio.log';

  /// thời gian rotate (3 ngày)
  static const Duration logRetenionPeriod = Duration(days: 3);

  // ─── Stack trace ───────────────────────────────────────────
  /// Số dòng stack trace tối đa giữ lại cho mỗi entry.
  /// Frame sâu hơn thường là framework noise.
  static const int maxTraceLines = 21;

  /// Số dòng "message" tối đa (khi lỗi quá dài).
  static const int maxErrorLines = 10;

  // ─── Log level ──────────────────────────────────────────────
  /// 5 mức log. Dùng để format header + lọc nếu cần.
  static const String levelDebug = 'DEBUG';
  static const String levelInfo = 'INFO';
  static const String levelWarn = 'WARN';
  static const String levelError = 'ERROR';
  static const String levelFatal = 'FATAL';

  // ─── Bộ lọc lỗi ────────────────────────────────────────────
  /// Mã response HTTP không cần log (vd: 401 khi chưa login là bình thường).
  static const List<int> dontLogErrorResponseCodes = <int>[
    // 100201, // ví dụ: mã custom của dự án
  ];
}
