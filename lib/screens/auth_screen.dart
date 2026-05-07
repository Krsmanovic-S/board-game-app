import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/controllers/auth_controller.dart';
import 'package:board_game_app/utils/auth.dart';
import 'package:board_game_app/widgets/info_modal.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    Layout.init(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Layout.symmetric(horizontal: 16, vertical: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: child,
                  ),
                ),
                child: _isLogin
                    ? _AuthCard(
                        key: const ValueKey('login'),
                        isLogin: true,
                        onToggle: () => setState(() => _isLogin = false),
                      )
                    : _AuthCard(
                        key: const ValueKey('register'),
                        isLogin: false,
                        onToggle: () => setState(() => _isLogin = true),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const _AuthCard({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final _googleSignIn = GoogleSignIn();

  // Real-time validation state
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmError;

  bool _usernameChecking = false;
  UsernameValidationResult? _usernameResult;

  Timer? _usernameDebounce;

  bool get _canSubmit {
    if (_isLoading) return false;
    if (widget.isLogin) {
      return _emailError == null &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty;
    }
    return _emailError == null &&
        _emailController.text.trim().isNotEmpty &&
        _usernameResult == UsernameValidationResult.valid &&
        _passwordError == null &&
        _passwordController.text.isNotEmpty &&
        _confirmError == null &&
        _confirmPasswordController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  // - Real-time validators ----------------------------------------------------

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = validateEmailFormat(value.trim());
    });
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
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

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
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

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = validatePasswordFormat(value);
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmError = value != _confirmPasswordController.text
            ? AppLocalization.passwordsNoMatch
            : null;
      }
    });
  }

  void _onConfirmChanged(String value) {
    setState(() {
      _confirmError = value != _passwordController.text
          ? AppLocalization.passwordsNoMatch
          : null;
    });
  }

  // - Submit ------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);
    try {
      if (widget.isLogin) {
        await _login();
      } else {
        await _register();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final controller = AuthScope.of(context);

    try {
      await controller.login(email, password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          AppLocalization.wrongCredentials,
        'network-request-failed' => AppLocalization.networkError,
        _ => AppLocalization.unknownError,
      };
      await InfoModal.show(
        context,
        title: AppLocalization.loginError,
        message: message,
      );
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final controller = AuthScope.of(context);

    // Final submit-time checks
    final usernameResult = await validateUsername(username);
    if (usernameResult != UsernameValidationResult.valid) {
      if (mounted) {
        setState(() {
          _usernameResult = usernameResult;
          _usernameError = usernameErrorMessage(usernameResult);
        });
      }
      return;
    }

    try {
      await controller.register(email, password, username);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'email-already-in-use' => AppLocalization.emailInUse,
        'network-request-failed' => AppLocalization.networkError,
        _ => AppLocalization.unknownError,
      };
      await InfoModal.show(
        context,
        title: AppLocalization.registerError,
        message: message,
      );
    }
  }

  Future<void> _continueWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        context.push('/username-picker', extra: userCredential.user);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      await InfoModal.show(
        context,
        title: AppLocalization.error,
        message: e.message ?? AppLocalization.unknownError,
      );
    }
  }

  Future<void> _continueWithApple() async {
    // Apple sign-in — implement when targeting iOS
  }

  // - Build -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Card(
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
              widget.isLogin
                  ? AppLocalization.loginTitle
                  : AppLocalization.registerTitle,
              style: AppTextStyles.font22.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Layout.heightBox(24),

            // Email
            _buildTextField(
              controller: _emailController,
              hint: AppLocalization.email,
              keyboardType: TextInputType.emailAddress,
              maxLength: 30,
              onChanged: _onEmailChanged,
              error: _emailError,
            ),

            // Username (register only)
            if (!widget.isLogin) ...[
              Layout.heightBox(16),
              _buildUsernameField(),
            ],

            Layout.heightBox(16),

            // Password
            _buildPasswordField(
              controller: _passwordController,
              hint: AppLocalization.password,
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onChanged:
                  widget.isLogin ? (_) => setState(() {}) : _onPasswordChanged,
              error: _passwordError,
            ),

            // Confirm password (register only)
            if (!widget.isLogin) ...[
              Layout.heightBox(16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: AppLocalization.confirmPassword,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                onChanged: _onConfirmChanged,
                error: _confirmError,
              ),
            ],

            // Google / Apple
            if (widget.isLogin) ...[
              Layout.heightBox(20),
              if (Platform.isAndroid)
                SignInButton(
                  Buttons.google,
                  padding: Layout.symmetric(vertical: 4),
                  text: AppLocalization.continueWithGoogle,
                  onPressed: _continueWithGoogle,
                ),
              if (Platform.isIOS)
                SignInButton(
                  Buttons.apple,
                  padding: Layout.symmetric(vertical: 4),
                  text: AppLocalization.continueWithApple,
                  onPressed: _continueWithApple,
                ),
            ],

            Layout.heightBox(20),

            // Toggle link
            GestureDetector(
              onTap: widget.onToggle,
              child: Text(
                widget.isLogin
                    ? AppLocalization.noAccount
                    : AppLocalization.haveAccount,
                style: AppTextStyles.font14.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Layout.heightBox(20),

            // Submit button
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
                      widget.isLogin
                          ? AppLocalization.loginTitle
                          : AppLocalization.registerTitle,
                      style: AppTextStyles.font18.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _canSubmit ? Colors.white : AppColors.textMuted,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // - Field builders ----------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    ValueChanged<String>? onChanged,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: maxLength != null
              ? [LengthLimitingTextInputFormatter(maxLength)]
              : null,
          style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
        if (error != null) ...[
          Layout.heightBox(4),
          Text(
            error,
            style: AppTextStyles.font12.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _usernameController,
          onChanged: _onUsernameChanged,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: AppLocalization.username,
            suffixIcon: _buildUsernameSuffix(),
          ),
        ),
        if (_usernameError != null) ...[
          Layout.heightBox(4),
          Text(
            _usernameError!,
            style: AppTextStyles.font12.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget? _buildUsernameSuffix() {
    if (_usernameController.text.isEmpty) return null;
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textMuted,
                size: Layout.v(20),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          Layout.heightBox(4),
          Text(
            error,
            style: AppTextStyles.font12.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
