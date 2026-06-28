import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/data/models/price_list_entry.dart';

enum BrowseTab { all, updated, newGames }

class GamesController extends ChangeNotifier {
  static const _cacheKey = 'games_cache';
  static const _cacheTimestampKey = 'games_cache_timestamp';

  List<BoardGame> _games = [];
  List<BoardGame> _updatedGames = [];
  List<BoardGame> _newGames = [];
  bool _isLoading = false;
  String? _error;
  BrowseTab _browseTab = BrowseTab.all;

  List<BoardGame> get games => _games;
  List<BoardGame> get updatedGames => _updatedGames;
  List<BoardGame> get newGames => _newGames;

  bool get isLoading => _isLoading;
  String? get error => _error;
  BrowseTab get browseTab => _browseTab;
  final Map<String, List<PriceHistoryEntry>> _priceHistoryCache = {};

  void setBrowseTab(BrowseTab tab) {
    if (_browseTab == tab) return;
    _browseTab = tab;
    notifyListeners();
  }

  GamesController() {
    _loadGames();
  }

  Future<void> _loadGames() async {
    _isLoading = true;
    notifyListeners();

    // All Games — serve from cache if less than 6 hours old
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final cachedTimestamp = prefs.getInt(_cacheTimestampKey);
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheValid = cachedJson != null &&
          cachedTimestamp != null &&
          (now - cachedTimestamp) < const Duration(hours: 6).inMilliseconds;

      if (cacheValid) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        _games = decoded
            .map((e) => BoardGame.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final allSnap =
            await FirebaseFirestore.instance.collection('products').get();
        _games = allSnap.docs.map(BoardGame.fromFirestore).toList()..shuffle();
        final jsonStr = jsonEncode(_games.map((g) => g.toJson()).toList());
        await prefs.setString(_cacheKey, jsonStr);
        await prefs.setInt(_cacheTimestampKey, now);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final cutoff =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));

    // Recently changed games
    try {
      final updatedSnap = await FirebaseFirestore.instance
          .collection('products')
          .where('lastChangedAt', isGreaterThan: cutoff)
          .orderBy('lastChangedAt', descending: true)
          .get();
      final gameMap = {for (final g in _games) g.id: g};
      _updatedGames = updatedSnap.docs
          .map((d) => gameMap[d.id])
          .whereType<BoardGame>()
          .toList()
        ..shuffle();
    } catch (e) {
      debugPrint('Failed to load updated games: $e');
    }

    try {
      final newSnap = await FirebaseFirestore.instance
          .collection('products')
          .where('addedAt', isGreaterThan: cutoff)
          .orderBy('addedAt', descending: true)
          .get();
      final gameMap = {for (final g in _games) g.id: g};
      _newGames = newSnap.docs
          .map((d) => gameMap[d.id])
          .whereType<BoardGame>()
          .toList()
        ..shuffle();
    } catch (e) {
      debugPrint('Failed to load new games: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }

  Future<List<PriceHistoryEntry>> getPriceHistory(String gameId) async {
    if (_priceHistoryCache.containsKey(gameId)) {
      return _priceHistoryCache[gameId]!;
    }

    final snap = await FirebaseFirestore.instance
        .collection('products')
        .doc(gameId)
        .collection('priceHistory')
        .orderBy('recordedAt', descending: true)
        .get();

    final entries =
        snap.docs.map((doc) => PriceHistoryEntry.fromFirestore(doc)).toList();

    _priceHistoryCache[gameId] = entries;
    return entries;
  }
}

class GamesScope extends InheritedNotifier<GamesController> {
  const GamesScope({
    super.key,
    required GamesController controller,
    required super.child,
  }) : super(notifier: controller);

  static GamesController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GamesScope>()!.notifier!;
}
