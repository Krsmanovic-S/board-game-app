import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:board_game_app/localization/localization.dart';

enum UsernameValidationResult {
  valid,
  empty,
  tooShort,
  tooLong,
  invalidCharacters,
  taken,
}

// - Format-only validators (no network, instant) ------------------------------

String? validateEmailFormat(String email) {
  if (email.isEmpty) return AppLocalization.emailRequired;
  final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(email)) return AppLocalization.emailInvalid;
  return null;
}

String? validatePasswordFormat(String password) {
  if (password.isEmpty) return AppLocalization.passwordRequired;
  if (password.length < 6) return AppLocalization.passwordTooShort;
  return null;
}

UsernameValidationResult validateUsernameFormat(String username) {
  if (username.isEmpty) return UsernameValidationResult.empty;
  if (username.length < 5) return UsernameValidationResult.tooShort;
  if (username.length > 18) return UsernameValidationResult.tooLong;
  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
    return UsernameValidationResult.invalidCharacters;
  }
  return UsernameValidationResult.valid;
}

String? usernameErrorMessage(UsernameValidationResult result) {
  return switch (result) {
    UsernameValidationResult.valid => null,
    UsernameValidationResult.empty => AppLocalization.usernameRequired,
    UsernameValidationResult.tooShort => AppLocalization.usernameTooShort,
    UsernameValidationResult.tooLong => AppLocalization.usernameTooLong,
    UsernameValidationResult.invalidCharacters =>
      AppLocalization.usernameInvalidChars,
    UsernameValidationResult.taken => AppLocalization.usernameTaken,
  };
}

// - Network validators (Firestore) --------------------------------------------

Future<UsernameValidationResult> validateUsername(String username) async {
  final formatResult = validateUsernameFormat(username);
  if (formatResult != UsernameValidationResult.valid) return formatResult;

  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username.trim())
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) return UsernameValidationResult.taken;
  return UsernameValidationResult.valid;
}

// - Submit-time validators (with context, for modal errors) -------------------

Future<bool> validateEmail(String email) async {
  return validateEmailFormat(email) == null;
}

Future<bool> validatePassword(String password) async {
  return validatePasswordFormat(password) == null;
}

Future<bool> validatePasswordsMatch(String password, String confirm) async {
  return password == confirm;
}
