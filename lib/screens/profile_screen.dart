import 'package:board_game_app/controllers/watchlist_controller.dart';
import 'package:board_game_app/widgets/field_card.dart';
import 'package:board_game_app/widgets/settings_buttons.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:board_game_app/controllers/tip_controller.dart';
import 'package:board_game_app/utils/tip_service.dart';
import 'package:board_game_app/utils/support_email.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late WatchlistController _watchlistCtrl;

  TipService get _tipService => TipServiceScope.of(context);

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

  void _showTipPicker() async {
    if (_tipService.loading ||
        !_tipService.available ||
        _tipService.products.isEmpty) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: Layout.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Layout.heightBox(20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalization.supportApp,
                style: AppTextStyles.font22.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Layout.heightBox(4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalization.supportDescription,
                style: AppTextStyles.font16.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Layout.heightBox(12),
            ...['vigor_tip_small', 'vigor_tip_medium', 'vigor_tip_large'].map(
              (id) => TipOptionRow(
                productId: id,
                onTap: () {
                  Navigator.pop(ctx);
                  _tipService.tipById(id);
                },
              ),
            ),
            Layout.heightBox(20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: AppButtonStyles.modalCancel,
                child: Text(AppLocalization.cancel),
              ),
            ),
          ],
        ),
      ),
    );
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
              // Tipping
              SectionHeader(title: AppLocalization.supportDeveloperHeader),

              Layout.heightBox(12),

              MenuTile(
                icon: Icons.favorite,
                label: AppLocalization.supportDeveloperButton,
                onTap: _showTipPicker,
              ),

              Layout.heightBox(12),

              // Profile Info
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

              // Logout Button
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

              // Notification Settings
              SectionHeader(title: AppLocalization.receivedNotificationsHeader),

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
                label: AppLocalization.pushNotifications,
                value: user?.pushNotificationsEnabled ?? true,
                onChanged: (v) =>
                    _watchlistCtrl.updatePushNotificationsEnabled(v),
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

              // Feedback Email
              SectionHeader(title: AppLocalization.profileContact),

              Layout.heightBox(16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final size = MediaQuery.of(context).size;
                    sendSupportEmail(
                        context: context,
                        screenSize:
                            "${size.width.toInt()}x${size.height.toInt()}");
                  },
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

              Layout.heightBox(16),

              // Debug Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final db = FirebaseFirestore.instance;
                    final snap = await db
                        .collection('products')
                        .orderBy('updatedAt', descending: true)
                        .limit(10)
                        .get();

                    for (final doc in snap.docs) {
                      final data = doc.data();
                      debugPrint(
                          '${data['name']} - updatedAt: ${data['updatedAt']}');
                    }
                  },
                  child: const Text('Debug: Show Changed Games'),
                ),
              ),

              Layout.heightBox(16),
            ],
          ),
        ),
      ),
    );
  }
}

class TipOptionRow extends StatelessWidget {
  final String productId;
  final VoidCallback onTap;

  static final _labels = {
    'app_tip_small': AppLocalization.buyTipSmall,
    'app_tip_medium': AppLocalization.buyTipMedium,
    'app_tip_large': AppLocalization.buyTipLarge,
  };

  const TipOptionRow({required this.productId, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final tipService = TipServiceScope.of(context);
    final product = tipService.products.firstWhere((p) => p.id == productId);

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
                  _labels[productId] ?? productId,
                  style: AppTextStyles.font16.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                product.price,
                style: AppTextStyles.font16.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Layout.widthBox(6),
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
