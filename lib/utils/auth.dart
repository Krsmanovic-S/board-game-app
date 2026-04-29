import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/widgets/info_modal.dart';

/// Returns true if valid, shows InfoModal and returns false otherwise.

Future<bool> validateEmail(BuildContext context, String email) async {
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(email.trim())) {
    if (context.mounted) {
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: AppLocalization.invalidEmail,
      );
    }
    return false;
  }
  return true;
}

Future<bool> validateUsername(BuildContext context, String username) async {
  final trimmed = username.trim();
  if (trimmed.isEmpty) {
    if (context.mounted) {
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: AppLocalization.usernameRequired,
      );
    }
    return false;
  }

  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: trimmed)
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    if (context.mounted) {
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: AppLocalization.usernameTaken,
      );
    }
    return false;
  }
  return true;
}

Future<bool> validatePassword(BuildContext context, String password) async {
  if (password.length < 6) {
    if (context.mounted) {
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: AppLocalization.passwordTooShort,
      );
    }
    return false;
  }
  return true;
}

Future<bool> validatePasswordsMatch(
  BuildContext context,
  String password,
  String confirm,
) async {
  if (password != confirm) {
    if (context.mounted) {
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: AppLocalization.passwordsDontMatch,
      );
    }
    return false;
  }
  return true;
}
