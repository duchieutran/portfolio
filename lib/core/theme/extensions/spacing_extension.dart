import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

@immutable
class SpacingExtension extends ThemeExtension<SpacingExtension> {
  final double xs;

  final double sm;

  final double md;

  final double lg;

  final double xl;

  const SpacingExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  @override
  SpacingExtension copyWith() => this;

  @override
  SpacingExtension lerp(
    ThemeExtension<SpacingExtension>? other,
    double t,
  ) {
    if (other is! SpacingExtension) return this;

    return SpacingExtension(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
    );
  }
}
