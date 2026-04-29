import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/providers/auth_controller.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
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

    if (!await validateEmail(context, email)) return;

    try {
      await controller.login(email, password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
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
    final confirm = _confirmPasswordController.text;
    final controller = AuthScope.of(context);

    if (!await validateEmail(context, email)) return;
    if (!mounted) return;
    if (!await validateUsername(context, username)) return;
    if (!mounted) return;
    if (!await validatePassword(context, password)) return;
    if (!mounted) return;
    if (!await validatePasswordsMatch(context, password, confirm)) return;
    if (!mounted) return;

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

            _buildTextField(
              controller: _emailController,
              hint: AppLocalization.email,
              keyboardType: TextInputType.emailAddress,
            ),

            if (!widget.isLogin) ...[
              Layout.heightBox(16),
              _buildTextField(
                controller: _usernameController,
                hint: AppLocalization.username,
              ),
            ],

            Layout.heightBox(16),

            _buildPasswordField(
              controller: _passwordController,
              hint: AppLocalization.password,
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),

            if (!widget.isLogin) ...[
              Layout.heightBox(16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: AppLocalization.confirmPassword,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ],

            if (widget.isLogin) ...[
              Layout.heightBox(20),
              SignInButton(
                Buttons.google,
                padding: Layout.symmetric(vertical: 4),
                text: AppLocalization.continueWithGoogle,
                onPressed: () {},
              ),
              Layout.heightBox(12),
              SignInButton(
                Buttons.apple,
                padding: Layout.symmetric(vertical: 4),
                text: AppLocalization.continueWithApple,
                onPressed: () {},
              ),
            ],

            Layout.heightBox(20),

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

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: AppButtonStyles.primaryFilled.copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.disabled)
                      ? AppColors.primaryDim
                      : AppColors.primary,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: Layout.v(20),
                      width: Layout.v(20),
                      child: CircularProgressIndicator(
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
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
    );
  }
}
