/// Service xử lý lỗi tập trung — single sink cho mọi lỗi trong app.
///
/// API public:
/// - [initGlobalErrorHandler] — gọi 1 lần trong main(), trước runApp().
/// - [record] — gọi khi business code muốn log lỗi.
///
/// Mọi thao tác ghi file đều đi qua [_queue] để tránh race condition.
class ErrorService {
  /// Tài liệu đọc hiểu:
  /// Trong Flutter về cơ bản có 4 loại nguồn lỗi khác nhau, mỗi nguồn cần có một cơ chế bắt lỗi riêng để bắt lỗi riêng.
  /// 4 nguồn khác nhau bao gồm:
  /// - UI/Build (Lỗi được bắt trong hàm build(), layout, paint.):
  ///     + Sử dụng -> Flutter.onError
  /// - Native platform (App bị crash từ native code (Java, Kotlin, Swift) đẩy lên)
  ///     + Sử dụng -> PlatformDispatcher.instance.onError
  /// - Background isolate (Lỗi trong compute() hoặc isolate khác):
  ///     + Sử dụng -> Isolate.current.addErrorListener
  /// - Async ngoài zone (Future lỗi không ai await/catch):
  ///     + Sử dụng runZonedGuarded

  ErrorService._();

  static const List<String> _excludedErrors = <String>[];

  static bool _isExcluded(String message) {
    return _excludedErrors.any((pattern) => message.contains(pattern));
  }

  static 

  
}
