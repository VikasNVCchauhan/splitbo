// app/lib/src/routing/app_router.dart
// Manual Riverpod provider — no code-gen, no build_runner needed.

import 'dart:async';

import 'package:data/data.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_balances/feature_balances.dart';
import 'package:feature_expenses/feature_expenses.dart';
import 'package:feature_groups/feature_groups.dart';
import 'package:feature_settings/feature_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home       = '/home';
  static const groups     = '/groups';
  static const activity   = '/activity';
  static const settings   = '/settings';
  static const signIn     = '/auth/sign-in';
  static const signUp     = '/auth/sign-up';
  static const expenseNew = '/expense/new';

  static String groupDetail(String id)   => '/groups/$id';
  static String expenseDetail(String id) => '/expense/$id';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.signIn,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Debug mode: skip auth guard for local UI testing
      if (kDebugMode) return null;

      final container = ProviderScope.containerOf(context);
      final userAsync = container.read(authStateProvider);

      // While auth is loading, don't redirect — wait for it to resolve
      if (userAsync.isLoading) return null;

      final isSignedIn = userAsync.valueOrNull != null;
      final onAuthPage = state.matchedLocation.startsWith('/auth');

      if (!isSignedIn && !onAuthPage) return AppRoutes.signIn;
      if (isSignedIn && onAuthPage) return AppRoutes.home;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.groups,
              builder: (_, __) => const GroupsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => _PlaceholderScreen(
                    label: 'Group: ${state.pathParameters['id']}',
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.activity,
              builder: (_, __) =>
                  const _PlaceholderScreen(label: 'Activity'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseNew,
        pageBuilder: (_, __) => const MaterialPage(
          fullscreenDialog: true,
          child: AddExpenseScreen(),
        ),
      ),
      GoRoute(
        path: '/expense/:id',
        builder: (_, state) => _PlaceholderScreen(
          label: 'Expense: ${state.pathParameters['id']}',
        ),
      ),
    ],
  );
});

// Notifies go_router when auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(ProviderRef ref) {
    _sub = ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;

  static const _brandGreen = Color(0xFFC3FD00);
  static const _inactive = Color(0xFF757575);
  static const _bg = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      floatingActionButton: shell.currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.expenseNew),
              backgroundColor: _brandGreen,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: _bg,
        elevation: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              selected: shell.currentIndex == 0,
              onTap: () => shell.goBranch(0),
            ),
            _NavItem(
              icon: Icons.group_outlined,
              activeIcon: Icons.group_rounded,
              label: 'Groups',
              selected: shell.currentIndex == 1,
              onTap: () => shell.goBranch(1),
            ),
            const Expanded(child: SizedBox()), // FAB notch
            _NavItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Activity',
              selected: shell.currentIndex == 2,
              onTap: () => shell.goBranch(2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              selected: shell.currentIndex == 3,
              onTap: () => shell.goBranch(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _brandGreen = Color(0xFFC3FD00);
  static const _inactive = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? _brandGreen : _inactive,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? _brandGreen : _inactive,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
