import 'dart:convert';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:board_game_app/data/models/settings.dart';

class SettingsController extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;
  static const _key = 'tessera_settings';

  String determineDefaultLanguage() {
    final Locale systemLocale = PlatformDispatcher.instance.locale;
    final String langCode = systemLocale.languageCode.toLowerCase();
    final String countryCode = systemLocale.countryCode?.toUpperCase() ?? '';

    if (['sr', 'hr', 'bs', 'me', 'sh'].contains(langCode) ||
        ['RS', 'HR', 'BA', 'ME'].contains(countryCode)) {
      return 'sr';
    }

    if (langCode == 'ru' || countryCode == 'RU') return 'ru';

    return 'en';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_key);

    if (rawData != null) {
      Map<String, dynamic> savedMap = jsonDecode(rawData);
      _settings = AppSettings.fromMap(savedMap);
    } else {
      String defaultLang = determineDefaultLanguage();
      _settings = AppSettings(
        languageCode: defaultLang,
        themeColor: AppThemeColor.linenTeal,
      );
      await _saveToDisk();
    }
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_settings.toMap()));
  }

  Future<void> updateSettings(AppSettings s) async {
    _settings = s;
    await _saveToDisk();
    notifyListeners();
  }
}

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
