import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.font18.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Layout.heightBox(6),
        Divider(color: AppColors.primary, thickness: 1.5, height: 0),
      ],
    );
  }
}

class FieldCard extends StatelessWidget {
  final String? label;
  final String value;
  final VoidCallback? onTap;
  final bool? toggled;
  final ValueChanged<bool>? onToggle;
  final Widget? leading;

  const FieldCard({
    super.key,
    this.label,
    required this.value,
    this.onTap,
    this.toggled,
    this.onToggle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isToggle = onToggle != null && toggled != null;
    final isClickable = onTap != null;

    Widget content = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Layout.v(10)),
        border: Border.all(color: AppColors.border),
      ),
      padding: Layout.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            Layout.widthBox(10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: AppTextStyles.font12.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Layout.heightBox(3),
                ],
                Text(
                  value,
                  style: AppTextStyles.font16.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isToggle) ...[
            Layout.widthBox(8),
            Switch(
              value: toggled!,
              onChanged: onToggle,
            ),
          ] else if (isClickable) ...[
            Layout.widthBox(8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Layout.v(14),
              color: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (isClickable) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
