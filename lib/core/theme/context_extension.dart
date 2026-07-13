import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/extensions/app_theme_extension.dart';
import 'package:portfolio/core/theme/extensions/radius_extension.dart';
import 'package:portfolio/core/theme/extensions/spacing_extension.dart';
import 'package:portfolio/core/theme/extensions/typography_extension.dart';

extension ThemeContext on BuildContext {
  ThemeData get themeData => Theme.of(this);

  AppThemeExtension get theme => themeData.extension<AppThemeExtension>()!;

  SpacingExtension get spacing => themeData.extension<SpacingExtension>()!;

  RadiusExtension get radius => themeData.extension<RadiusExtension>()!;

  TypographyExtension get typography =>
      themeData.extension<TypographyExtension>()!;
}
