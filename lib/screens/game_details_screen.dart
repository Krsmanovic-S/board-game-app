import 'package:board_game_app/widgets/field_card.dart';
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
          body: Padding(
            padding: Layout.all(16),
            child: Column(
              children: [
                SectionHeader(title: 'Ime Igre'),
                Layout.heightBox(10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Layout.v(10)),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: Layout.symmetric(horizontal: 14, vertical: 12),
                  child: Center(
                    child: Text(
                      widget.game!.name,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font20.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )));
  }
}
