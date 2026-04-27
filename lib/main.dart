import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/app/router.dart';
import 'package:board_game_app/utils/tip_service.dart';
import 'package:board_game_app/providers/tip_controller.dart';
import 'package:board_game_app/providers/settings_controller.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/app/layout.dart';

final _settingsController = SettingsController();
final _tipService = TipService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load Controllers Here
  try {
    await _tipService.init();
  } catch (e) {
    debugPrint('TipService failed to initialize: $e');
  }

  await _settingsController.load();

  // Default language should be connected to a settings controller
  AppLocalization.setLanguage('sr');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Layout.init(context);

    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) {
        AppColors.primary = _settingsController.settings.themeColor.primary;
        AppColors.primaryDim =
            _settingsController.settings.themeColor.primaryDim;
        return SettingsScope(
          controller: _settingsController,
          child: TipServiceScope(
            tipService: _tipService,
            child: MaterialApp.router(
              title: 'Kockica',
              theme: buildAppTheme(),
              routerConfig: appRouter,
            ),
          ),
        );
      },
    );
  }
}
