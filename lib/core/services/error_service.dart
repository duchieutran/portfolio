import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'package:flutter/foundation.dart';
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
    // 1. UI/ BUILD/ LAYOUT/ PAINT
    FlutterError.onError = (detail) {
      _logError('UI', detail.exception, detail.stack ?? StackTrace.current);
      FlutterError.presentError(detail);
    };

    // 2. PLATFORM/ NATIVE CALLBACK/ MAIN-ISOLATE ROOT
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError("Platform", error, stack);
      return true;
    };

    return runZonedGuarded<Future<void>>(
      () async {
        // Đảm bảo Flutter binding đã được khởi tạo trước khi chạy ứng dụng.
        WidgetsFlutterBinding.ensureInitialized();

        // 3. ASYNC/ FUTURE/ STREAM
        if (!kIsWeb) {
          Isolate.current.addErrorListener(
            RawReceivePort((dynamic pair) {
              final list = pair as List<dynamic>;
              final error = list[0];
              final stackStr = list.length > 1 ? list[1] as String : '';

              _logError(
                'Isolate',
                error ?? 'Unknown',
                StackTrace.fromString(stackStr),
              );
            }).sendPort,
          );
        }

        await app();
      },
      // Hàm callback được gọi khi phát hiện lỗi không đồng bộ trong zone.
      (error, stack) {
        // Chuyển lỗi tới bộ xử lý lỗi mặc định của Flutter.
        _logError("Zone", error, stack);
      },
    );
  }

  // Log error tạm thời cho dev
  static void _logError(String source, Object error, StackTrace stack) {
    const border = "================================================";
    final ts = DateTime.now().toIso8601String();
    final buffer = StringBuffer()
      ..writeln(border)
      ..writeln("[ERROR] $ts  |   Source: $source")
      ..writeln("Message: $error")
      ..writeln(border)
      ..writeln(stack.toString())
      ..write(border);

    developer.log(
      buffer.toString(),
      name: 'ErrorService',
      level: 1000,
      error: error,
      stackTrace: stack,
    );
  }
}
