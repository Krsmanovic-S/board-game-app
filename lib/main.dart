import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/router.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/firebase_options.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/providers/auth_controller.dart';
import 'package:board_game_app/providers/settings_controller.dart';
import 'package:board_game_app/providers/tip_controller.dart';
import 'package:board_game_app/utils/tip_service.dart';
import 'package:firebase_core/firebase_core.dart';

final _settingsController = SettingsController();
final _tipService = TipService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await _tipService.init();
  } catch (e) {
    debugPrint('TipService failed to initialize: $e');
  }

  await _settingsController.load();

  AppLocalization.setLanguage('sr');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        return AuthScope(
          controller: authController,
          child: SettingsScope(
            controller: _settingsController,
            child: TipServiceScope(
              tipService: _tipService,
              child: MaterialApp.router(
                title: 'Kockica',
                theme: buildAppTheme(),
                routerConfig: appRouter,
              ),
            ),
          ),
        );
      },
    );
  }
}
