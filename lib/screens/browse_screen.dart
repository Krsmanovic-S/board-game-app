import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/widgets/game_card.dart';
import 'package:board_game_app/widgets/search_bar_field.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();

  bool _isSearching = false;
  bool _isLoading = true;
  bool _hasError = false;

  List<BoardGame> _games = [];
  List<BoardGame> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final games = snapshot.docs.map(BoardGame.fromFirestore).toList();

      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lower = query.toLowerCase();

    setState(() {
      _searchResults = _games
          .where((game) => game.name.toLowerCase().contains(lower))
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

  List<BoardGame> get _displayGames {
    if (!_isSearching || _searchController.text.isEmpty) return _games;
    return _searchResults;
  }

  bool get _showEmptyState =>
      _isSearching &&
      _searchController.text.isNotEmpty &&
      _searchResults.isEmpty;

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: Layout.v(60),
      color: AppColors.surface,
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
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Text(
          AppLocalization.unknownError,
          style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_showEmptyState) {
      return Center(
        child: Text(
          AppLocalization.noSearchResults,
          style: AppTextStyles.font18.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return MasonryGridView.count(
      padding: Layout.symmetric(horizontal: 12, vertical: 16),
      crossAxisCount: 2, // Exactly 2 cards per row
      mainAxisSpacing: Layout.v(12),
      crossAxisSpacing: Layout.v(12),
      itemCount: _displayGames.length,
      itemBuilder: (context, index) {
        return GameCard(game: _displayGames[index]);
      },
    );
  }
}
