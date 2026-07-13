import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/dark_theme.dart';

import 'package:portfolio/core/theme/light_theme.dart';
// Bỏ comment dòng dưới sau khi tạo dark_theme.dart:
// import 'package:portfolio/core/theme/dark_theme.dart';

/// Entry point tập trung cho theme system.
///
/// Dùng trong [MaterialApp]:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,        // bật sau khi tạo dark_theme.dart
///   themeMode: ThemeMode.system,
///   home: ...,
/// )
/// ```
abstract final class AppTheme {
  // Ngăn instantiation — class chỉ chứa static members.
  AppTheme._();

  /// Theme cho Brightness.light.
  static ThemeData get light => lightTheme;

  /// Theme cho Brightness.dark.
  // Bỏ comment getter dưới sau khi tạo dark_theme.dart:
  static ThemeData get dark => darkTheme;
}
