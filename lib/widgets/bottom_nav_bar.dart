import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/providers/settings_controller.dart';
import 'package:board_game_app/app/layout.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  int _locationToIndex(String location) {
    if (location.startsWith('/auth')) return 0;
    if (location.startsWith('/browse')) return 1;
    if (location.startsWith('/watchlist')) return 2;
    if (location.startsWith('/profile')) return 3;

    return 2;
  }

  @override
  Widget build(BuildContext context) {
    SettingsScope.of(context); // subscribe to theme changes
    final location = GoRouterState.of(context).uri.toString();
    print('Loc: $location');
    final currentIndex = _locationToIndex(location);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: Layout.symmetric(vertical: 12),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.explore,
                label: AppLocalization.browseLabel,
                isActive: currentIndex == 1,
                onTap: () => context.go('/browse'),
              ),
              _NavDivider(),
              _NavItem(
                icon: Icons.remove_red_eye_rounded,
                label: AppLocalization.watchlistLabel,
                isActive: currentIndex == 2,
                onTap: () => context.go('/watchlist'),
              ),
              _NavDivider(),
              _NavItem(
                icon: Icons.person,
                label: AppLocalization.profileLabel,
                isActive: currentIndex == 3,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: Layout.v(48),
      color: AppColors.divider.withValues(alpha: 0.3),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnim = Tween(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    const inactiveColor = AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(opacity: _opacityAnim.value, child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: widget.isActive ? 24 : 0,
                height: 3,
                margin: Layout.only(bottom: 4),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                widget.icon,
                size: Layout.v(24),
                color: widget.isActive ? activeColor : inactiveColor,
              ),
              Layout.heightBox(4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.font12.copyWith(
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isActive ? activeColor : inactiveColor,
                  letterSpacing: 0.3,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
