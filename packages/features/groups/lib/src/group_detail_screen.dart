// packages/features/groups/lib/src/group_detail_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'csv_export_stub.dart'
    if (dart.library.html) 'csv_export_web.dart'
    if (dart.library.io) 'csv_export_io.dart';

const _green = Color(0xFFC3FD00);
const _surface = Color(0xFF1A1A1A);
const _border = Color(0xFF2C2C2C);
const _textSecondary = Color(0xFF9E9E9E);

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(watchGroupsProvider);
    return groupAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: _green)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white))),
      ),
      data: (groups) {
        final group = groups.where((g) => g.id == groupId).firstOrNull;
        if (group == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            appBar: AppBar(backgroundColor: const Color(0xFF0A0A0A), iconTheme: const IconThemeData(color: Colors.white)),
            body: const Center(child: Text('Group not found', style: TextStyle(color: Colors.white))),
          );
        }
        return _GroupDetailBody(group: group);
      },
    );
  }
}

class _GroupDetailBody extends ConsumerStatefulWidget {
  const _GroupDetailBody({required this.group});
  final GroupEntity group;

  @override
  ConsumerState<_GroupDetailBody> createState() => _GroupDetailBodyState();
}

class _GroupDetailBodyState extends ConsumerState<_GroupDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  GroupEntity get group => widget.group;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(watchExpensesProvider(group.id));
    final expenses = expensesAsync.valueOrNull ?? [];
    final computedTotal = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final onMembersTab = _tab.index == 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _scrolled
            ? const Color(0xFF0A0A0A)
            : Colors.transparent,
        elevation: _scrolled ? 4 : 0,
        shadowColor: Colors.black54,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrolled ? 1.0 : 0.0,
          child: Text(
            group.name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _scrolled
                    ? _surface
                    : const Color(0xFF0A0A0A).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => _showGroupSettings(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: onMembersTab
          ? null
          : (_tab.index == 0
              ? FloatingActionButton.extended(
                  heroTag: 'addExpense',
                  onPressed: () =>
                      context.push('/expense/new?groupId=${group.id}'),
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                )
              : null),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.depth == 0) {
            final scrolled = n.metrics.pixels > 180;
            if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
          }
          return false;
        },
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: _LinkedInHeader(
                group: group,
                computedTotal: computedTotal,
                onEditPhoto: () => _showGroupSettings(context),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PillTabDelegate(
                controller: _tab,
                selectedIndex: _tab.index,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: [
              // ── Expenses ──────────────────────────────────────
              expensesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: _green, strokeWidth: 2)),
                error: (e, _) => Center(
                    child: Text(e.toString(),
                        style: const TextStyle(color: Colors.white))),
                data: (expenses) => expenses.isEmpty
                    ? _EmptyExpenses(groupId: group.id)
                    : _ExpenseList(expenses: expenses, group: group),
              ),
              // ── Balances ──────────────────────────────────────
              expensesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: _green, strokeWidth: 2)),
                error: (_, __) => const _ComingSoon(label: 'Balances'),
                data: (expenses) =>
                    _BalancesTab(expenses: expenses, group: group),
              ),
              // ── Charts ────────────────────────────────────────
              expensesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: _green, strokeWidth: 2)),
                error: (_, __) => const _ComingSoon(label: 'Charts'),
                data: (expenses) => expenses.isEmpty
                    ? const _ComingSoon(label: 'Charts')
                    : _ChartsTab(expenses: expenses, group: group),
              ),
              // ── Totals ────────────────────────────────────────
              expensesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: _green, strokeWidth: 2)),
                error: (_, __) => const _ComingSoon(label: 'Totals'),
                data: (expenses) => expenses.isEmpty
                    ? const _ComingSoon(label: 'Totals')
                    : _TotalsTab(expenses: expenses, group: group),
              ),
              // ── Whiteboard ────────────────────────────────────
              _WhiteboardTab(groupId: group.id),
              // ── Members ───────────────────────────────────────
              _MembersTab(
                group: group,
                onAddMember: () => _showAddMemberSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGroupSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _GroupSettingsSheet(group: group),
      ),
    );
  }

  Future<void> _exportCsv(
      List<ExpenseEntity> expenses, BuildContext context) async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }
    final buf = StringBuffer();
    buf.writeln('Date,Description,Category,Amount,Currency,Paid By');
    for (final e in expenses) {
      final date = e.createdAt.toIso8601String().substring(0, 10);
      final desc = '"${e.description.replaceAll('"', '""')}"';
      buf.writeln(
          '$date,$desc,${e.category.label},${e.amount.toStringAsFixed(2)},${e.currency},${e.paidBy}');
    }
    await downloadCsv(buf.toString(), '${group.name}_expenses.csv');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${expenses.length} expenses')),
      );
    }
  }

  void _showAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _AddMemberSheet(group: group),
      ),
    );
  }
}

