import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/localization/localization.dart';

// Effect for Transitioning
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
    );

class RootPagePopHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onBackInvoked;

  const RootPagePopHandler({
    super.key,
    required this.child,
    required this.onBackInvoked,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBackInvoked();
      },
      child: child,
    );
  }
}

final appRouter = GoRouter(
  // Populate Initial Location
  initialLocation: '',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) => _fadePage(
            state,
            RootPagePopHandler(
              onBackInvoked: () => _handleRootBack(context),
              // Populate this screen
              child: Text('Placeholder'),
            ),
          ),
        ),
        GoRoute(
          path: '',
          pageBuilder: (context, state) => _fadePage(
            state,
            RootPagePopHandler(
              onBackInvoked: () => _handleRootBack(context),
              // Populate this screen
              child: Text('Placeholder'),
            ),
          ),
        ),
      ],
    ),
  ],
);

// Global or static helper to handle the back button logic
void _handleRootBack(BuildContext context) {
  final shellState = context.findAncestorStateOfType<_AppShellState>();
  shellState?._onBackPressed();
}

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with WidgetsBindingObserver {
  // Drag swiping for navigation - remove if not needed
  double? _dragStartY;
  double _dragDelta = 0;
  DateTime? _lastBackPress;

  // Insert Routes Here
  static const _routes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This method catches the hardware back button press
  @override
  Future<bool> didPopRoute() async {
    final router = GoRouter.of(context);

    if (router.canPop()) {
      // If there's a sub-page (like Settings), go back normally
      router.pop();
      return true; // "true" tells the system we handled it
    } else {
      // We are on a root screen (Templates, History, etc.)
      _onBackPressed(); // Show your "Press again to exit" snackbar
      return true; // "true" prevents the app from closing immediately
    }
  }

  // Populate real routes here - must be the same as the ones in GoRouter
  int _locationToIndex(String location) {
    if (location.startsWith('')) return 0;
    if (location.startsWith('')) return 1;
    return 0;
  }

  // Press Back to Exit
  void _onBackPressed() {
    final now = DateTime.now();
    final lastPress = _lastBackPress;
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    if (lastPress == null ||
        now.difference(lastPress) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalization.pressBackToExit),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Place to subscribe to controllers

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // If didPop is true, it means something else already handled the pop
        if (didPop) return;

        final router = GoRouter.of(context);

        // We are in a sub-page, so we let the router pop
        if (router.canPop()) {
          router.pop();
          // We are on a root tab, trigger the double-tap logic
        } else {
          _onBackPressed();
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final swipeThresholdY = constraints.maxHeight * 0.80;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,

              // Swipe Navigation Logic 1
              onHorizontalDragStart: (details) {
                if (details.localPosition.dy >= swipeThresholdY) {
                  _dragStartY = details.localPosition.dy;
                  _dragDelta = 0;
                } else {
                  _dragStartY = null;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (_dragStartY != null) {
                  _dragDelta += details.delta.dx;
                }
              },
              // Swipe Navigation Logic 2
              onHorizontalDragEnd: (details) {
                if (_dragStartY != null && _dragDelta.abs() > 60) {
                  final location = GoRouterState.of(context).uri.toString();
                  final currentIndex = _locationToIndex(location);
                  final nextIndex = _dragDelta < 0
                      ? (currentIndex + 1).clamp(0, 2)
                      : (currentIndex - 1).clamp(0, 2);
                  if (nextIndex != currentIndex) {
                    context.go(_routes[nextIndex]);
                  }
                }
                _dragStartY = null;
              },
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
