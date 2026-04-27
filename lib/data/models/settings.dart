import 'package:flutter/material.dart';
import 'package:board_game_app/localization/localization.dart';

enum AppThemeColor {
  orange;

  Color get primary => switch (this) {
    AppThemeColor.orange => const Color.fromARGB(255, 224, 141, 32),
  };

  Color get primaryDim => switch (this) {
    AppThemeColor.orange => const Color.fromARGB(255, 50, 37, 17),
  };
}

class AppSettings {
  AppThemeColor themeColor;

  AppSettings({this.themeColor = AppThemeColor.orange});

  // Implement the copyWith method here

  Map<String, dynamic> toMap() => {};

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings();
}
