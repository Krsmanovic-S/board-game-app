import 'package:board_game_app/localization/lang/english_localization.dart';
import 'package:board_game_app/localization/lang/serbian_localization.dart';

class AppLocalization {
  static String _code = 'en';

  static void setLanguage(String code) {
    _code = code;
  }

  static Map<String, String> get _strings =>
      _languages[_code] ?? _languages['en']!;

  // ── Auth ────────────────────────────────────────────────────────────────────
  static String get loginTitle => _strings['loginTitle']!;
  static String get registerTitle => _strings['registerTitle']!;
  static String get username => _strings['username']!;
  static String get password => _strings['password']!;
  static String get confirmPassword => _strings['confirmPassword']!;
  static String get email => _strings['email']!;
  static String get continueWithGoogle => _strings['continueWithGoogle']!;
  static String get continueWithApple => _strings['continueWithApple']!;
  static String get noAccount => _strings['noAccount']!;
  static String get haveAccount => _strings['haveAccount']!;
  static String get forgotPassword => _strings['forgotPassword']!;

  // ── Validation ────────────────────────────────────────────────────────────
  static String get validationError => _strings['validationError']!;
  static String get invalidEmail => _strings['invalidEmail']!;
  static String get usernameRequired => _strings['usernameRequired']!;
  static String get usernameTaken => _strings['usernameTaken']!;
  static String get passwordTooShort => _strings['passwordTooShort']!;
  static String get passwordsDontMatch => _strings['passwordsDontMatch']!;

  // ── Auth Errors ───────────────────────────────────────────────────────────
  static String get error => _strings['error']!;
  static String get loginError => _strings['loginError']!;
  static String get registerError => _strings['registerError']!;
  static String get emailInUse => _strings['emailInUse']!;
  static String get wrongCredentials => _strings['wrongCredentials']!;
  static String get networkError => _strings['networkError']!;
  static String get unknownError => _strings['unknownError']!;

  // ── Profile ────────────────────────────────────────────────────────────────
  static String get logout => _strings['logout']!;
  static String get profileMyData => _strings['profileMyData']!;
  static String get profileSettings => _strings['profileSettings']!;
  static String get profileContact => _strings['profileContact']!;
  static String get sendEmail => _strings['sendEmail']!;
  static String get settingsComingSoon => _strings['settingsComingSoon']!;

  // ── Nav Bar ────────────────────────────────────────────────────────
  static String get browseLabel => _strings['browseLabel']!;
  static String get watchlistLabel => _strings['watchlistLabel']!;
  static String get profileLabel => _strings['profileLabel']!;

  // ── Common Actions ────────────────────────────────────────────────────────
  static String get add => _strings['add']!;
  static String get all => _strings['all']!;
  static String get cancel => _strings['cancel']!;
  static String get confirm => _strings['confirm']!;
  static String get continueLabel => _strings['continue']!;
  static String get delete => _strings['delete']!;
  static String get edit => _strings['edit']!;
  static String get goBack => _strings['goBack']!;
  static String get keep => _strings['keep']!;
  static String get ok => _strings['ok']!;
  static String get on => _strings['on']!;
  static String get off => _strings['off']!;
  static String get save => _strings['save']!;
  static String get start => _strings['start']!;
  static String get yes => _strings['yes']!;
  static String get yesCancel => _strings['yesCancel']!;
  static String get pressBackToExit => _strings['pressBackToExit']!;

  // ── Time Units ────────────────────────────────────────────────────────────
  static String get hours => _strings['hours']!;
  static String get minutes => _strings['minutes']!;
  static String get name => _strings['name']!;
  static String get seconds => _strings['seconds']!;

  // ── Month Names ───────────────────────────────────────────────────────────
  static String get january => _strings['january']!;
  static String get february => _strings['february']!;
  static String get march => _strings['march']!;
  static String get april => _strings['april']!;
  static String get may => _strings['may']!;
  static String get june => _strings['june']!;
  static String get july => _strings['july']!;
  static String get august => _strings['august']!;
  static String get september => _strings['september']!;
  static String get october => _strings['october']!;
  static String get november => _strings['november']!;
  static String get december => _strings['december']!;

  // ── Colors ───────────────────────────────────────────────────────────
  static String get orange => _strings['orange']!;

  // ── Parameterized Methods ─────────────────────────────────────────────────

  /// 'Are you sure you want to delete "{name}"?'
  static String areYouSureDelete(String name) =>
      _strings['areYouSureDelete']!.replaceAll('{name}', name);

  /// '"{name}" created successfully'
  static String createdSuccessfully(String name) =>
      _strings['createdSuccessfully']!.replaceAll('{name}', name);

  /// '"{name}" updated successfully'
  static String updatedSuccessfully(String name) =>
      _strings['updatedSuccessfully']!.replaceAll('{name}', name);

  // ── Month name by 0-based index (0 = January) ─────────────────────────────────────────────────
  static String monthByIndex(int index) {
    const keys = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    return _strings[keys[index]]!;
  }

  // ── Language Map ──────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _languages = {
    'en': englishLocalization,
    'sr': serbianLocalization,
  };
}
