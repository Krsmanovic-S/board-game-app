import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:sign_in_button/sign_in_button.dart';

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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            // Card Title
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
            ),

            if (!widget.isLogin) ...[
              Layout.heightBox(16),
              _buildTextField(
                controller: _usernameController,
                hint: AppLocalization.username,
                keyboardType: TextInputType.emailAddress,
              ),
            ],

            Layout.heightBox(16),

            _buildPasswordField(),

            // Continue with Google / Apple
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

            // Switch between Login and Register
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
              onPressed: () {},
              style: AppButtonStyles.primaryFilled.copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.disabled)
                      ? AppColors.primaryDim
                      : AppColors.primary,
                ),
              ),
              child: Text(
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: AppTextStyles.font16.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: AppLocalization.password,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
            size: Layout.v(20),
          ),
        ),
      ),
    );
  }
}
