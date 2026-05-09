import 'dart:async';

import 'package:board_game_app/widgets/page_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/controllers/auth_controller.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/utils/auth.dart';
import 'package:board_game_app/widgets/info_modal.dart';

class UsernamePickerScreen extends StatefulWidget {
  const UsernamePickerScreen({super.key});

  @override
  State<UsernamePickerScreen> createState() => _UsernamePickerScreenState();
}

class _UsernamePickerScreenState extends State<UsernamePickerScreen> {
  final _controller = TextEditingController();

  String? _usernameError;
  bool _usernameChecking = false;
  UsernameValidationResult? _usernameResult;
  Timer? _debounce;
  bool _isLoading = false;

  bool get _canSubmit =>
      !_isLoading &&
      !_usernameChecking &&
      _usernameResult == UsernameValidationResult.valid;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();

    final instantResult = validateUsernameFormat(trimmed);
    if (instantResult != UsernameValidationResult.valid) {
      setState(() {
        _usernameResult = instantResult;
        _usernameError = usernameErrorMessage(instantResult);
        _usernameChecking = false;
      });
      return;
    }

    setState(() {
      _usernameResult = null;
      _usernameError = null;
      _usernameChecking = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await validateUsername(trimmed);
      if (mounted) {
        setState(() {
          _usernameResult = result;
          _usernameError = result == UsernameValidationResult.valid
              ? null
              : usernameErrorMessage(result);
          _usernameChecking = false;
        });
      }
    });
  }

  Widget? _buildSuffixIcon() {
    if (_controller.text.isEmpty) return null;
    if (_usernameChecking) {
      return Padding(
        padding: EdgeInsets.all(Layout.v(12)),
        child: SizedBox(
          width: Layout.v(16),
          height: Layout.v(16),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (_usernameResult == UsernameValidationResult.valid) {
      return Icon(Icons.check_circle_outline_rounded,
          color: AppColors.primary, size: Layout.v(20));
    }
    if (_usernameResult != null) {
      return Icon(Icons.cancel_outlined,
          color: AppColors.error, size: Layout.v(20));
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final username = _controller.text.trim();
    final auth = AuthScope.of(context);

    final finalResult = await validateUsername(username);
    if (finalResult != UsernameValidationResult.valid) {
      if (mounted) {
        setState(() {
          _usernameResult = finalResult;
          _usernameError = usernameErrorMessage(finalResult);
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await auth.createUserDocument(username);
    } catch (_) {
      if (mounted) {
        await InfoModal.show(
          context,
          title: AppLocalization.error,
          message: AppLocalization.unknownError,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Layout.init(context);

    return PageContainer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: Layout.symmetric(horizontal: 24, vertical: 32),
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Layout.v(16)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: Layout.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalization.pickUsername,
                          style: AppTextStyles.font22.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Layout.heightBox(12),
                        Text(
                          AppLocalization.usernamePickerDesc,
                          style: AppTextStyles.font14.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Layout.heightBox(24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _controller,
                              onChanged: _onUsernameChanged,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: AppTextStyles.font16
                                  .copyWith(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: AppLocalization.username,
                                suffixIcon: _buildSuffixIcon(),
                              ),
                            ),
                            if (_usernameError != null) ...[
                              Layout.heightBox(4),
                              Text(
                                _usernameError!,
                                style: AppTextStyles.font12
                                    .copyWith(color: AppColors.error),
                              ),
                            ],
                          ],
                        ),
                        Layout.heightBox(24),
                        ElevatedButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: AppButtonStyles.primaryFilled.copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (s) => s.contains(WidgetState.disabled)
                                  ? AppColors.disabled
                                  : AppColors.primary,
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: Layout.v(20),
                                  width: Layout.v(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppLocalization.confirm,
                                  style: AppTextStyles.font18.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: _canSubmit
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
