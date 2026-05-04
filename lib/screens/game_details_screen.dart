import 'package:flutter/material.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;
  final BoardGame? game;

  const GameDetailsScreen({super.key, required this.gameId, this.game});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
        child: SafeArea(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                title: Text(AppLocalization.gameDetailsAppBar),
                foregroundColor: AppColors.secondary,
                leadingWidth: Layout.v(70),
                titleSpacing: 0,
              ),
              body: Text('Placeholder')),
        ));
  }
}
