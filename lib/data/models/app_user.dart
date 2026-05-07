import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String fcmToken;
  final Map<String, bool> globalNotifications;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.fcmToken,
    required this.globalNotifications,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawGlobal =
        data['globalNotifications'] as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      globalNotifications: {
        'priceDrop': rawGlobal['priceDrop'] as bool? ?? true,
        'priceIncrease': rawGlobal['priceIncrease'] as bool? ?? true,
        'outOfStock': rawGlobal['outOfStock'] as bool? ?? true,
        'backInStock': rawGlobal['backInStock'] as bool? ?? true,
      },
      pushNotificationsEnabled:
          data['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          data['emailNotificationsEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'username': username,
        'fcmToken': fcmToken,
        'globalNotifications': globalNotifications,
        'pushNotificationsEnabled': pushNotificationsEnabled,
        'emailNotificationsEnabled': emailNotificationsEnabled,
      };
}
