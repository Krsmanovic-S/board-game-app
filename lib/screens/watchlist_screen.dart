import 'package:board_game_app/controllers/games_controller.dart';
import 'package:board_game_app/controllers/watchlist_controller.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/widgets/watchlist_card.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    final watchlist = WatchlistScope.of(context);
    final games = GamesScope.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            title: Text(AppLocalization.watchlistAppBar),
            foregroundColor: AppColors.secondary,
          ),
          body: watchlist.loading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _buildBody(context, watchlist, games),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WatchlistController watchlist,
      GamesController games) {
    if (watchlist.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalization.emptyWatchlistText1,
              style: AppTextStyles.font18.copyWith(color: AppColors.textMuted),
            ),
            Layout.heightBox(8),
            Text(
              AppLocalization.emptyWatchlistText2,
              style: AppTextStyles.font18.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final gameMap = {for (final g in games.games) g.id: g};
    final watched = watchlist.items.entries
        .where((e) => gameMap.containsKey(e.key))
        .map((e) => MapEntry(gameMap[e.key]!, e.value))
        .toList();

    if (watched.isEmpty && games.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (watched.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalization.emptyWatchlistText1,
              style: AppTextStyles.font18.copyWith(color: AppColors.textMuted),
            ),
            Text(
              AppLocalization.emptyWatchlistText2,
              style: AppTextStyles.font18.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: Layout.all(16),
      itemCount: watched.length,
      separatorBuilder: (_, __) => Layout.heightBox(8),
      itemBuilder: (_, index) {
        final entry = watched[index];
        return WatchlistCard(game: entry.key, item: entry.value);
      },
    );
  }
}
