import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';

class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.search, color: AppColors.textMuted, size: Layout.v(20)),
        Layout.widthBox(8),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: onChanged,
            style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppLocalization.searchHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (controller.text.isNotEmpty) {
              controller.clear();
              onChanged('');
            } else {
              onClose();
            }
          },
          child: Padding(
            padding: Layout.all(4),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: Layout.v(20),
            ),
          ),
        ),
      ],
    );
  }
}
