import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final userAsync = ref.watch(authStateProvider);
    final groupsAsync = ref.watch(watchGroupsProvider);
    final user = userAsync.valueOrNull;
    final firstName = user?.displayName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: _SplitboAppBar(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // ── Greeting ─────────────────────────────────────────
            Text(
              'Hi $firstName! 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Split smarter. Live better.',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Action Rows ─────────────────────────────────
            _ActionRow(
              icon: Icons.people_outline_rounded,
              title: 'Split a Bill',
              subtitle: 'Add friends and split in seconds',
              onTap: () => context.push('/expense/new'),
            ),
            const SizedBox(height: 10),
            _ActionRow(
              icon: Icons.receipt_long_outlined,
              title: 'Add Expense',
              subtitle: 'Keep track together',
              onTap: () => context.push('/expense/new'),
            ),
            const SizedBox(height: 10),
            _ActionRow(
              icon: Icons.bolt_outlined,
              title: 'Settle Up',
              subtitle: 'Clear balances easily',
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // ── New Expense Button ────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/expense/new'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      'New Expense',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Recent Groups ─────────────────────────────────────
            Row(
              children: [
                Text(
                  'Recent Groups',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/groups'),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            groupsAsync.when(
              loading: () => user == null
                  ? _EmptyGroupsHint(onTap: () => context.go('/groups'))
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              error: (_, __) => _EmptyGroupsHint(
                  onTap: () => context.go('/groups')),
              data: (groups) {
                if (groups.isEmpty) {
                  return _EmptyGroupsHint(
                    onTap: () => context.go('/groups'),
                  );
                }
                final recent = groups.take(3).toList();
                return Column(
                  children: recent
                      .asMap()
                      .entries
                      .map((e) => _RecentGroupRow(group: e.value, index: e.key))
                      .toList(),
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

// ── App bar ───────────────────────────────────────────────────────────────────
class _SplitboAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SplitboAppBar({required this.user});
  final UserEntity? user;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      backgroundColor: colors.backgroundDefault,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(
              painter: _MarkPainter(colors.brandPrimary),
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Split',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Bo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
          onPressed: () => context.push('/activity'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: colors.brandPrimaryLt,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    user?.initials ?? '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.brandPrimaryDk,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: colors.brandPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent group row ──────────────────────────────────────────────────────────
class _RecentGroupRow extends StatelessWidget {
  const _RecentGroupRow({required this.group, required this.index});
  final GroupEntity group;
  final int index;

  static const _colors = [
    Color(0xFF4DB6AC), // teal  – travel / trips
    Color(0xFFFF8A65), // orange – food / lunch
    Color(0xFF7986CB), // indigo – work / office
    Color(0xFF81C784), // green  – general
    Color(0xFFBA68C8), // purple – misc
  ];

  static const _emojiHints = {
    'trip': '✈️', 'travel': '✈️', 'goa': '🌴', 'beach': '🏖️',
    'vacation': '🏖️', 'holiday': '✈️',
    'lunch': '🍽️', 'dinner': '🍽️', 'food': '🍽️', 'coffee': '☕',
    'party': '🎉', 'birthday': '🎂',
    'flat': '🏠', 'home': '🏠', 'house': '🏠', 'flatmate': '🏠',
    'office': '💼', 'work': '💼', 'team': '💼',
    'gym': '💪', 'sport': '⚽',
    'movie': '🎬', 'netflix': '🎬',
  };

  String get _avatar {
    final lower = group.name.toLowerCase();
    for (final entry in _emojiHints.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return group.name.isNotEmpty ? group.name[0].toUpperCase() : '?';
  }

  Color get _avatarColor => _colors[index % _colors.length];

  String _fmt(double v) =>
      v >= 1000 ? '₹${(v / 1000).toStringAsFixed(1)}k' : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = group.totalExpenses;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _avatarColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _avatar.length == 1
                  ? Text(
                      _avatar,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _avatarColor,
                      ),
                    )
                  : Text(_avatar, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total > 0
                      ? '${group.memberCount} member${group.memberCount == 1 ? '' : 's'} · ${_fmt(total)} total'
                      : '${group.memberCount} member${group.memberCount == 1 ? '' : 's'} · All settled up 🎉',
                  style: TextStyle(
                    fontSize: 12,
                    color: total > 0 ? colors.textSecondary : const Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                total > 0 ? _fmt(total) : '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: colors.textSecondary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty groups hint ─────────────────────────────────────────────────────────
class _EmptyGroupsHint extends StatelessWidget {
  const _EmptyGroupsHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Column(
          children: [
            Icon(Icons.group_add_outlined, size: 36, color: colors.textDisabled),
            const SizedBox(height: 8),
            Text(
              'No groups yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a group to start splitting expenses',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared mini logo-mark painter — mirrors logo_mark.svg ────────────────────
class _MarkPainter extends CustomPainter {
  final Color color;
  const _MarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 512;
    final p = Paint()..color = color..style = PaintingStyle.fill;

    // Dot
    canvas.drawCircle(Offset(178 * s, 120 * s), 48 * s, p);

    // Blade
    final blade = Path()
      ..moveTo(166 * s, 218 * s)
      ..cubicTo(105 * s, 275 * s, 100 * s, 324 * s, 154 * s, 378 * s)
      ..cubicTo(192 * s, 416 * s, 246 * s, 364 * s, 290 * s, 320 * s)
      ..lineTo(426 * s, 184 * s)
      ..lineTo(426 * s, 84 * s)
      ..lineTo(326 * s, 84 * s)
      ..close();
    canvas.drawPath(blade, p);

    // Crescent with evenodd hole (center 288,368 r=38)
    final crescent = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(346 * s, 294 * s)
      ..cubicTo(407 * s, 237 * s, 412 * s, 188 * s, 358 * s, 134 * s)
      ..cubicTo(320 * s, 96 * s, 266 * s, 148 * s, 222 * s, 192 * s)
      ..lineTo(86 * s, 328 * s)
      ..lineTo(86 * s, 428 * s)
      ..lineTo(186 * s, 428 * s)
      ..close();
    crescent.addOval(
        Rect.fromCircle(center: Offset(288 * s, 368 * s), radius: 38 * s));
    canvas.drawPath(crescent, p);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.color != color;
}
