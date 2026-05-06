import 'package:board_game_app/controllers/watchlist_controller.dart';
import 'package:board_game_app/widgets/field_card.dart';
import 'package:board_game_app/widgets/settings_buttons.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/providers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late WatchlistController _watchlistCtrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchlistCtrl = WatchlistScope.of(context);
  }

  @override
  void dispose() {
    _watchlistCtrl.flushGlobalPendingWrites();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    final auth = AuthScope.of(context);
    final user = auth.appUser;
    final notifications = user?.globalNotifications ??
        {
          'priceDrop': true,
          'priceIncrease': true,
          'outOfStock': true,
          'backInStock': true,
        };

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
              SectionHeader(title: AppLocalization.profileMyData),
              Layout.heightBox(12),
              FieldCard(
                label: AppLocalization.username,
                value: user?.username ?? '',
              ),
              Layout.heightBox(8),
              FieldCard(
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
              Layout.heightBox(16),
              SectionHeader(title: AppLocalization.profileSettings),
              Layout.heightBox(8),
              Column(
                children: [
                  Text(
                    AppLocalization.globalNotificationsDesc1,
                    style: AppTextStyles.font16,
                  ),
                  Layout.heightBox(8),
                  Text(
                    AppLocalization.globalNotificationsDesc2,
                    style: AppTextStyles.font16,
                  ),
                ],
              ),
              Layout.heightBox(8),
              SwitchRow(
                label: AppLocalization.priceDropLabel,
                value: notifications['priceDrop'] ?? true,
                onChanged: (v) =>
                    _watchlistCtrl.updateGlobalNotification('priceDrop', v),
              ),
              Layout.heightBox(8),
              SwitchRow(
                label: AppLocalization.priceIncreaseLabel,
                value: notifications['priceIncrease'] ?? true,
                onChanged: (v) =>
                    _watchlistCtrl.updateGlobalNotification('priceIncrease', v),
              ),
              Layout.heightBox(8),
              SwitchRow(
                label: AppLocalization.backInStockLabel,
                value: notifications['backInStock'] ?? true,
                onChanged: (v) =>
                    _watchlistCtrl.updateGlobalNotification('backInStock', v),
              ),
              Layout.heightBox(8),
              SwitchRow(
                label: AppLocalization.outOfStockLabel,
                value: notifications['outOfStock'] ?? true,
                onChanged: (v) =>
                    _watchlistCtrl.updateGlobalNotification('outOfStock', v),
              ),
              Layout.heightBox(16),
              SectionHeader(title: AppLocalization.profileContact),
              Layout.heightBox(8),
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
