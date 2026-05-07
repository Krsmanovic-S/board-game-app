import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> initNotifications() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint(
        '[FCM] Foreground message: ${message.notification?.title} - ${message.notification?.body}');
  });

  await _saveToken();
  FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenString);
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
      .update({'fcmToken': token});
}
