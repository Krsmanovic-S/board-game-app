import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';

class InfoModal extends StatelessWidget {
  final String title;
  final String message;

  const InfoModal({super.key, required this.title, required this.message});

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => InfoModal(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    return AlertDialog(
      title: Center(child: Text(title)),
      content: Text(message),
      actionsPadding: Layout.symmetric(horizontal: 16, vertical: 12),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppButtonStyles.primaryFilled,
            child: Text(AppLocalization.ok),
          ),
        ),
      ],
    );
  }
}
