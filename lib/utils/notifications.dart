import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:board_game_app/app/router.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

Future<void> initNotifications() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // App opened from terminated state
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) _handleNotificationTap(initialMessage);

  // App brought to foreground via notification tap
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');
  });

  await _saveToken();
  FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenString);
}

void _handleNotificationTap(RemoteMessage message) {
  final productId = message.data['productId'];
  if (productId == null) return;

  final context = navigatorKey.currentContext;
  if (context != null) GoRouter.of(context).push('/product/$productId');
}

Future<void> _saveToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await _saveTokenString(token);
}

Future<void> _saveTokenString(String token) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'fcmToken': token}, SetOptions(merge: true));
}
