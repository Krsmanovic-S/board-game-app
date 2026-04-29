import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/providers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    final auth = AuthScope.of(context);
    final user = auth.appUser;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: Layout.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(AppLocalization.profileMyData),

              _InfoCard(
                label: AppLocalization.username,
                value: user?.username ?? '',
              ),
              Layout.heightBox(8),
              _InfoCard(
                label: AppLocalization.email,
                value: user?.email ?? '',
              ),

              Layout.heightBox(16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => auth.logout(),
                  style: AppButtonStyles.primaryFilled,
                  child: Text(
                    AppLocalization.logout,
                    style: AppTextStyles.font18.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              Layout.heightBox(28),

              _SectionHeader(AppLocalization.profileSettings),
              _InfoCard(value: AppLocalization.settingsComingSoon),

              Layout.heightBox(28),

              _SectionHeader(AppLocalization.profileContact),
              Layout.heightBox(4),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    textStyle: AppTextStyles.font18.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                    padding: EdgeInsets.symmetric(vertical: Layout.v(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(Layout.v(8)),
                      ),
                    ),
                    elevation: 10,
                  ),
                  child: Text(AppLocalization.sendEmail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

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
        Layout.heightBox(12),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? label;
  final String value;

  const _InfoCard({this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Layout.v(10)),
        border: Border.all(color: AppColors.border),
      ),
      padding: Layout.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppTextStyles.font12.copyWith(color: AppColors.textMuted),
            ),
            Layout.heightBox(3),
          ],
          Text(
            value,
            style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
