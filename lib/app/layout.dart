import 'package:flutter/material.dart';

class Layout {
  Layout._();

  static double _width = 390;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _width = size.width;
  }

  // Scale factor based on 390px design width (iPhone 14 / Pixel 8 logical width)
  static double get _s => (_width / 390).clamp(0.75, 1.25);

  // Tighter clamp for fonts than spacing
  static double get _fs => (_width / 390).clamp(0.85, 1.1);
  static double fv(double val) => val * _fs;

  static bool get isSmall => _width < 360;
  static bool get isLarge => _width > 420;

  // Scaled values
  static double v(double val) => val * _s;

  // Font sizes
  static double get size10 => fv(10);
  static double get size12 => fv(12);
  static double get size14 => fv(14);
  static double get size16 => fv(16);
  static double get size18 => fv(18);
  static double get size20 => fv(20);
  static double get size22 => fv(22);

  // SizedBoxes
  static Widget heightBox(double val) => SizedBox(height: v(val));
  static Widget widthBox(double val) => SizedBox(width: v(val));

  // EdgeInsets
  static EdgeInsets all(double val) => EdgeInsets.all(v(val));
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: v(horizontal), vertical: v(vertical));
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: v(left),
    top: v(top),
    right: v(right),
    bottom: v(bottom),
  );
  static EdgeInsets fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) => EdgeInsets.fromLTRB(v(left), v(top), v(right), v(bottom));
}
