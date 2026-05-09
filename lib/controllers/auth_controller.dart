import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/app_user.dart';
import 'package:board_game_app/utils/notifications.dart';

class AuthController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _initialized = false;
  bool _needsUsername = false;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoggedIn => _firebaseUser != null;
  bool get initialized => _initialized;
  bool get needsUsername => _needsUsername;

  AuthController() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  bool _isOAuthUser(User user) => user.providerData.any(
        (p) => p.providerId == 'google.com' || p.providerId == 'apple.com',
      );

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadAppUser(user.uid);
      _needsUsername = _appUser == null && _isOAuthUser(user);
      if (!_needsUsername) {
        try {
          await initNotifications();
        } catch (e) {
          debugPrint('[AuthController] initNotifications failed: $e');
        }
      }
    } else {
      _appUser = null;
      _needsUsername = false;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _appUser = AppUser.fromFirestore(doc);
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(
    String email,
    String password,
    String username,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'username': username,
      'fcmToken': '',
      'pushNotificationsEnabled': true,
      'emailNotificationsEnabled': false,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).delete();

    final watchlistSnap = await _firestore
        .collection('watchlist')
        .doc(uid)
        .collection('items')
        .get();
    for (final doc in watchlistSnap.docs) {
      await doc.reference.delete();
    }

    try {
      await _firebaseUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _auth.signOut();
      }
      rethrow;
    }
  }

  Future<void> createUserDocument(String username) async {
    final user = _firebaseUser!;
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email ?? '',
      'username': username,
      'fcmToken': '',
      'globalNotifications': {
        'priceDrop': true,
        'priceIncrease': true,
        'outOfStock': true,
        'backInStock': true,
      },
      'pushNotificationsEnabled': true,
      'emailNotificationsEnabled': false,
    });
    await _loadAppUser(user.uid);
    _needsUsername = false;
    try {
      await initNotifications();
    } catch (e) {
      debugPrint('[AuthController] initNotifications failed: $e');
    }
    notifyListeners();
  }

  void patchGlobalNotification(String field, bool value) {
    if (_appUser == null) return;
    final updated = Map<String, bool>.from(_appUser!.globalNotifications);
    updated[field] = value;
    _appUser = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      username: _appUser!.username,
      fcmToken: _appUser!.fcmToken,
      globalNotifications: updated,
      pushNotificationsEnabled: _appUser!.pushNotificationsEnabled,
    );
    notifyListeners();
  }

  void patchPushNotificationsEnabled(bool value) {
    if (_appUser == null) return;
    _appUser = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      username: _appUser!.username,
      fcmToken: _appUser!.fcmToken,
      globalNotifications: _appUser!.globalNotifications,
      pushNotificationsEnabled: value,
    );
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;
}
