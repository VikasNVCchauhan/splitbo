import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final groupsAsync = ref.watch(watchGroupsProvider);

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.backgroundDefault,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: TextStyle(color: colors.semanticError)),
        ),
        data: (groups) => _GroupsBody(
          groups: groups,
          onCreateTap: () => _showCreateGroupSheet(context, ref),
          onGroupTap: (g) => context.push('/groups/${g.id}'),
        ),
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const _CreateGroupSheet(),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _GroupsBody extends StatelessWidget {
  const _GroupsBody({
    required this.groups,
    required this.onCreateTap,
    required this.onGroupTap,
  });

  final List<GroupEntity> groups;
  final VoidCallback onCreateTap;
  final void Function(GroupEntity) onGroupTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Create a Group button — always visible at top
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onCreateTap,
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
                  'Create a Group',
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

        if (groups.isEmpty) ...[
          const SizedBox(height: 48),
          _EmptyState(),
        ] else ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Your Groups',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...groups.map((g) => _GroupCard(
                group: g,
                onTap: () => onGroupTap(g),
              )),
        ],
      ],
    );
  }
}

// ── Group card ────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});
  final GroupEntity group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final symbol = group.currency == 'INR' ? '₹' : group.currency;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  group.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
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
                  const SizedBox(height: 2),
                  Text(
                    '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$symbol${group.totalExpenses.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: colors.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Icon(Icons.group_outlined, size: 56, color: colors.textDisabled),
        const SizedBox(height: 16),
        Text(
          'No groups yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a group to start splitting\nexpenses with friends.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      ],
    );
  }
}

// ── Create group sheet ────────────────────────────────────────────────────────
class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  String _currency = 'INR';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _saving = true);
    final result = await ref.read(groupRepositoryProvider).createGroup(
          name: name,
          description: '',
          currency: _currency,
          memberIds: [user.id],
        );
    if (mounted) {
      setState(() => _saving = false);
      result.fold(
        ok: (_) => Navigator.of(context).pop(),
        err: (err) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'New Group',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'e.g. Goa Trip, Flat Mates',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: const [
              DropdownMenuItem(value: 'INR', child: Text('₹ INR – Indian Rupee')),
              DropdownMenuItem(value: 'USD', child: Text('\$ USD – US Dollar')),
              DropdownMenuItem(value: 'EUR', child: Text('€ EUR – Euro')),
              DropdownMenuItem(value: 'GBP', child: Text('£ GBP – Pound')),
            ],
            onChanged: (v) => setState(() => _currency = v!),
            dropdownColor: colors.surfaceOverlay,
            style: TextStyle(color: colors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Create Group',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
