import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/data/models/price_list_entry.dart';

enum BrowseTab { all, updated, newGames }

class GamesController extends ChangeNotifier {
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

    // All Games
    try {
      final allSnap =
          await FirebaseFirestore.instance.collection('products').get();
      _games = allSnap.docs.map(BoardGame.fromFirestore).toList()..shuffle();
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
