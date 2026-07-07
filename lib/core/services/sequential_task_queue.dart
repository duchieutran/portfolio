/// Hàng đợi tuần tự — đảm bảo các job chạy theo thứ tự, không chen ngang.
///
/// Dùng để serialize các thao tác ghi file log, tránh race condition
/// khi nhiều lỗi xảy ra đồng thời.
class SequentialTaskQueue {
  /// Danh sách job đang chờ. Mỗi job là một closure trả về Future<void>.
  final List<Future<void> Function()> _queue = [];

  /// Cờ báo: có đang xử lý job không?
  /// Tránh gọi _runNext() nhiều lần khi add() nhiều job liên tiếp.
  bool _running = false;

  /// Thêm một job vào cuối hàng đợi.
  ///
  /// Job sẽ chạy theo thứ tự thêm vào. Nếu queue đang rảnh,
  /// job này chạy ngay; nếu không, phải đợi các job trước xong.
  ///
  /// Trả về Future.value() ngay — KHÔNG đợi job chạy xong.
  /// (Lý do: ErrorService không nên block vì ghi log.)
  Future<void> add(Future<void> Function() job) {
    _queue.add(job);
    if (!_running) {
      _runNext();
    }
    return Future.value();
  }

  /// Lặp qua queue cho đến khi hết job.
  /// Được gọi nội bộ — không nên gọi từ ngoài.
  Future<void> _runNext() async {
    _running = true;
    while (_queue.isNotEmpty) {
      // removeAt(0) = lấy job đầu hàng (FIFO — First In First Out).
      final job = _queue.removeAt(0);
      try {
        await job();
      } catch (_) {
        // Nuốt lỗi để không chặn queue.
        // Lỗi ghi file sẽ được ErrorService ghi nhận riêng nếu cần.
      }
    }
    _running = false;
  }

  /// Reset queue — dùng khi logout/clear data, bỏ mọi job đang chờ.
  void cancelAndReset() {
    _queue.clear();
  }

  /// Đánh dấu ngừng hoạt động — dùng khi teardown (test, app dispose).
  void dispose() {
    _queue.clear();
    _running = false;
  }
}