// ── Pill tab bar delegate ─────────────────────────────────────────────────────
class _PillTabDelegate extends SliverPersistentHeaderDelegate {
  const _PillTabDelegate({
    required this.controller,
    required this.selectedIndex,
  });
  final TabController controller;
  final int selectedIndex;

  static const _labels = [
    'Expenses', 'Balances', 'Charts', 'Totals', 'Whiteboard', 'Members'
  ];
  static const _height = 56.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = i == selectedIndex;
          return GestureDetector(
            onTap: () => controller.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? _green : _surface,
                borderRadius: BorderRadius.circular(20),
                border: sel
                    ? null
                    : Border.all(color: _border, width: 1),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: _green.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  color: sel ? Colors.black : _textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_PillTabDelegate old) =>
      old.selectedIndex != selectedIndex;
}

// ── LinkedIn-style group header ───────────────────────────────────────────────
class _LinkedInHeader extends StatelessWidget {
  const _LinkedInHeader({
    required this.group,
    required this.computedTotal,
    required this.onEditPhoto,
  });
  final GroupEntity group;
  final double computedTotal;
  final VoidCallback onEditPhoto;

  static const _memberColors = [
    Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
    Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    final members = group.memberIds;
    final visibleMembers = members.length.clamp(0, 5);
    final overflow = members.length - visibleMembers;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Cover banner ─────────────────────────────────────────
        GestureDetector(
          onTap: onEditPhoto,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _green.withOpacity(0.25),
                  const Color(0xFF0A0A0A),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Subtle pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.06,
                    child: Image.asset(
                      'assets/images/logo_icon.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Edit',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Info row (below banner) ───────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Container(
            color: const Color(0xFF0A0A0A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group avatar overlapping banner
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: GestureDetector(
                    onTap: onEditPhoto,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0A0A0A), width: 3),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              group.name.isNotEmpty
                                  ? group.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: _green),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.black, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + stats
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          '$symbol${computedTotal.toStringAsFixed(0)} total · ${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Member avatars stack (right side)
                if (members.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32,
                          width: visibleMembers * 22.0 +
                              (overflow > 0 ? 24 : 0) +
                              8,
                          child: Stack(
                            children: [
                              for (int i = 0; i < visibleMembers; i++)
                                Positioned(
                                  left: i * 22.0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _memberColors[
                                              i % _memberColors.length]
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFF0A0A0A), width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + i),
                                        style: TextStyle(
                                            color: _memberColors[
                                                i % _memberColors.length],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                ),
                              if (overflow > 0)
                                Positioned(
                                  left: visibleMembers * 22.0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          _textSecondary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFF0A0A0A), width: 2),
                                    ),
                                    child: Center(
                                      child: Text('+$overflow',
                                          style: const TextStyle(
                                              color: _textSecondary,
                                              fontSize: 9)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Members',
                            style: TextStyle(
                                color: _textSecondary,
                                fontSize: 10,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Group Settings sheet (replaces popup menu) ────────────────────────────────
class _GroupSettingsSheet extends ConsumerStatefulWidget {
  const _GroupSettingsSheet({required this.group});
  final GroupEntity group;

  @override
  ConsumerState<_GroupSettingsSheet> createState() =>
      _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends ConsumerState<_GroupSettingsSheet> {
  GroupEntity get group => widget.group;

  static const _inviteBase = 'https://vikasnvcchauhan.github.io/splitbo';
  String get _inviteUrl => '$_inviteBase/#/invite/${group.id}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  const Text('Group Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _border),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SettingsRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Edit Group Photo',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo upload coming soon',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Color(0xFF1E1E1E),
                        ),
                      );
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.edit_outlined,
                    label: 'Edit Group Name',
                    onTap: () {
                      Navigator.pop(context);
                      _showEditName(context);
                    },
                  ),
                  const Divider(height: 1, color: _border,
                      indent: 20, endIndent: 20),
                  _SettingsRow(
                    icon: Icons.person_add_outlined,
                    label: 'Add Members',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddMemberSheet(context);
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.link_rounded,
                    label: 'Invite via Link',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _inviteUrl));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invite link copied',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Color(0xFF1E1E1E),
                        ),
                      );
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.qr_code_rounded,
                    label: 'Share QR Code',
                    onTap: () {
                      Navigator.pop(context);
                      _showQrCode(context);
                    },
                  ),
                  const Divider(height: 1, color: _border,
                      indent: 20, endIndent: 20),
                  _SettingsRow(
                    icon: Icons.people_outline_rounded,
                    label: 'View Members',
                    trailing: Text('${group.memberCount}',
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 14)),
                    onTap: () => _showMembers(context),
                  ),
                  const Divider(height: 1, color: _border,
                      indent: 20, endIndent: 20),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    label: 'Leave Group',
                    color: const Color(0xFFFFB347),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLeave(context);
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Group',
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteGroup(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditName(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _EditGroupSheet(group: group),
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _AddMemberSheet(group: group),
      ),
    );
  }

  void _showQrCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invite via QR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: _inviteUrl,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text('Scan to join "${group.name}"',
                style: const TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showMembers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Text('Members (${group.memberCount})',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: _textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _border),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  itemCount: group.memberIds.length,
                  itemBuilder: (_, i) {
                    const colors = [
                      Color(0xFFC3FD00), Color(0xFF00D4FF),
                      Color(0xFFFF6B9D), Color(0xFFFFB347),
                      Color(0xFF9B59B6), Color(0xFF2ECC71),
                    ];
                    final c = colors[i % colors.length];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                                color: c,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      title: Text('Member ${i + 1}',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          i == 0 ? 'Admin' : 'Member',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Leave Group',
            style: TextStyle(color: Colors.white)),
        content: Text('Leave "${group.name}"?',
            style: const TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement leave group
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leave group coming soon',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFF1E1E1E),
                ),
              );
            },
            child: const Text('Leave',
                style: TextStyle(color: Color(0xFFFFB347))),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Delete Group',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${group.name}"? This cannot be undone.',
          style: const TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref
                  .read(groupRepositoryProvider)
                  .deleteGroup(group.id);
              if (context.mounted) {
                result.fold(
                  ok: (_) => context.pop(),
                  err: (e) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: const Color(0xFF1E1E1E),
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: _textSecondary, size: 20),
    );
  }
}

