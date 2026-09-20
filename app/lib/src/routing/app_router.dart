// app/lib/src/routing/app_router.dart
// Manual Riverpod provider — no code-gen, no build_runner needed.

import 'dart:async';

import 'package:data/data.dart';
import 'package:feature_activity/feature_activity.dart';
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
  static const friends    = '/friends';
  static const activity   = '/activity';
  static const settings   = '/settings';
  static const signIn     = '/auth/sign-in';
  static const signUp     = '/auth/sign-up';
  static const expenseNew = '/expense/new';

  static String groupDetail(String id)   => '/groups/$id';
  static String expenseDetail(String id) => '/expense/$id';
  static String inviteGroup(String id)   => '/invite/$id';
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
                  builder: (_, state) => GroupDetailScreen(
                    groupId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.friends,
              builder: (_, __) => const FriendsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.activity,
              builder: (_, __) => const ActivityScreen(),
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
        path: '/invite/:id',
        builder: (_, state) => _InviteScreen(
          groupId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/balances',
        builder: (_, __) => const BalanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseNew,
        pageBuilder: (_, state) => MaterialPage(
          fullscreenDialog: true,
          child: AddExpenseScreen(
            initialGroupId: state.uri.queryParameters['groupId'],
          ),
        ),
      ),
      GoRoute(
        path: '/expense/:id',
        builder: (_, state) => _ExpenseNotFoundScreen(
          expenseId: state.pathParameters['id']!,
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

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;

  static const _brandGreen = Color(0xFFC3FD00);
  static const _inactive = Color(0xFF757575);
  static const _bg = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Save FCM token whenever signed-in user changes
    ref.watch(saveFcmTokenProvider);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: _bg,
        indicatorColor: _brandGreen.withOpacity(0.15),
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _brandGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded, color: _brandGreen),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: _brandGreen),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: _brandGreen),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: _brandGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ExpenseNotFoundScreen extends StatelessWidget {
  const _ExpenseNotFoundScreen({required this.expenseId});
  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFC3FD00)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                color: Color(0xFF555555), size: 48),
            const SizedBox(height: 16),
            const Text('Expense not found',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Open the group to view this expense.',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home',
                  style: TextStyle(color: Color(0xFFC3FD00))),
            ),
          ],
        ),
      ),
    );
  }
}

// Opens when someone taps an invite link — auto-joins group after sign-in.
class _InviteScreen extends ConsumerStatefulWidget {
  const _InviteScreen({required this.groupId});
  final String groupId;

  @override
  ConsumerState<_InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<_InviteScreen> {
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryJoin());
  }

  Future<void> _tryJoin() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      // Not signed in — redirect to sign-in, then come back
      if (mounted) context.go(AppRoutes.signIn);
      return;
    }
    setState(() => _joining = true);
    await ref.read(groupRepositoryProvider).addMembers(
      groupId: widget.groupId,
      userIds: [user.id],
    );
    if (mounted) {
      setState(() => _joining = false);
      context.go(AppRoutes.groupDetail(widget.groupId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Color(0xFFC3FD00), strokeWidth: 2),
            const SizedBox(height: 20),
            Text(
              _joining ? 'Joining group…' : 'Checking sign-in…',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
