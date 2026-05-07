import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:board_game_app/localization/localization.dart';

Future<void> sendSupportEmail({
  required BuildContext context,
  required String screenSize,
}) async {
  // Collect users device information
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String appVersion = packageInfo.version;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String model = "Unknown Device";
  String os = "Unknown OS";

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    model = "${androidInfo.manufacturer} ${androidInfo.model}";
    os = "Android ${androidInfo.version.release}";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    model = iosInfo.utsname.machine;
    os = "iOS ${iosInfo.systemVersion}";
  }

  // Mail title and body prompt
  final String subject = AppLocalization.emailSubjectFeedback;
  final String prompt = AppLocalization.emailFeedbackPrompt;

  // Format the body of the email
  final String body = """
Phone Model: $model
Screen Size: $screenSize
OS: $os
App Version: $appVersion

$prompt


""";

  // Open the users mail app
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: AppLocalization.supportEmail,
    query: _encodeQueryParameters({'subject': subject, 'body': body}),
  );

  try {
    // Check whether the phone can open the mail-to link
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalization.noEmailFound)));
      }
    }
  } catch (e) {
    debugPrint("${AppLocalization.failedEmailLaunch} $e");
  }
}

String? _encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}