// ── Charts tab ────────────────────────────────────────────────────────────────
class _ChartsTab extends StatelessWidget {
  const _ChartsTab({required this.expenses, required this.group});
  final List<ExpenseEntity> expenses;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    final byCategory = <ExpenseCategory, double>{};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1.0 : sorted.first.value;

    const barColors = [
      Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
      Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
      Color(0xFFFF6B6B), Color(0xFFE91E63), Color(0xFF03A9F4),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('Spending by Category',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        ...sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value.key;
          final amount = entry.value.value;
          final pct = amount / max;
          final color = barColors[i % barColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    Text('$symbol${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 8, color: const Color(0xFF252525)),
                      FractionallySizedBox(
                        widthFactor: pct.clamp(0.02, 1.0),
                        child: Container(height: 8, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Balances tab ──────────────────────────────────────────────────────────────
class _BalancesTab extends StatelessWidget {
  const _BalancesTab({required this.expenses, required this.group});
  final List<ExpenseEntity> expenses;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    // Simple net balance per member: paid - fair share
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    final memberCount = group.memberIds.length;
    if (memberCount == 0) return const _ComingSoon(label: 'Balances');
    final fairShare = total / memberCount;

    final paid = <String, double>{};
    for (final e in expenses) {
      paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amount;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('Who paid what',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Fair share per person: $symbol${fairShare.toStringAsFixed(0)}',
            style: const TextStyle(color: _textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ...paid.entries.map((entry) {
          final net = entry.value - fairShare;
          final isPositive = net > 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person_outline, color: _green, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          group.memberDisplayNames[entry.key] ??
                              'Member (${entry.key.substring(0, 6)}…)',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                      Text('Paid $symbol${entry.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isPositive ? 'gets back' : 'owes',
                      style: TextStyle(
                          color: isPositive
                              ? _green
                              : const Color(0xFFFF6B6B),
                          fontSize: 11),
                    ),
                    Text(
                      '$symbol${net.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                          color: isPositive
                              ? _green
                              : const Color(0xFFFF6B6B),
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Settle Up CTA
        if (paid.isNotEmpty)
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push('/balances'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text('Settle Up',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
      ],
    );
  }
}

// ── Totals tab ────────────────────────────────────────────────────────────────
class _TotalsTab extends StatelessWidget {
  const _TotalsTab({required this.expenses, required this.group});
  final List<ExpenseEntity> expenses;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    final byCategory = <ExpenseCategory, double>{};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Grand Total',
                  style: TextStyle(color: _textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text('$symbol${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: _green,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              Text('${expenses.length} expense${expenses.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: _textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('By Category',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...byCategory.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text('$symbol${e.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: _green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Whiteboard tab ────────────────────────────────────────────────────────────
class _WhiteboardTab extends StatefulWidget {
  const _WhiteboardTab({required this.groupId});
  final String groupId;

  @override
  State<_WhiteboardTab> createState() => _WhiteboardTabState();
}

class _WhiteboardTabState extends State<_WhiteboardTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _green.withOpacity(0.15)),
            ),
            child: const Text('Shared notes — visible to all group members',
                style: TextStyle(color: _green, fontSize: 11)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Write anything… grocery list, trip notes, reminders.',
                hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                border: InputBorder.none,
                filled: true,
                fillColor: _surface,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coming soon placeholder ───────────────────────────────────────────────────
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction_outlined,
              color: _textSecondary, size: 40),
          const SizedBox(height: 12),
          Text('$label coming soon',
              style: const TextStyle(
                  color: _textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
// ── Members tab ───────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.group, required this.onAddMember});
  final GroupEntity group;
  final VoidCallback onAddMember;

  static const _memberColors = [
    Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
    Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final members = group.memberIds;
    return Column(
      children: [
        // Add member header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '${members.length} Member${members.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddMember,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_outlined,
                          color: Colors.black, size: 16),
                      SizedBox(width: 6),
                      Text('Add Member',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _border),
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline,
                          color: _textSecondary, size: 40),
                      const SizedBox(height: 12),
                      const Text('No members yet',
                          style:
                              TextStyle(color: _textSecondary, fontSize: 14)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: onAddMember,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('+ Add First Member',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                    final memberId = members[i];
                    final color =
                        _memberColors[i % _memberColors.length];
                    final initials = memberId.length >= 2
                        ? memberId.substring(0, 2).toUpperCase()
                        : memberId.toUpperCase();
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: color.withOpacity(0.15),
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        memberId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: i == 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
// ── Add Member Sheet ──────────────────────────────────────────────────────────
class _AddMemberSheet extends ConsumerStatefulWidget {
  const _AddMemberSheet({required this.group});
  final GroupEntity group;

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<({String id, String displayName, String? avatarUrl})> _results = [];
  bool _searching = false;
  bool _addingGuest = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final result =
        await ref.read(groupRepositoryProvider).searchUsers(q.trim());
    if (!mounted) return;
    setState(() {
      _searching = false;
      _results = result.fold(
        ok: (list) => list
            .where((u) => !widget.group.memberIds.contains(u.id))
            .toList(),
        err: (_) => [],
      );
    });
  }

  Future<void> _addUser(String userId, String displayName) async {
    await ref.read(groupRepositoryProvider).addMembers(
          groupId: widget.group.id,
          userIds: [userId],
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$displayName added to group',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
      );
      setState(() => _results.removeWhere((r) => r.id == userId));
    }
  }

  Future<void> _addGuest() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final email = _emailCtrl.text.trim().toLowerCase();
    final phone = _phoneCtrl.text.trim();
    setState(() => _addingGuest = true);
    final firestore = ref.read(firebaseFirestoreProvider);

    // Try to find existing user by email or phone
    if (email.isNotEmpty || phone.isNotEmpty) {
      final query = email.isNotEmpty ? email : phone;
      final result = await ref.read(groupRepositoryProvider).searchUsers(query);
      final match = result.fold(
        ok: (list) => list.where((u) => !widget.group.memberIds.contains(u.id)).firstOrNull,
        err: (_) => null,
      );
      if (match != null) {
        await ref.read(groupRepositoryProvider).addMembers(
              groupId: widget.group.id,
              userIds: [match.id],
            );
        if (mounted) {
          setState(() {
            _addingGuest = false;
            _nameCtrl.clear();
            _emailCtrl.clear();
            _phoneCtrl.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${match.displayName} found on Splitbo and added!',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF1E1E1E),
            ),
          );
        }
        return;
      }
    }

    // No existing user — create guest
    final docRef = firestore.collection('${dbPrefix}users').doc();
    await docRef.set({
      'displayName': name,
      if (email.isNotEmpty) 'email': email,
      if (phone.isNotEmpty) 'phoneNumber': phone,
      'isGuest': true,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    await ref.read(groupRepositoryProvider).addMembers(
          groupId: widget.group.id,
          userIds: [docRef.id],
        );
    if (mounted) {
      setState(() {
        _addingGuest = false;
        _nameCtrl.clear();
        _emailCtrl.clear();
        _phoneCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added as guest',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text('Add Members',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              indicatorColor: _green,
              labelColor: _green,
              unselectedLabelColor: _textSecondary,
              tabs: const [
                Tab(text: 'Manual'),
                Tab(text: 'Search'),
                Tab(text: 'QR Invite'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _ManualTab(
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    phoneCtrl: _phoneCtrl,
                    adding: _addingGuest,
                    onAdd: _addGuest,
                  ),
                  _SearchTab(
                    ctrl: _searchCtrl,
                    results: _results,
                    searching: _searching,
                    onSearch: _search,
                    onAdd: _addUser,
                  ),
                  _QrInviteTab(group: widget.group),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab({
    required this.ctrl,
    required this.results,
    required this.searching,
    required this.onSearch,
    required this.onAdd,
  });
  final TextEditingController ctrl;
  final List<({String id, String displayName, String? avatarUrl})> results;
  final bool searching;
  final ValueChanged<String> onSearch;
  final void Function(String id, String name) onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name…',
              hintStyle: const TextStyle(color: _textSecondary),
              prefixIcon: const Icon(Icons.search, color: _textSecondary),
              filled: true,
              fillColor: const Color(0xFF252525),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (searching)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(color: _green, strokeWidth: 2),
            )
          else if (results.isEmpty && ctrl.text.length >= 2)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('No users found',
                  style: TextStyle(color: _textSecondary)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final u = results[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _green.withOpacity(0.15),
                      child: Text(
                        u.displayName.isNotEmpty
                            ? u.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: _green, fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text(u.displayName,
                        style: const TextStyle(color: Colors.white)),
                    trailing: TextButton(
                      onPressed: () => onAdd(u.id, u.displayName),
                      style: TextButton.styleFrom(foregroundColor: _green),
                      child: const Text('Add'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ManualTab extends StatelessWidget {
  const _ManualTab({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.adding,
    required this.onAdd,
  });
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final bool adding;
  final VoidCallback onAdd;

  static InputDecoration _fieldDeco(String label, String hint, IconData icon) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _textSecondary),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add by name. Provide email or phone to link an existing Splitbo account automatically.',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDeco('Name *', 'e.g. Rahul, Priya', Icons.person_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDeco('Email (optional)', 'email@example.com', Icons.email_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: _fieldDeco('Phone (optional)', '+91 98765 43210', Icons.phone_outlined),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: adding ? null : onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: adding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.black))
                  : const Text('Add',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrInviteTab extends ConsumerStatefulWidget {
  const _QrInviteTab({required this.group});
  final GroupEntity group;

  @override
  ConsumerState<_QrInviteTab> createState() => _QrInviteTabState();
}

class _QrInviteTabState extends ConsumerState<_QrInviteTab> {
  static const _inviteBase = 'https://vikasnvcchauhan.github.io/splitbo';
  static const _ttlSeconds = 600; // 10 minutes

  String? _code;
  bool _generating = false;
  int _secondsLeft = _ttlSeconds;
  Timer? _timer;

  static String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() { _generating = true; _secondsLeft = _ttlSeconds; });
    _timer?.cancel();
    final code = _randomCode();
    final expiresAt = DateTime.now().add(const Duration(seconds: _ttlSeconds));
    try {
      final firestore = ref.read(firebaseFirestoreProvider);
      final user = ref.read(authStateProvider).valueOrNull;
      await firestore.collection('${dbPrefix}invites').doc(code).set({
        'groupId': widget.group.id,
        'createdBy': user?.id ?? '',
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'status': 'pending',
      });
    } catch (_) {}
    if (!mounted) return;
    setState(() { _code = code; _generating = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          _code = null;
        }
      });
    });
  }

  String get _inviteUrl => '$_inviteBase/#/join/${_code ?? ''}';

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_generating) {
      return const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2));
    }
    if (_code == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('QR code expired', style: TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _generateCode,
              icon: const Icon(Icons.refresh, color: _green),
              label: const Text('Generate new code', style: TextStyle(color: _green)),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: _inviteUrl,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, color: _green, size: 16),
              const SizedBox(width: 6),
              Text(
                'Expires in ${_fmt(_secondsLeft)}',
                style: TextStyle(
                  color: _secondsLeft < 60 ? const Color(0xFFFF6B6B) : _green,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _generateCode,
                icon: const Icon(Icons.refresh, color: _textSecondary, size: 14),
                label: const Text('Refresh', style: TextStyle(color: _textSecondary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan to join — no account needed. Shows only a name entry screen.',
            style: TextStyle(color: _textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _inviteUrl,
                    style: const TextStyle(color: _textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _inviteUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied!',
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF1E1E1E),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Copy',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Group Sheet ──────────────────────────────────────────────────────────
class _EditGroupSheet extends ConsumerStatefulWidget {
  const _EditGroupSheet({required this.group});
  final GroupEntity group;

  @override
  ConsumerState<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<_EditGroupSheet> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final result = await ref
        .read(groupRepositoryProvider)
        .updateGroup(groupId: widget.group.id, name: name);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      ok: (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group updated', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF1E1E1E),
          ),
        );
      },
      err: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Edit Group',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Group name',
                labelStyle: const TextStyle(color: _textSecondary),
                prefixIcon: const Icon(Icons.group_outlined, color: _textSecondary),
                filled: true,
                fillColor: const Color(0xFF252525),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _green)),
              ),
            ),
            const SizedBox(height: 20),
            if (_nameCtrl.text.trim().isNotEmpty)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({required this.expenses, required this.group});
  final List<ExpenseEntity> expenses;
  final GroupEntity group;

  static const _categoryIcons = {
    ExpenseCategory.food: Icons.restaurant_outlined,
    ExpenseCategory.transport: Icons.directions_car_outlined,
    ExpenseCategory.accommodation: Icons.hotel_outlined,
    ExpenseCategory.entertainment: Icons.movie_outlined,
    ExpenseCategory.utilities: Icons.bolt_outlined,
    ExpenseCategory.shopping: Icons.shopping_bag_outlined,
    ExpenseCategory.medical: Icons.local_hospital_outlined,
    ExpenseCategory.education: Icons.school_outlined,
    ExpenseCategory.other: Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final e = expenses[i];
        final icon = _categoryIcons[e.category] ?? Icons.receipt_long_outlined;
        final diff = DateTime.now().difference(e.createdAt);
        final _ = diff; // unused after subtitle change
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        final dateStr = '${e.createdAt.day} ${months[e.createdAt.month - 1]} ${e.createdAt.year}';

        return GestureDetector(
          onTap: () => _showExpenseActions(context, ref, e),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _green, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.description,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('$dateStr · Split among ${group.memberCount}',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '$symbol${e.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: _green, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.more_vert, color: _textSecondary, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExpenseActions(
      BuildContext context, WidgetRef ref, ExpenseEntity e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.description,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${group.currency == 'INR' ? '₹' : group.currency}${e.amount.toStringAsFixed(2)} · ${e.category.label}',
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Expense',
              color: Colors.white,
              onTap: () {
                Navigator.pop(context);
                _showEditSheet(context, ref, e);
              },
            ),
            const SizedBox(height: 4),
            _ActionTile(
              icon: Icons.delete_outline,
              label: 'Delete Expense',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, e);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ExpenseEntity e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Delete Expense',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${e.description}"?',
          style: const TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref
                  .read(expenseRepositoryProvider)
                  .deleteExpense(groupId: group.id, expenseId: e.id);
              if (context.mounted) {
                result.fold(
                  ok: (_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Color(0xFF1E1E1E),
                    ),
                  ),
                  err: (err) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err.message,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: const Color(0xFF1E1E1E),
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, WidgetRef ref, ExpenseEntity e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _EditExpenseSheet(expense: e, group: group),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              color: _textSecondary, size: 48),
          const SizedBox(height: 16),
          const Text('No expenses yet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap + to add the first expense',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Edit expense sheet ────────────────────────────────────────────────────────
class _EditExpenseSheet extends ConsumerStatefulWidget {
  const _EditExpenseSheet({required this.expense, required this.group});
  final ExpenseEntity expense;
  final GroupEntity group;

  @override
  ConsumerState<_EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<_EditExpenseSheet> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late ExpenseCategory _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.expense.description);
    _amountCtrl = TextEditingController(
        text: widget.expense.amount.toStringAsFixed(0));
    _category = widget.expense.category;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    return _descCtrl.text.trim().isNotEmpty && amount > 0;
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (!_isValid) return;
    setState(() => _saving = true);
    final result = await ref.read(expenseRepositoryProvider).updateExpense(
          groupId: widget.group.id,
          expenseId: widget.expense.id,
          description: desc,
          amount: amount,
          category: _category,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      ok: (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF1E1E1E),
          ),
        );
      },
      err: (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Edit Expense',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DarkInputField(
              controller: _descCtrl,
              label: 'Description',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _DarkInputField(
              controller: _amountCtrl,
              label: 'Amount',
              type: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              dropdownColor: const Color(0xFF252525),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: _textSecondary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _green)),
                filled: true,
                fillColor: const Color(0xFF252525),
              ),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label,
                          style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),
            if (_isValid)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.black))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DarkInputField extends StatelessWidget {
  const _DarkInputField({
    required this.controller,
    required this.label,
    this.type,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final TextInputType? type;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: type,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green)),
        filled: true,
        fillColor: const Color(0xFF252525),
      ),
    );
  }
}
