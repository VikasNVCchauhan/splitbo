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
    final allExpenses = <({ExpenseEntity expense, String groupName})>[];

    for (int i = 0; i < groups.length; i++) {
      allExpensesAsync[i].whenData((expenses) {
        for (final e in expenses) {
          allExpenses.add((expense: e, groupName: groups[i].name));
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
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.expense, required this.groupName});
  final ExpenseEntity expense;
  final String groupName;

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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = _categoryIcons[expense.category] ?? Icons.receipt_long_outlined;
    final formattedDate = _formatDate(expense.createdAt);

    return Container(
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
