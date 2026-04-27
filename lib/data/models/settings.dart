import 'package:flutter/material.dart';

enum AppThemeColor {
  linenTeal,
  warmSandTerracotta,
  creamOlive,
  warmWhiteDeepRed;

  String get displayName => switch (this) {
    AppThemeColor.linenTeal => 'Linen & Teal',
    AppThemeColor.warmSandTerracotta => 'Warm Sand & Terracotta',
    AppThemeColor.creamOlive => 'Cream & Olive',
    AppThemeColor.warmWhiteDeepRed => 'Warm White & Deep Red',
  };

  Color get primary => switch (this) {
    AppThemeColor.linenTeal => const Color.fromARGB(255, 46, 125, 107),

    AppThemeColor.warmSandTerracotta => const Color.fromARGB(255, 192, 82, 42),
    AppThemeColor.creamOlive => const Color.fromARGB(255, 92, 122, 62),
    AppThemeColor.warmWhiteDeepRed => const Color.fromARGB(255, 166, 50, 40),
  };

  Color get primaryDim => switch (this) {
    AppThemeColor.linenTeal => const Color.fromARGB(255, 28, 75, 64),
    AppThemeColor.warmSandTerracotta => const Color.fromARGB(255, 100, 49, 25),
    AppThemeColor.creamOlive => const Color.fromARGB(255, 55, 73, 37),
    AppThemeColor.warmWhiteDeepRed => const Color.fromARGB(255, 100, 30, 24),
  };

  Color get secondary => switch (this) {
    AppThemeColor.linenTeal => const Color.fromARGB(255, 192, 122, 47),
    AppThemeColor.warmSandTerracotta => const Color.fromARGB(255, 139, 105, 20),
    AppThemeColor.creamOlive => const Color.fromARGB(255, 196, 136, 42),
    AppThemeColor.warmWhiteDeepRed => const Color.fromARGB(255, 212, 148, 58),
  };

  Color get secondaryDim => switch (this) {
    AppThemeColor.linenTeal => const Color.fromARGB(255, 115, 73, 28),
    AppThemeColor.warmSandTerracotta => const Color.fromARGB(255, 83, 63, 12),
    AppThemeColor.creamOlive => const Color.fromARGB(255, 118, 82, 25),
    AppThemeColor.warmWhiteDeepRed => const Color.fromARGB(255, 127, 89, 35),
  };

  LinearGradient get scaffoldGradient => switch (this) {
    AppThemeColor.warmSandTerracotta => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 245, 240, 232),
        Color.fromARGB(255, 232, 224, 212),
      ],
    ),
    AppThemeColor.creamOlive => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 247, 244, 238),
        Color.fromARGB(255, 234, 229, 218),
      ],
    ),
    AppThemeColor.warmWhiteDeepRed => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 250, 246, 241),
        Color.fromARGB(255, 237, 229, 218),
      ],
    ),
    AppThemeColor.linenTeal => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 244, 239, 230),
        Color.fromARGB(255, 232, 224, 210),
      ],
    ),
  };
}

class AppSettings {
  AppThemeColor themeColor;

  AppSettings({this.themeColor = AppThemeColor.linenTeal});

  AppSettings copyWith({AppThemeColor? themeColor}) =>
      AppSettings(themeColor: themeColor ?? this.themeColor);

  Map<String, dynamic> toMap() => {'themeColor': themeColor.name};

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    themeColor: AppThemeColor.values.firstWhere(
      (e) => e.name == map['themeColor'],
      orElse: () => AppThemeColor.linenTeal,
    ),
  );
}
