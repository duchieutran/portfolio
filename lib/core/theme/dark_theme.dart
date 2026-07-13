import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/extensions/app_theme_extension.dart';
import 'package:portfolio/core/theme/extensions/spacing_extension.dart';
import 'package:portfolio/core/theme/tokens/colors.dart';
import 'package:portfolio/core/theme/tokens/spacing.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  extensions: [
    const AppThemeExtension(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
    ),
    const SpacingExtension(
      xs: AppSpacing.xs,
      sm: AppSpacing.sm,
      md: AppSpacing.md,
      lg: AppSpacing.lg,
      xl: AppSpacing.xl,
    ),
  ],
);
