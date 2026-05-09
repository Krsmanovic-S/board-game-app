import 'package:board_game_app/controllers/watchlist_controller.dart';
import 'package:board_game_app/widgets/field_card.dart';
import 'package:board_game_app/widgets/settings_buttons.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/controllers/auth_controller.dart';
import 'package:board_game_app/controllers/tip_controller.dart';
import 'package:board_game_app/controllers/settings_controller.dart';
import 'package:board_game_app/utils/tip_service.dart';
import 'package:board_game_app/utils/support_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:board_game_app/data/models/settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late WatchlistController _watchlistCtrl;
  DateTime? _lastVerificationSent;
  bool _isUpdating = false;

  SettingsController get _controller => SettingsScope.of(context);
  AppSettings get _settings => _controller.settings;

  static final _languageOptions = {
    'sr': AppLocalization.serbian,
    'en': AppLocalization.english,
    'ru': AppLocalization.russian,
  };

  String _languageLabel(String code) =>
      _languageOptions[code] ?? _languageOptions['sr']!;

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

  Future<void> _showPicker({
    required String title,
    required List<String> options,
    required String current,
    required void Function(String) onSave,
  }) async {
    String selected = current;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
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
                  title,
                  style: AppTextStyles.font22.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Layout.heightBox(8),
              ...options.map(
                (opt) => OptionRow(
                  label: opt,
                  isSelected: opt == selected,
                  onTap: () => setModal(() => selected = opt),
                ),
              ),
              Layout.heightBox(20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: AppButtonStyles.modalCancel,
                      child: Text(AppLocalization.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSave(selected);
                        Navigator.pop(ctx);
                      },
                      style: AppButtonStyles.modalSave,
                      child: Text(AppLocalization.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            ...['app_tip_small', 'app_tip_medium', 'app_tip_large'].map(
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

    _controller;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
      child: Stack(children: [
        SafeArea(
          child: AbsorbPointer(
            absorbing: _isUpdating,
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

                  // Verifying Email
                  if (FirebaseAuth.instance.currentUser?.emailVerified ==
                      false) ...[
                    Layout.heightBox(6),
                    Container(
                      padding: Layout.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(Layout.v(8)),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: Layout.v(16)),
                          Layout.widthBox(8),
                          Expanded(
                            child: Text(
                              AppLocalization.emailNotVerified,
                              style: AppTextStyles.font14
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                          if (_lastVerificationSent != null &&
                              DateTime.now()
                                      .difference(_lastVerificationSent!)
                                      .inSeconds <
                                  60) ...[
                            Row(
                              children: [
                                Icon(Icons.check_circle),
                                Layout.widthBox(4),
                                Text(
                                  AppLocalization.alreadySent,
                                  style: AppTextStyles.font14.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            )
                          ] else ...[
                            GestureDetector(
                                child: Text(
                                  AppLocalization.resend,
                                  style: AppTextStyles.font14.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.error,
                                  ),
                                ),
                                onTap: () async {
                                  await FirebaseAuth.instance.currentUser
                                      ?.sendEmailVerification();
                                  _lastVerificationSent = DateTime.now();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(AppLocalization
                                              .verificationSent)),
                                    );
                                  }
                                })
                          ],
                        ],
                      ),
                    ),
                  ],

                  Layout.heightBox(16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              AppLocalization.logoutConfirmTitle,
                              textAlign: TextAlign.center,
                            ),
                            content: Text(AppLocalization.logoutConfirmMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(AppLocalization.cancel,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(AppLocalization.yes,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          auth.logout();
                        }
                      },
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

                  // Delete Account Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              AppLocalization.deleteAccountTitle,
                              textAlign: TextAlign.center,
                            ),
                            content: Text(AppLocalization.deleteAccountMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(AppLocalization.cancel,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  AppLocalization.delete,
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          try {
                            await auth.deleteAccount();
                          } on FirebaseAuthException catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalization.unknownError)),
                            );
                          }
                        }
                      },
                      style: AppButtonStyles.destructiveFilled,
                      child: Text(AppLocalization.deleteAccount),
                    ),
                  ),

                  Layout.heightBox(16),

                  // Notification Settings
                  SectionHeader(
                      title: AppLocalization.receivedNotificationsHeader),

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
                    onChanged: (v) => _watchlistCtrl.updateGlobalNotification(
                        'priceIncrease', v),
                  ),
                  Layout.heightBox(8),
                  SwitchRow(
                    label: AppLocalization.backInStockLabel,
                    value: notifications['backInStock'] ?? true,
                    onChanged: (v) => _watchlistCtrl.updateGlobalNotification(
                        'backInStock', v),
                  ),
                  Layout.heightBox(8),
                  SwitchRow(
                    label: AppLocalization.outOfStockLabel,
                    value: notifications['outOfStock'] ?? true,
                    onChanged: (v) => _watchlistCtrl.updateGlobalNotification(
                        'outOfStock', v),
                  ),
                  Layout.heightBox(16),

                  // App Settings
                  SectionHeader(title: AppLocalization.settings),

                  Layout.heightBox(16),

                  SettingRow(
                    label: AppLocalization.language,
                    value: _languageLabel(_settings.languageCode),
                    onTap: () => _showPicker(
                      title: AppLocalization.language,
                      options: _languageOptions.values.toList(),
                      current: _languageLabel(_settings.languageCode),
                      onSave: (v) async {
                        final code = _languageOptions.entries
                            .firstWhere((e) => e.value == v)
                            .key;

                        // Optimization: don't do anything if language didn't change
                        if (code == _settings.languageCode) return;

                        setState(() => _isUpdating = true);

                        await Future.delayed(
                          const Duration(milliseconds: 500),
                        );

                        // Update the backend settings (Controller/Database)
                        await _controller.updateSettings(
                          _settings.copyWith(languageCode: code),
                        );

                        // Update the global localization reference
                        AppLocalization.setLanguage(code);

                        // Stop the loading spinner
                        if (mounted) {
                          setState(() => _isUpdating = false);
                        }
                      },
                    ),
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
                ],
              ),
            ),
          ),
        ),
        if (_isUpdating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ]),
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
