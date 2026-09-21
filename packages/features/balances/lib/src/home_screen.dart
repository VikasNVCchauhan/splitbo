import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _green = Color(0xFFC3FD00);
const _surface = Color(0xFF141414);
const _textSecondary = Color(0xFF9E9E9E);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final groupsAsync = ref.watch(watchGroupsProvider);
    final balancesAsync = ref.watch(watchBalancesProvider);
    final user = userAsync.valueOrNull;
    final firstName = user?.displayName.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _HomeAppBar(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),

            // ── Greeting ─────────────────────────────────────────────
            Text.rich(
              TextSpan(children: [
                const TextSpan(
                  text: 'Good to see you\nagain, ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
                TextSpan(
                  text: '$firstName!',
                  style: const TextStyle(
                      color: _green,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Balance summary chip ──────────────────────────────
            balancesAsync.whenData((balances) {
              final totalNet = balances.fold(0.0, (sum, b) => sum + b.net);
              if (totalNet.abs() < 0.01) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Text('All settled up!',
                          style: TextStyle(
                              color: _textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              }
              final isOwed = totalNet > 0;
              return GestureDetector(
                onTap: () => context.push('/balances'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwed
                        ? _green.withOpacity(0.08)
                        : const Color(0xFFFF6B6B).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isOwed
                          ? _green.withOpacity(0.2)
                          : const Color(0xFFFF6B6B).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOwed
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isOwed ? _green : const Color(0xFFFF6B6B),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOwed
                            ? 'You are owed ₹${totalNet.toStringAsFixed(0)} overall'
                            : 'You owe ₹${totalNet.abs().toStringAsFixed(0)} overall',
                        style: TextStyle(
                          color:
                              isOwed ? _green : const Color(0xFFFF6B6B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).valueOrNull ??
                const SizedBox.shrink(),

            const SizedBox(height: 20),

            // ── 2×2 Quick Action Grid ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Split Bill',
                    onTap: () => context.push('/expense/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add Expense',
                    onTap: () => context.push('/expense/new'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'View Stats',
                    onTap: () => context.push('/balances'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.group_outlined,
                    label: 'Groups',
                    onTap: () => context.go('/groups'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Recent Groups ─────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Recent Groups',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/groups'),
                  child: const Text('See all',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _green)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            groupsAsync.when(
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child:
                          CircularProgressIndicator(color: _green, strokeWidth: 2))),
              error: (_, __) =>
                  _EmptyGroupsHint(onTap: () => context.go('/groups')),
              data: (groups) {
                if (groups.isEmpty) {
                  return _EmptyGroupsHint(onTap: () => context.go('/groups'));
                }
                final recent = groups.take(5).toList();
                return SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length + 1,
                    itemBuilder: (_, i) {
                      if (i == recent.length) {
                        return _NewGroupCircle(
                            onTap: () => context.go('/groups'));
                      }
                      return _GroupCircle(
                          group: recent[i], index: i);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({required this.user});
  final UserEntity? user;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final initials = user?.displayName != null
        ? user!.displayName
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s[0].toUpperCase())
            .join()
        : '?';

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo — ClipOval removes white JPEG matte corners
          ClipOval(
            child: Image.asset(
              'assets/images/logo_icon.jpg',
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'Split',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              TextSpan(
                  text: 'bo',
                  style: TextStyle(
                      color: _green,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ],
      ),
      actions: [
        // Profile avatar → settings
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => context.go('/settings'),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: user?.avatarUrl != null ? null : _green.withOpacity(0.15),
                shape: BoxShape.circle,
                image: user?.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user!.avatarUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: user?.avatarUrl == null
                  ? Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: _green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────
class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Group circle (horizontal scroll) ─────────────────────────────────────────
class _GroupCircle extends StatelessWidget {
  const _GroupCircle({required this.group, required this.index});
  final GroupEntity group;
  final int index;

  static const _avatarColors = [
    Color(0xFF4DB6AC),
    Color(0xFFFF8A65),
    Color(0xFF7986CB),
    Color(0xFF81C784),
    Color(0xFFBA68C8),
  ];

  static const _emojiHints = {
    'trip': '✈️', 'travel': '✈️', 'goa': '🌴', 'beach': '🏖️',
    'vacation': '🏖️', 'holiday': '✈️',
    'lunch': '🍽️', 'dinner': '🍽️', 'food': '🍽️', 'coffee': '☕',
    'party': '🎉', 'birthday': '🎂',
    'flat': '🏠', 'home': '🏠', 'house': '🏠', 'flatmate': '🏠',
    'office': '💼', 'work': '💼', 'team': '💼',
  };

  String get _avatar {
    final lower = group.name.toLowerCase();
    for (final e in _emojiHints.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return group.name.isNotEmpty ? group.name[0].toUpperCase() : '?';
  }

  Color get _color => _avatarColors[index % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    final isEmoji = _avatar.length > 1;
    return GestureDetector(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isEmoji ? _color.withOpacity(0.15) : _color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _avatar,
                  style: TextStyle(
                    fontSize: isEmoji ? 28 : 24,
                    fontWeight: FontWeight.w700,
                    color: isEmoji ? null : _color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── New group circle ──────────────────────────────────────────────────────────
class _NewGroupCircle extends StatelessWidget {
  const _NewGroupCircle({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _green.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: _green, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'New',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty hint ────────────────────────────────────────────────────────────────
class _EmptyGroupsHint extends StatelessWidget {
  const _EmptyGroupsHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF252525)),
        ),
        child: Column(
          children: [
            const Icon(Icons.group_add_outlined,
                size: 36, color: _textSecondary),
            const SizedBox(height: 10),
            const Text('No groups yet',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Create a group to start splitting expenses',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _textSecondary)),
          ],
        ),
      ),
    );
  }
}
