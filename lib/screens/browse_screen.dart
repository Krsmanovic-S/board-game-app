import 'package:board_game_app/widgets/page_container.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/controllers/games_controller.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/widgets/game_card.dart';
import 'package:board_game_app/widgets/search_bar_field.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
          padding: Layout.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: Layout.v(20), color: AppColors.textPrimary),
              Layout.widthBox(6),
              Text(
                label,
                style: AppTextStyles.font16.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();

  bool _isSearching = false;
  List<BoardGame> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final gamesCtrl = GamesScope.of(context);
    final sourceGames = gamesCtrl.browseTab == BrowseTab.updated
        ? gamesCtrl.updatedGames
        : gamesCtrl.games;
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final lower = query.toLowerCase();
    setState(() {
      _searchResults = sourceGames
          .where((g) => g.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  void _openSearch() => setState(() => _isSearching = true);

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    final gamesCtrl = GamesScope.of(context);

    return PageContainer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(gamesCtrl),
              Expanded(child: _buildBody(gamesCtrl)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(GamesController gamesCtrl) {
    return Container(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: Layout.v(60),
            child: Padding(
              padding: Layout.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_isSearching)
                    Expanded(
                      child: SearchBarField(
                        controller: _searchController,
                        onClose: _closeSearch,
                        onChanged: _onSearchChanged,
                      ),
                    )
                  else ...[
                    Expanded(
                      child: Text(
                        AppLocalization.browseLabel,
                        style: AppTextStyles.font22.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                        size: Layout.v(22),
                      ),
                      onPressed: _openSearch,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _TabButton(
                    label: AppLocalization.updatedGamesTab,
                    icon: Icons.edit_outlined,
                    selected: gamesCtrl.browseTab == BrowseTab.updated,
                    onTap: () => gamesCtrl.setBrowseTab(BrowseTab.updated),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  _TabButton(
                    label: AppLocalization.allGamesTab,
                    icon: Icons.grid_view_rounded,
                    selected: gamesCtrl.browseTab == BrowseTab.all,
                    onTap: () => gamesCtrl.setBrowseTab(BrowseTab.all),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  _TabButton(
                    label: AppLocalization.newTab,
                    icon: Icons.auto_awesome,
                    selected: gamesCtrl.browseTab == BrowseTab.newGames,
                    onTap: () => gamesCtrl.setBrowseTab(BrowseTab.newGames),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GamesController gamesCtrl) {
    if (gamesCtrl.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (gamesCtrl.error != null) {
      return Center(
        child: Text(
          AppLocalization.unknownError,
          style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    final tabGames = gamesCtrl.browseTab == BrowseTab.updated
        ? gamesCtrl.updatedGames
        : gamesCtrl.browseTab == BrowseTab.newGames
            ? gamesCtrl.newGames
            : gamesCtrl.games;

    final displayGames = _isSearching && _searchController.text.isNotEmpty
        ? _searchResults
        : tabGames;

    if (_isSearching &&
        _searchController.text.isNotEmpty &&
        displayGames.isEmpty) {
      return Center(
        child: Text(
          AppLocalization.noSearchResults,
          style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    if (displayGames.isEmpty) {
      if (gamesCtrl.browseTab == BrowseTab.updated) {
        return Center(
          child: Text(
            AppLocalization.noUpdatedGames,
            style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
          ),
        );
      } else if (gamesCtrl.browseTab == BrowseTab.newGames) {
        return Center(
          child: Text(
            AppLocalization.noNewGames,
            style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
          ),
        );
      }
    }

    return MasonryGridView.count(
      padding: Layout.symmetric(horizontal: 8, vertical: 16),
      crossAxisCount: 2,
      mainAxisSpacing: Layout.v(8),
      crossAxisSpacing: Layout.v(8),
      itemCount: displayGames.length,
      itemBuilder: (context, index) {
        return GameCard(game: displayGames[index]);
      },
    );
  }
}
