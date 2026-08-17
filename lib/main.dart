import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/router.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/controllers/games_controller.dart';
import 'package:board_game_app/controllers/watchlist_controller.dart';
import 'package:board_game_app/firebase_options.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/controllers/auth_controller.dart';
import 'package:board_game_app/controllers/settings_controller.dart';
import 'package:board_game_app/controllers/tip_controller.dart';
import 'package:board_game_app/utils/tip_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final _settingsController = SettingsController();
final _tipService = TipService();
final _gamesController = GamesController();
final _watchlistController = WatchlistController(authController);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the system automatically
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await _settingsController.load();
  AppLocalization.setLanguage(_settingsController.settings.languageCode);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  // Store setup talks to StoreKit over the network, so it must never block
  // launch: a slow store would trip the iOS watchdog and kill the app.
  unawaited(
    _tipService.init().catchError(
      (Object e) => debugPrint('TipService failed to initialize: $e'),
    ),
  );
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
        return GamesScope(
          controller: _gamesController,
          child: AuthScope(
            controller: authController,
            child: WatchlistScope(
              controller: _watchlistController,
              child: SettingsScope(
                controller: _settingsController,
                child: TipServiceScope(
                  tipService: _tipService,
                  child: MaterialApp.router(
                    title: 'Tessera',
                    theme: buildAppTheme(),
                    routerConfig: appRouter,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
