import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:board_game_app/data/models/app_user.dart';

class AuthController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _initialized = false;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoggedIn => _firebaseUser != null;
  bool get initialized => _initialized;

  AuthController() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadAppUser(user.uid);
    } else {
      _appUser = null;
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
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
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
