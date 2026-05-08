import 'package:board_game_app/localization/lang/english_localization.dart';
import 'package:board_game_app/localization/lang/serbian_localization.dart';
import 'package:board_game_app/utils/auth.dart';

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
  static String get usernameTooShort => _strings['usernameTooShort']!;
  static String get usernameTooLong => _strings['usernameTooLong']!;
  static String get usernameInvalidChars => _strings['usernameInvalidChars']!;
  static String get emailRequired => _strings['emailRequired']!;
  static String get emailInvalid => _strings['emailInvalid']!;
  static String get passwordRequired => _strings['passwordRequired']!;
  static String get passwordTooShort => _strings['passwordTooShort']!;
  static String get passwordsNoMatch => _strings['passwordsNoMatch']!;

  static String? usernameError(UsernameValidationResult result) {
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

  // ── Support Email ────────────────────────────────────────────────────────────
  static String get supportEmail => _strings['supportEmail']!;
  static String get emailSubjectFeedback => _strings['emailSubjectFeedback']!;
  static String get emailFeedbackPrompt => _strings['emailFeedbackPrompt']!;
  static String get noEmailFound => _strings['noEmailFound']!;
  static String get failedEmailLaunch => _strings['failedEmailLaunch']!;

  // ── Validation ────────────────────────────────────────────────────────────
  static String get validationError => _strings['validationError']!;
  static String get invalidEmail => _strings['invalidEmail']!;
  static String get usernameRequired => _strings['usernameRequired']!;
  static String get usernameTaken => _strings['usernameTaken']!;
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
  static String get globalNotificationsDesc1 =>
      _strings['globalNotificationsDesc1']!;
  static String get globalNotificationsDesc2 =>
      _strings['globalNotificationsDesc2']!;
  static String get receivedNotificationsHeader =>
      _strings['receivedNotificationsHeader']!;
  static String get pushNotifications => _strings['pushNotifications']!;
  static String get emailNotifications => _strings['emailNotifications']!;

  // ── Tipping ────────────────────────────────────────────────────────────────
  static String get supportDeveloperHeader =>
      _strings['supportDeveloperHeader']!;
  static String get supportDeveloperButton =>
      _strings['supportDeveloperButton']!;
  static String get supportApp => _strings['supportApp']!;
  static String get supportDescription => _strings['supportDescription']!;
  static String get buyTipSmall => _strings['buyTipSmall']!;
  static String get buyTipMedium => _strings['buyTipMedium']!;
  static String get buyTipLarge => _strings['buyTipLarge']!;

  // ── Nav Bar ────────────────────────────────────────────────────────
  static String get browseLabel => _strings['browseLabel']!;
  static String get watchlistLabel => _strings['watchlistLabel']!;
  static String get profileLabel => _strings['profileLabel']!;

  // ── Browse ────────────────────────────────────────────────────────────────
  static String get searchHint => _strings['searchHint']!;
  static String get noSearchResults => _strings['noSearchResults']!;
  static String get noUpdatedGames => _strings['noUpdatedGames']!;
  static String get allGamesTab => _strings['allGamesTab']!;
  static String get updatedGamesTab => _strings['updatedGamesTab']!;
  static String get price => _strings['price']!;
  static String get lowestPrice => _strings['lowestPrice']!;
  static String get notAvailable => _strings['notAvailable']!;

  // ── Watchlist ────────────────────────────────────────────────────────────────
  static String get watchlistAppBar => _strings['watchlistAppBar']!;
  static String get emptyWatchlistText1 => _strings['emptyWatchlistText1']!;
  static String get emptyWatchlistText2 => _strings['emptyWatchlistText2']!;

  // ── Game Details ────────────────────────────────────────────────────────────────
  static String get gameDetailsAppBar => _strings['gameDetailsAppBar']!;
  static String get buyOnButton => _strings['buyOnButton']!;
  static String get pricePerStore => _strings['pricePerStore']!;
  static String get notifications => _strings['notifications']!;
  static String get noPriceHistory => _strings['noPriceHistory']!;

  // ── Game Notifications ────────────────────────────────────────────────────────────────
  static String get priceDropLabel => _strings['priceDropLabel']!;
  static String get priceIncreaseLabel => _strings['priceIncreaseLabel']!;
  static String get outOfStockLabel => _strings['outOfStockLabel']!;
  static String get backInStockLabel => _strings['backInStockLabel']!;
  static String get watchToEnableNotifications =>
      _strings['watchToEnableNotifications']!;
  static String get saveError => _strings['saveError']!;

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
