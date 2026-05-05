import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/watchlist_item.dart';
import 'package:board_game_app/providers/auth_controller.dart';

class WatchlistController extends ChangeNotifier {
  final AuthController _auth;
  final _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _sub;
  final Map<String, WatchlistItem> _items = {};
  final Map<String, Timer> _timers = {};
  final Map<String, Map<String, dynamic>> _pending = {};
  bool _loading = true;

  bool get loading => _loading;
  Map<String, WatchlistItem> get items => Map.unmodifiable(_items);

  WatchlistController(this._auth) {
    _auth.addListener(_onAuthChanged);
    if (_auth.firebaseUser != null) {
      _initListener(_auth.firebaseUser!.uid);
    }
  }

  void _onAuthChanged() {
    final uid = _auth.firebaseUser?.uid;
    if (uid != null) {
      _initListener(uid);
    } else {
      _sub?.cancel();
      _sub = null;
      _items.clear();
      _loading = true;
      notifyListeners();
    }
  }

  void _initListener(String uid) {
    _sub?.cancel();
    _loading = true;
    notifyListeners();

    _sub = _firestore
        .collection('watchlist')
        .doc(uid)
        .collection('items')
        .snapshots()
        .listen((snap) {
      final liveIds = snap.docs.map((d) => d.id).toSet();

      for (final doc in snap.docs) {
        // Don't overwrite items that have pending optimistic per-field writes
        final hasPending =
            _pending.keys.any((k) => k.startsWith('${doc.id}-'));
        if (!hasPending) {
          _items[doc.id] = WatchlistItem.fromFirestore(doc);
        }
      }
      _items.removeWhere((id, _) => !liveIds.contains(id));

      _loading = false;
      notifyListeners();
    });
  }

  bool isWatched(String gameId) => _items.containsKey(gameId);
  WatchlistItem? getItem(String gameId) => _items[gameId];

  Future<void> watchGame(String gameId) async {
    final uid = _auth.firebaseUser?.uid;
    if (uid == null) return;
    final item = WatchlistItem(
      productId: gameId,
      notifyPriceDrop: true,
      notifyPriceIncrease: true,
      notifyOutOfStock: true,
      notifyBackInStock: true,
      addedAt: Timestamp.now(),
    );
    await _firestore
        .collection('watchlist')
        .doc(uid)
        .collection('items')
        .doc(gameId)
        .set(item.toFirestore());
  }

  Future<void> unwatchGame(String gameId) async {
    final uid = _auth.firebaseUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('watchlist')
        .doc(uid)
        .collection('items')
        .doc(gameId)
        .delete();
  }

  void updatePerGameNotification(String gameId, String field, bool value) {
    // Optimistic update so the UI reflects the change immediately
    final existing = _items[gameId];
    if (existing != null) {
      _items[gameId] = existing.withField(field, value);
      notifyListeners();
    }

    final key = '$gameId-$field';
    _timers[key]?.cancel();
    _pending[key] = {
      'type': 'perGame',
      'gameId': gameId,
      'field': field,
      'value': value,
    };
    _timers[key] = Timer(const Duration(seconds: 2), () {
      _doWritePerGame(gameId, field, value);
      _timers.remove(key);
      _pending.remove(key);
    });
  }

  void updateGlobalNotification(String field, bool value) {
    // Optimistic update on in-memory AppUser so ProfileScreen rebuilds immediately
    _auth.patchGlobalNotification(field, value);

    final key = 'global-$field';
    _timers[key]?.cancel();
    _pending[key] = {'type': 'global', 'field': field, 'value': value};
    _timers[key] = Timer(const Duration(seconds: 2), () {
      _doWriteGlobal(field, value);
      _timers.remove(key);
      _pending.remove(key);
    });
  }

  void _doWritePerGame(String gameId, String field, bool value) async {
    final uid = _auth.firebaseUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('watchlist')
          .doc(uid)
          .collection('items')
          .doc(gameId)
          .update({field: value});
    } catch (_) {}
  }

  void _doWriteGlobal(String field, bool value) async {
    final uid = _auth.firebaseUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'globalNotifications.$field': value});
    } catch (_) {}
  }

  void flushGamePendingWrites(String gameId) {
    final keys =
        _pending.keys.where((k) => k.startsWith('$gameId-')).toList();
    for (final key in keys) {
      _timers[key]?.cancel();
      _timers.remove(key);
      final data = _pending.remove(key)!;
      _doWritePerGame(
        data['gameId'] as String,
        data['field'] as String,
        data['value'] as bool,
      );
    }
  }

  void flushGlobalPendingWrites() {
    final keys =
        _pending.keys.where((k) => k.startsWith('global-')).toList();
    for (final key in keys) {
      _timers[key]?.cancel();
      _timers.remove(key);
      final data = _pending.remove(key)!;
      _doWriteGlobal(data['field'] as String, data['value'] as bool);
    }
  }

  @override
  void dispose() {
    final keys = List<String>.from(_pending.keys);
    for (final key in keys) {
      _timers[key]?.cancel();
      _timers.remove(key);
      final data = _pending.remove(key)!;
      if (data['type'] == 'perGame') {
        _doWritePerGame(
          data['gameId'] as String,
          data['field'] as String,
          data['value'] as bool,
        );
      } else {
        _doWriteGlobal(data['field'] as String, data['value'] as bool);
      }
    }
    _sub?.cancel();
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}

class WatchlistScope extends InheritedNotifier<WatchlistController> {
  const WatchlistScope({
    super.key,
    required WatchlistController controller,
    required super.child,
  }) : super(notifier: controller);

  static WatchlistController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WatchlistScope>()!.notifier!;
}
