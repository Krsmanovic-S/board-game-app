import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/settings.dart';

class SettingsController extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  Future<void> load() async {
    //_settings = await AppDatabase.getSettings();
    _settings = AppSettings();
  }

  Future<void> updateSettings(AppSettings s) async {
    _settings = s;
    //await AppDatabase.saveSettings(s);
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
