// packages/features/groups/lib/src/group_detail_screen.dart

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
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _green)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white))),
      ),
      data: (groups) {
        final group = groups.where((g) => g.id == groupId).firstOrNull;
        if (group == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
            body: const Center(child: Text('Group not found', style: TextStyle(color: Colors.white))),
          );
        }
        return _GroupDetailBody(group: group);
      },
    );
  }
}

class _GroupDetailBody extends ConsumerWidget {
  const _GroupDetailBody({required this.group});
  final GroupEntity group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(watchExpensesProvider(group.id));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _green),
        title: Text(
          group.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          expensesAsync.whenOrNull(
            data: (expenses) => IconButton(
              icon: const Icon(Icons.download_outlined, color: _green),
              tooltip: 'Export CSV',
              onPressed: () => _exportCsv(expenses, group, context),
            ),
          ) ?? const SizedBox.shrink(),
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: _green),
            tooltip: 'Add Member',
            onPressed: () => _showAddMemberSheet(context, ref),
          ),
          PopupMenuButton<String>(
            color: _surface,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'delete') _confirmDeleteGroup(context, ref);
              if (v == 'edit') _showEditGroupSheet(context, ref);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text('Edit Group',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 18),
                    SizedBox(width: 10),
                    Text('Delete Group',
                        style: TextStyle(color: Color(0xFFFF6B6B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expense/new?groupId=${group.id}'),
        backgroundColor: _green,
        foregroundColor: Colors.black,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupBanner(group: group),
          const Divider(height: 1, color: _border),
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _green, strokeWidth: 2)),
              error: (e, _) => Center(
                  child: Text(e.toString(),
                      style: const TextStyle(color: Colors.white))),
              data: (expenses) => expenses.isEmpty
                  ? _EmptyExpenses(groupId: group.id)
                  : _ExpenseList(expenses: expenses, group: group),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGroupSheet(BuildContext context, WidgetRef ref) {
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

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref) {
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

  Future<void> _exportCsv(
      List<ExpenseEntity> expenses, GroupEntity group, BuildContext context) async {
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

  void _showAddMemberSheet(BuildContext context, WidgetRef ref) {
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

  void _copyInviteLink(String groupId, BuildContext context) {
    const base = 'https://vikasnvcchauhan.github.io/splitbo';
    final link = '$base/#/invite/$groupId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E1E1E),
        duration: Duration(seconds: 2),
      ),
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
  final _guestCtrl = TextEditingController();
  List<({String id, String displayName, String? avatarUrl})> _results = [];
  bool _searching = false;
  bool _addingGuest = false;

  static const _inviteBase = 'https://vikasnvcchauhan.github.io/splitbo';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    _guestCtrl.dispose();
    super.dispose();
  }

  String get _inviteUrl => '$_inviteBase/#/invite/${widget.group.id}';

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
    final name = _guestCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _addingGuest = true);
    final firestore = ref.read(firebaseFirestoreProvider);
    final docRef = firestore.collection('${dbPrefix}users').doc();
    await docRef.set({
      'displayName': name,
      'email': null,
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
        _guestCtrl.clear();
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
                Tab(text: 'Add Guest'),
                Tab(text: 'Search'),
                Tab(text: 'Share'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _GuestTab(
                    ctrl: _guestCtrl,
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
                  _ShareTab(inviteUrl: _inviteUrl),
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

class _GuestTab extends StatelessWidget {
  const _GuestTab({
    required this.ctrl,
    required this.adding,
    required this.onAdd,
  });
  final TextEditingController ctrl;
  final bool adding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add someone without a Splitbo account. They\'ll appear as a member so you can split expenses with them.',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Guest name',
              hintText: 'e.g. Rahul, Priya',
              hintStyle: const TextStyle(color: _textSecondary),
              labelStyle: const TextStyle(color: _textSecondary),
              prefixIcon:
                  const Icon(Icons.person_outline, color: _textSecondary),
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
                  : const Text('Add Guest',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTab extends StatelessWidget {
  const _ShareTab({required this.inviteUrl});
  final String inviteUrl;

  @override
  Widget build(BuildContext context) {
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
              data: inviteUrl,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Share QR Code',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Anyone who scans this can join your group',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
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
                    inviteUrl,
                    style: const TextStyle(
                        color: _textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: inviteUrl));
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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

class _GroupBanner extends StatelessWidget {
  const _GroupBanner({required this.group});
  final GroupEntity group;

  static const _memberColors = [
    Color(0xFFC3FD00), Color(0xFF00D4FF), Color(0xFFFF6B9D),
    Color(0xFFFFB347), Color(0xFF9B59B6), Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    final members = group.memberIds;
    final visibleCount = members.length > 5 ? 5 : members.length;
    final overflow = members.length - visibleCount;

    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, color: _green),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                      style: const TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$symbol${group.totalExpenses.toStringAsFixed(0)} total expenses',
                      style: const TextStyle(
                          color: _green, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Members',
                style: TextStyle(
                    color: _textSecondary, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < visibleCount; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _memberColors[i % _memberColors.length]
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _memberColors[i % _memberColors.length]
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (i + 1).toString(),
                              style: TextStyle(
                                  color: _memberColors[i % _memberColors.length],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (overflow > 0)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _textSecondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _border),
                    ),
                    child: Center(
                      child: Text('+$overflow',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ],
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
        final when = diff.inDays > 0
            ? '${diff.inDays}d ago'
            : diff.inHours > 0
                ? '${diff.inHours}h ago'
                : '${diff.inMinutes}m ago';

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
                      Text('$when · ${e.category.label}',
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
