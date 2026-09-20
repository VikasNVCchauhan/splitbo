import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

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
          'Activity',
          style: TextStyle(
              color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: groupsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colors.brandPrimary, strokeWidth: 2)),
        error: (e, _) => _EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load activity',
          subtitle: e.toString(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No activity yet',
              subtitle: 'Create a group and add expenses to see activity here.',
            );
          }
          return _ActivityFeed(groups: groups, ref: ref);
        },
      ),
    );
  }
}

class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed({required this.groups, required this.ref});
  final List<GroupEntity> groups;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final allExpensesAsync = groups.map((g) => r.watch(watchExpensesProvider(g.id))).toList();
    final allExpenses = <({ExpenseEntity expense, String groupName, String groupId})>[];

    for (int i = 0; i < groups.length; i++) {
      allExpensesAsync[i].whenData((expenses) {
        for (final e in expenses) {
          allExpenses.add((expense: e, groupName: groups[i].name, groupId: groups[i].id));
        }
      });
    }

    allExpenses.sort((a, b) => b.expense.createdAt.compareTo(a.expense.createdAt));

    if (allExpenses.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Add your first expense to see activity here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: allExpenses.length,
      itemBuilder: (context, i) {
        final item = allExpenses[i];
        return _ActivityTile(
          expense: item.expense,
          groupName: item.groupName,
          groupId: item.groupId,
        );
      },
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({
    required this.expense,
    required this.groupName,
    required this.groupId,
  });
  final ExpenseEntity expense;
  final String groupName;
  final String groupId;

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
    final colors = context.colors;
    final icon = _categoryIcons[expense.category] ?? Icons.receipt_long_outlined;
    final formattedDate = _formatDate(expense.createdAt);

    return GestureDetector(
      onTap: () => _showActions(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.brandPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$groupName · $formattedDate',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${expense.currency} ${expense.amount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: colors.brandPrimary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.more_vert, color: colors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              '${expense.currency} ${expense.amount.toStringAsFixed(2)} · $groupName',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: colors.brandPrimary),
              title: Text('Edit Expense',
                  style: TextStyle(color: colors.textPrimary)),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _showEditSheet(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Color(0xFFFF6B6B)),
              title: const Text('Delete Expense',
                  style: TextStyle(color: Color(0xFFFF6B6B))),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _EditExpenseSheet(expense: expense, groupId: groupId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surfaceRaised,
        title: Text('Delete Expense',
            style: TextStyle(color: colors.textPrimary)),
        content: Text('Delete "${expense.description}"?',
            style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(expenseRepositoryProvider)
                  .deleteExpense(groupId: groupId, expenseId: expense.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Expense deleted',
                        style: TextStyle(color: colors.textPrimary)),
                    backgroundColor: colors.surfaceRaised,
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}

// ── Edit expense sheet (used from activity) ───────────────────────────────────
class _EditExpenseSheet extends ConsumerStatefulWidget {
  const _EditExpenseSheet({required this.expense, required this.groupId});
  final ExpenseEntity expense;
  final String groupId;

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
    if (!_isValid) return;
    setState(() => _saving = true);
    final result = await ref.read(expenseRepositoryProvider).updateExpense(
          groupId: widget.groupId,
          expenseId: widget.expense.id,
          description: _descCtrl.text.trim(),
          amount: double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
          category: _category,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      ok: (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense updated',
                style: TextStyle(color: context.colors.textPrimary)),
            backgroundColor: context.colors.surfaceRaised,
          ),
        );
      },
      err: (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message,
              style: TextStyle(color: context.colors.textPrimary)),
          backgroundColor: context.colors.surfaceRaised,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Edit Expense',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.number,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              dropdownColor: colors.surfaceRaised,
              style: TextStyle(color: colors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: colors.textSecondary),
              ),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label,
                          style: TextStyle(color: colors.textPrimary))))
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

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.textDisabled, size: 48),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
