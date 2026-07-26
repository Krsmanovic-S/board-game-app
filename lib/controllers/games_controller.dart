import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/data/models/price_list_entry.dart';

enum BrowseTab { all, updated, newGames }

class GamesController extends ChangeNotifier {
  static const _cacheFileName = 'games_cache.json';

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

    // All Games — served from the local cache file until the next scrape lands
    try {
      final cached = await _readCache();
      if (cached != null) {
        _games = cached;
      } else {
        final allSnap =
            await FirebaseFirestore.instance.collection('products').get();
        _games = allSnap.docs.map(BoardGame.fromFirestore).toList();
        await _writeCache(_games);
      }
      _games.shuffle();
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

  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// The scraper runs daily at 12:00 UTC and is done by ~13:15 UTC, so anything
  /// cached after 13:30 UTC on the most recent run day is still current.
  DateTime _lastScrapeCompletion() {
    final now = DateTime.now().toUtc();
    var boundary = DateTime.utc(now.year, now.month, now.day, 13, 30);
    if (now.isBefore(boundary)) {
      boundary = boundary.subtract(const Duration(days: 1));
    }
    return boundary;
  }

  /// Returns the cached games when the file exists and predates no scrape,
  /// otherwise `null` (stale cache files are deleted). Never throws — any
  /// read or parse failure falls through to a Firestore fetch.
  Future<List<BoardGame>?> _readCache() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        debugPrint('Games cache has unexpected shape, refetching');
        await file.delete();
        return null;
      }

      final cachedAt = DateTime.tryParse(decoded['cachedAt'] as String? ?? '');
      if (cachedAt == null || !cachedAt.isAfter(_lastScrapeCompletion())) {
        await file.delete();
        return null;
      }

      final rawGames = decoded['games'];
      if (rawGames is! List) {
        debugPrint('Games cache has unexpected shape, refetching');
        await file.delete();
        return null;
      }

      return rawGames
          .map((e) => BoardGame.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to read games cache: $e');
      await clearCache();
      return null;
    }
  }

  Future<void> _writeCache(List<BoardGame> games) async {
    try {
      final file = await _cacheFile();
      await file.writeAsString(jsonEncode({
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'games': games.map((g) => g.toJson()).toList(),
      }));
    } catch (e) {
      debugPrint('Failed to write games cache: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final file = await _cacheFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Failed to clear games cache: $e');
    }
  }

  Future<void> forceRefresh() async {
    await clearCache();
    await _loadGames();
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
