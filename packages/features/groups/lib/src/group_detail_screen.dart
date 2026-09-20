// packages/features/groups/lib/src/group_detail_screen.dart

import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            tooltip: 'Invite',
            onPressed: () => _copyInviteLink(group.id, context),
          ),
          PopupMenuButton<String>(
            color: _surface,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'delete') _confirmDeleteGroup(context, ref);
            },
            itemBuilder: (_) => [
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupHeader(group: group),
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

  void _copyInviteLink(String groupId, BuildContext context) {
    const base = 'https://vikasnvcchauhan.github.io/splitbo';
    final link = '$base/#/invite/$groupId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final symbol = group.currency == 'INR' ? '₹' : group.currency;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: _surface,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _green),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${group.memberCount} member${group.memberCount == 1 ? '' : 's'} · $symbol${group.totalExpenses.toStringAsFixed(0)} total',
                  style:
                      const TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
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
