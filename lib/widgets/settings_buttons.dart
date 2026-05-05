import 'package:flutter/material.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/app/layout.dart';

class SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  final VoidCallback? onInfo;

  const SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: context.cardDecoration,
      child: Padding(
        padding: Layout.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.font16.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (onInfo != null) ...[
              Layout.widthBox(8),
              GestureDetector(
                onTap: onInfo,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textMuted,
                  size: Layout.v(22),
                ),
              ),
            ],
            const Spacer(),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
