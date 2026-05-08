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

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: Layout.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: Layout.v(22)),
              Layout.widthBox(14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.font16.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: Layout.v(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: Layout.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.font16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.font16.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const OptionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: Layout.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.font16.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                Padding(
                  padding: Layout.only(right: 4),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
