import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String fcmToken;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.fcmToken,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'username': username,
    'fcmToken': fcmToken,
  };
}
