import 'dart:async';

import 'package:flutter/material.dart';

/// Dịch vụ xử lý lỗi toàn cục của ứng dụng.
///
/// Cung cấp cơ chế bắt và xử lý các lỗi phát sinh trong quá trình
/// ứng dụng chạy, bao gồm cả những lỗi bất đồng bộ (async) mà
/// Flutter framework không thể tự đón bắt được.
class ErrorService {
  // Constructor riêng tư để ngăn việc tạo instance từ bên ngoài,
  // đảm bảo ErrorService hoạt động theo mô hình singleton.
  ErrorService._();

  /// Khởi tạo bộ xử lý lỗi toàn cục và chạy ứng dụng bên trong nó.
  ///
  /// Phương thức này bọc [app] trong một [runZonedGuarded] zone, giúp
  /// chặn và xử lý mọi lỗi không mong muốn trong suốt vòng đời ứng dụng:
  ///
  /// - [WidgetsFlutterBinding.ensureInitialized] đảm bảo Flutter binding
  ///   đã sẵn sàng trước khi gọi [app].
  /// - Khi có lỗi xảy ra, [FlutterError.presentError] sẽ chuyển lỗi tới
  ///   bộ xử lý mặc định của Flutter để hiển thị hoặc ghi log.
  ///
  /// Tham số:
  /// - [app]: Hàm khởi chạy ứng dụng (ví dụ: `runApp`).
  static Future<void> initGlobalErrorHandler(
    Future<void> Function() app,
  ) async {
    return runZonedGuarded<Future<void>>(
      () async {
        // Đảm bảo Flutter binding đã được khởi tạo trước khi chạy ứng dụng.
        WidgetsFlutterBinding.ensureInitialized();
        await app();
      },
      // Hàm callback được gọi khi phát hiện lỗi không đồng bộ trong zone.
      (error, stack) {
        // Chuyển lỗi tới bộ xử lý lỗi mặc định của Flutter.
        FlutterError.presentError(
          FlutterErrorDetails(exception: error, stack: stack),
        );
      },
    );
  }
}
