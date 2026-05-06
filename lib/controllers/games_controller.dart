import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/data/models/price_list_entry.dart';

class GamesController extends ChangeNotifier {
  List<BoardGame> _games = [];
  bool _isLoading = false;
  String? _error;

  List<BoardGame> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final Map<String, List<PriceHistoryEntry>> _priceHistoryCache = {};

  GamesController() {
    _loadGames();
  }

  Future<void> _loadGames() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      _games = snapshot.docs.map(BoardGame.fromFirestore).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
