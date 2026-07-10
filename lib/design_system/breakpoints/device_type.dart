import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static DeviceType device(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Kích thước chiều rộng nhỏ hơn 600 => mobile
    if (width < 600) {
      return DeviceType.mobile;
    }

    // Kích thước chiều rộng 600 -> 1024 => tablet
    if (width < 1024) {
      return DeviceType.tablet;
    }

    // Kích thước cao hơn 1024 => desktop
    return DeviceType.desktop;
  }
}
