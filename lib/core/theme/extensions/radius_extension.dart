import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

@immutable
class RadiusExtension extends ThemeExtension<RadiusExtension> {
  /// Radius nhỏ — chip, tag, badge.
  final double sm;

  /// Radius vừa — button, input.
  final double md;

  /// Radius lớn — card, bottom sheet.
  final double lg;

  /// Radius rất lớn — dialog, modal tròn.
  final double xl;

  const RadiusExtension({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  // Convenience getters — dùng trực tiếp trong UI.
  BorderRadius get brSm => BorderRadius.circular(sm);
  BorderRadius get brMd => BorderRadius.circular(md);
  BorderRadius get brLg => BorderRadius.circular(lg);
  BorderRadius get brXl => BorderRadius.circular(xl);

  Radius get radiusSm => Radius.circular(sm);
  Radius get radiusMd => Radius.circular(md);
  Radius get radiusLg => Radius.circular(lg);
  Radius get radiusXl => Radius.circular(xl);

  @override
  RadiusExtension copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return RadiusExtension(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  RadiusExtension lerp(
    ThemeExtension<RadiusExtension>? other,
    double t,
  ) {
    if (other is! RadiusExtension) return this;

    return RadiusExtension(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
    );
  }
}