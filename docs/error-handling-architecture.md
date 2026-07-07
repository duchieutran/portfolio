# Quy trình xây dựng bộ xử lý lỗi (Error Handling System)

> Tài liệu tham chiếu nội bộ, tổng hợp từ module `error_service.dart` của dự án Vivas BHTM. Mục tiêu: chuẩn hoá cách xây dựng hệ thống xử lý lỗi áp dụng được cho mọi dự án Flutter (và các nền tảng khác).

---

## Mục lục

1. [Mục tiêu & nguyên tắc cốt lõi](#1-mục-tiêu--nguyên-tắc-cốt-lõi)
2. [Quy trình xây dựng 7 bước](#2-quy-trình-xây-dựng-7-bước)
3. [Kiến trúc chuẩn](#3-kiến-trúc-chuẩn)
4. [Triển khai chi tiết từng lớp](#4-triển-khai-chi-tiết-từng-lớp)
5. [Checklist chất lượng](#5-checklist-chất-lượng)
6. [Hướng phát triển mở (Roadmap)](#6-hướng-phát-triển-mở-roadmap)
7. [Câu hỏi thường gặp](#7-câu-hỏi-thường-gặp)
8. [Phụ lục: đoạn mã mẫu](#8-phụ-lục-đoạn-mã-mẫu)

---

## 1. Mục tiêu & nguyên tắc cốt lõi

### 1.1. Mục tiêu

| # | Mục tiêu | Mô tả |
|---|----------|--------|
| 1 | **Không mất lỗi** | Mọi lỗi phát sinh trong app đều phải được ghi nhận, không bị nuốt. |
| 2 | **Dễ truy vết** | Mỗi lỗi đi kèm: thời gian, loại nguồn, message, stack trace, payload liên quan. |
| 3 | **An toàn vận hành** | Không làm crash app; tách tác vụ nặng (ghi file, nén, upload) sang isolate. |
| 4 | **Có thể xuất ra ngoài** | Người dùng hoặc tester có thể lấy log gửi cho dev. |
| 5 | **Tách biệt khỏi business logic** | Business code chỉ "bắn" lỗi; ErrorService xử lý hậu trường. |

### 1.2. Nguyên tắc cốt lõi (5 "BẤT")

- **Bất khả phân tán** — Không log rải rác trong business code; một điểm đến duy nhất.
- **Bất khả xung đột** — Nhiều lỗi đồng thời? Phải serialize khi ghi file.
- **Bất khả phình to** — File log phải có cơ chế rotate (theo ngày / theo dung lượng).
- **Bất khả rò rỉ PII** — Không ghi nhạy cảm (mật khẩu, số thẻ, CCCD, JWT…).
- **Bất khả tải UI** — I/O / upload phải chạy isolate, không block main thread.

---

## 2. Quy trình xây dựng 7 bước

```
┌──────────────────────────┐
│  1. Liệt kê nguồn lỗi   │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  2. Chọn cấu trúc lưu   │
│     trữ log             │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  3. Xây hàng đợi tuần   │
│     tự (ghi file)       │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  4. Viết init Global     │
│     Error Handler        │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  5. Bộ lọc nhiễu &       │
│     whitelist/blacklist  │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  6. Cơ chế xuất /        │
│     share log            │
└──────────┬───────────────┘
           │
┌──────────▼───────────────┐
│  7. Bọc ở main.dart +   │
│     Logger façade        │
└──────────────────────────┘
```

### Bước 1 — Liệt kê nguồn lỗi

Trong Flutter, tối thiểu có 4 nguồn sau. Khi thêm SDK mới (Riverpod, Firebase, Drift…), đánh dấu xem SDK đó có hook lỗi riêng không:

| Nguồn | Hook |
|-------|------|
| UI / Build | `FlutterError.onError` |
| Native platform | `PlatformDispatcher.instance.onError` |
| Background isolate | `Isolate.current.addErrorListener` |
| Async ngoài zone | `runZonedGuarded` |

### Bước 2 — Chọn cấu trúc lưu trữ

Quyết định dựa trên ngữ cảnh:

| Lựa chọn | Ưu | Nhược |
|----------|----|-------|
| **File text trong app dir** | Đơn giản, làm chủ hoàn toàn | Phải tự xử lý rotate |
| **SQLite** | Truy vấn, lọc theo level/time dễ | Thêm dependency, schema migration |
| **Hệ thống log (logcat/Console)** | Tích hợp DevTool tốt | Không lưu lại lâu, khó share |
| **Remote (Sentry/Crashlytics)** | Có thống kê, nhóm lỗi | Cần mạng, PII risk |

**Khuyến nghị:** luôn có **1 file log on-device** (lưu dài hạn) + tuỳ chọn push remote song song ở môi trường production.

### Bước 3 — Hàng đợi tuần tự

Tại sao cần:
- `File.writeAsString` không thread-safe. Nếu 3 lỗi đến cùng lúc → có thể ghi đè.
- Ngay cả trong Dart đơn isolate, I/O `await` có thể chen ngang thứ tự kết thúc.

Giải pháp:

```dart
class SequentialTaskQueue {
  final _queue = <Future<void> Function()>[];
  bool _running = false;

  Future<void> add(Future<void> Function() job) {
    _queue.add(job);
    if (!_running) _runNext();
    return Future.value();
  }

  Future<void> _runNext() async {
    _running = true;
    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      try { await job(); } catch (_) { /* nuốt để không chặn queue */ }
    }
    _running = false;
  }
}
```

### Bước 4 — Init Global Error Handler

Khởi tạo **một lần duy nhất** ở `main.dart`, **trước `runApp()`**:

```dart
Future<void> main() async {
  await ErrorService.initGlobalErrorHandler(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  });
}
```

`runZonedGuarded` bảo vệ phần còn lại khỏi lỗi async không ai bắt.

### Bước 5 — Bộ lọc nhiễu

Một số lỗi **không phải lỗi thật** — là tình trạng bình thường trong runtime:

```dart
const _excludedErrors = [
  'PlatformException(media open error, invalid or unsupported media…)',
  'A RenderFlex overflowed by',  // layout chỉ là cosmetic
  'MissingPluginException(No implementation found for method …)',
];
```

Nên có danh sách blacklist có thể cấu hình qua `AppConfig`. Ngược lại có **whitelist** cho những lỗi đã biết nhưng muốn đặc biệt theo dõi.

### Bước 6 — Cơ chế xuất / chia sẻ log

Thiết kế hàm `downloadLog(targetPath)` dùng `compute()` (isolate riêng) để copy file. Cho phép:
- Chia sẻ qua `share_plus` (Android/iOS/Desktop).
- Lưu vào `Downloads` hoặc thư mục người dùng chọn.
- Tự động zip khi file > 1MB.

### Bước 7 — Logger façade & boot ở `main.dart`

Cuối cùng, tạo **Logger** đơn giản để dev gọi nhanh:

```dart
Logger.log('user tap submit');
Logger.warn('slow API', writeLog: true);
Logger.error(exception, writeLog: true);
```

`writeLog: true` mới đẩy xuống file; bằng không chỉ in console có màu.

---

## 3. Kiến trúc chuẩn

```
┌─────────────────────────────────────────────────┐
│                  main.dart                       │
│  ErrorService.initGlobalErrorHandler(boot)       │
└─────────────────────┬───────────────────────────┘
                      │
   ┌──────────────────┴────────────────────┐
   │                                       │
┌──▼─────────────┐  ┌─────────────────────▼──┐
│ FlutterError    │  │ PlatformDispatcher      │
│ .onError        │  │ .instance.onError        │
└──┬─────────────┘  └────────┬─────────────────┘
┌──▼─────────────┐  ┌────────▼─────────────────┐
│ Isolate.add    │  │ runZonedGuarded          │
│ ErrorListener  │  │ (unhandled async)        │
└──┬─────────────┘  └────────┬─────────────────┘
   │            ┌─────────────┘
   │            │
┌──▼────────────▼─────────────────┐
│   ErrorService.record(type,..) │
│      ↓                          │
│   SequentialTaskQueue.add(…)    │
│      ↓                          │
│   File.writeAsString(append)    │
└─────────────────────────────────┘
                  │
                  ▼
        galaxy_bhxh.log (rotate mỗi 3 ngày)
                  │
                  ▼
   downloadLog() → compute() → copy sang user dir
```

---

## 4. Triển khai chi tiết từng lớp

### 4.1. Lớp 1 — `error_service.dart`

```dart
class ErrorService {
  ErrorService._(); // private constructor
  static File? _logFile;
  static String? get logPath => _logFile?.path;

  static final _excludedErrors = [...];
  static final _queue = SequentialTaskQueue();

  static Future<void> initGlobalErrorHandler(
      Future<void> Function() app) async {
    return runZonedGuarded(() async {
      await _initLogFile();
      FlutterError.onError = (d) {
        if (!kReleaseMode) FlutterError.presentError(d);
        record('UI | Build', d.exception, d.stack ?? StackTrace.current);
      };
      PlatformDispatcher.instance.onError = (e, s) {
        FlutterError.presentError(FlutterErrorDetails(exception: e, stack: s));
        record('Uncaught | Platform', e, s);
        return true;
      };
      if (!kIsWeb) {
        Isolate.current.addErrorListener(
          RawReceivePort((pair) {
            final data = pair as List;
            record('Isolate', data.first,
                StackTrace.fromString(data.last.toString()));
          }).sendPort,
        );
      }
      await app();
    }, (e, s) {
      record('Asynchronous', e, s);
    });
  }
}
```

### 4.2. Lớp 2 — Sequential Task Queue

Xem [Bước 3](#bước-3--hàng-đợi-tuần-tự). Hai tính năng cần thêm sau:
- `cancelAndReset()` — khi logout/clear-data
- `dispose()` — khi app huỷ test/teardown

### 4.3. Lớp 3 — Logger façade

5 level nên có: `DEBUG / INFO / WARN / ERROR / FATAL`. Format gợi ý:

```text
═══╡ [ERROR] 2026-07-05 14:33:21 ╞═══
[SubmitForm] SocketException: Failed host lookup
Stack trace…
```

### 4.4. Lớp 4 — File rotation

Có 2 chiến lược; chọn 1 hoặc kết hợp:

- **Theo thời gian** (mà module hiện tại dùng): file có header timestamp; nếu cũ hơn N ngày → tạo mới.
- **Theo dung lượng**: nếu file > 5MB → rename thành `.log.1`, `.log.2` và tạo file mới.

### 4.5. Lớp 5 — Cấu hình tập trung

`AppConfig` chứa **mọi con số** để dev không phải đào mã nguồn để chỉnh:

```dart
class AppConfig {
  static const LOG_FILE_RETENTION_PERIOD = Duration(days: 3);
  static const LOG_FILE_MAX_TRACE_LINES = 21;
  static const LOG_ERROR_MAX_LINES = 10;
  static const DONT_LOG_ERROR_RESPONSE_CODES = [100201];
}
```

---

## 5. Checklist chất lượng

### 5.1. Trước khi đẩy lên production

- [ ] Đăng ký đủ 4 nguồn lỗi (UI/Platform/Isolate/Async)
- [ ] File log có rotate (tránh đầy disk)
- [ ] Có bộ lọc lỗi nhiễu (`_excludedErrors`)
- [ ] Tất cả ghi file chạy qua queue tuần tự
- [ ] Không ghi PII (mật khẩu, JWT, OTP, số thẻ, CCCD)
- [ ] Tác vụ export/share dùng `compute()` / isolate
- [ ] Trên web (`kIsWeb`) không gọi path_provider `getApplicationSupportDirectory()`
- [ ] `kReleaseMode` — đảm bảo `FlutterError.presentError` không in lộ stack ra console user
- [ ] Có cơ chế share log ra ngoài cho người dùng cuối
- [ ] AppConfig tách hằng số ra ngoài, dễ chỉnh

### 5.2. Testing

- [ ] Ép throw ở `main.dart` xem log ghi đúng.
- [ ] Throw trong `compute()` → isolate listener có bắt?
- [ ] Throw trong `Future.delayed` bên ngoài zone → `runZonedGuarded` bắt?
- [ ] Đổi ngày hệ thống → file mới được tạo?
- [ ] Stress test: throw 100 lỗi liên tiếp → log đủ 100 dòng, đúng thứ tự?

---

## 6. Hướng phát triển mở (Roadmap)

> Những mục **chưa có** trong module hiện tại. Ưu tiên đánh theo thứ tự để áp dụng tuỳ quy mô dự án.

### 6.1. Giai đoạn 1 — Nền tảng (đã có)

- ✅ Single sink 4 nguồn lỗi
- ✅ File log có rotate
- ✅ Hàng đợi tuần tự
- ✅ Logger façade 3 level
- ✅ Download log qua isolate

### 6.2. Giai đoạn 2 — Mở rộng lưu trữ

- [ ] **SQLite cho log**: thay file phẳng, hỗ trợ truy vấn theo thời gian / level / tag.
- [ ] **Cấu trúc thư mục** `logs/yyyy-MM-dd/`, mỗi ngày 1 file.
- [ ] **Nén gzip** khi export: file > 500KB → tự `gzip`.
- [ ] **Sampling log** ở production: chỉ giữ 1/10 lỗi giống nhau → giảm tải đĩa.

### 6.3. Giai đoạn 3 — Bảo mật & PII

- [ ] **Regex redactor** cho PII:
  ```dart
  final redacted = message.replaceAllMapped(
    RegExp(r'\b\d{12}\b'),         // CCCD 12 số
    (_) => '***CCCĐ***',
  );
  ```
- [ ] **Mã hoá file log** bằng AES khi lưu.
- [ ] **Vai trò & mức log**: dev có thể bật DEBUG, user chỉ thấy INFO trở lên.
- [ ] Chữ ký số trên file log → chống giả mạo khi gửi qua CSKH.

### 6.4. Giai đoạn 4 — Tích hợp remote

- [ ] **Crashlytics / Sentry**: hook song song với file local; khi có mạng → batch upload.
- [ ] **Remote config** để bật/tắt cờ `writeLog` từ xa.
- [ ] **Feature flag**: `forceReportError` để dev chủ động upload log.
- [ ] **A/B testing**: 10% user gửi log DEBUG, còn lại chỉ ERROR.

### 6.5. Giai đoạn 5 — Trải nghiệm

- [ ] **Màn hình DevTools**: trong app, hiện danh sách lỗi gần đây (debug build).
- [ ] **Chia sẻ 1 chạm**: nút "Gửi log cho CSKH" → share file qua `share_plus`.
- [ ] **Tìm & lọc log** ngay trong app: input → search file log realtime.
- [ ] **Widget overlay**: chỉ báo góc màn hình khi log có lỗi mới.

### 6.6. Giai đoạn 6 — Platform-native

- [ ] **iOS — OSLog**: forward từ Swift/ObjC log sang `ErrorService`.
- [ ] **Android — Logcat**: forward từ Kotlin/Java.
- [ ] **Web — sentry-js / rollbar**: chuyên biệt cho `kIsWeb`.
- [ ] **Desktop — log file rotation theo dung lượng** (vì user thường để app chạy tháng).

### 6.7. Giai đoạn 7 — Phân tích nâng cao

- [ ] **Fingerprinting stack trace** → nhóm các lỗi giống nhau.
- [ ] **Time-series thống kê**: biểu đồ số lỗi theo ngày.
- [ ] **Anomaly detection**: cảnh báo khi 1 loại lỗi tăng đột biến.
- [ ] **Tự động tạo GitHub Issue** kèm log khi lỗi fatal.

---

## 7. Câu hỏi thường gặp

**Hỏi:** Có nên log ra console vẫn dùng `print()`?
**Đáp:** Không. Dùng `dart:developer` `log()` để tích hợp DevTools, có filter, có level. Và bọc bằng `Logger` façade để có màu và `writeLog`.

**Hỏi:** Có cần ghi log ở console song song với file không?
**Đáp:** Có. Console giúp dev debug runtime; file phục vụ truy vết sau. Ghi cả hai với `writeLog: true` cho production, không cần ở dev.

**Hỏi:** Rotate theo thời gian hay theo dung lượng?
**Đáp:** Theo **thời gian** dễ cài, phù hợp app thường. Theo **dung lượng** phù hợp app chạy nền lâu (messenger, foreground service). Có thể kết hợp: đếm cả 2, đạt ngưỡng nào trước thì rotate.

**Hỏi:** Stack trace dài quá có nên cắt bớt không?
**Đáp:** Có. `LOG_FILE_MAX_TRACE_LINES` nên đặt 10–25 dòng. Frame sâu hơn thường là framework noise, không cần thiết cho 90% trường hợp.

**Hỏi:** Làm sao test module này?
**Đáp:** Test 5 kịch bản:
1. Throw ở UI → log có `[UI | Build]`
2. Throw ở Future bên ngoài zone → log có `[Asynchronous]`
3. Throw ở `compute()` → log có `[Isolate]`
4. Throw 100 lần liên tục → log đủ, đúng thứ tự
5. Đổi system date > retention → file mới được tạo

---

## 8. Phụ lục: đoạn mã mẫu

### 8.1. `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.0
  path: ^1.8.3
  intl: ^0.19.0
  share_plus: ^10.0.0      # tuỳ chọn
```

### 8.2. `main.dart` tối thiểu

```dart
import 'package:flutter/widgets.dart';
import 'core/services/error_service.dart';

Future<void> main() async {
  await ErrorService.initGlobalErrorHandler(_boot);
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

### 8.3. Gọi trong business code

```dart
try {
  final res = await dio.get('/users');
} catch (e, s) {
  ErrorService.record('UserList', e, s);
  // hoặc dùng façade:
  Logger.error(e, tag: 'UserList', writeLog: true);
  rethrow;
}
```

### 8.4. Share log từ button

```dart
ElevatedButton(
  onPressed: () async {
    final dir = await getApplicationDocumentsDirectory();
    final path = await ErrorService.downloadLog(dir.path);
    if (path != null) await Share.shareXFiles([XFile(path)]);
  },
  child: const Text('Gửi log cho CSKH'),
);
```

---

## Changelog nội bộ

| Phiên bản | Ngày | Thay đổi |
|-----------|---------|-----------|
| 1.0 | 2026-07-05 | Khởi tạo tài liệu từ module `error_service.dart` (Vivas BHTM) |

---

> **Ghi nhớ cuối cùng:** Một bộ xử lý lỗi tốt **không phải là thứ người dùng thấy**, mà là thứ **cứu bạn vào lúc 2 giờ sáng** khi production crash. Đầu tư cho nó sớm, bạn sẽ trả ơn chính mình.
