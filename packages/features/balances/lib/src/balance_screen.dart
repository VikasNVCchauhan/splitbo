import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Public screen ─────────────────────────────────────────────────────────────
class BalanceScreen extends ConsumerWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final groupsAsync = ref.watch(watchGroupsProvider);

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.backgroundDefault,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'Balances',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC3FD00)),
        ),
        error: (_, __) => const Center(child: Text('Could not load groups.')),
        data: (groups) {
          if (groups.isEmpty || currentUser == null) return const _EmptyBalances();
          return _BalanceSummary(groups: groups, currentUser: currentUser);
        },
      ),
    );
  }
}

// ── Balance data row (internal model) ────────────────────────────────────────
class _BalanceRow {
  const _BalanceRow({
    required this.groupId,
    required this.groupName,
    required this.otherUserId,
    required this.otherName,
    required this.amount,
    required this.currency,
  });

  final String groupId;
  final String groupName;
  final String otherUserId;
  final String otherName;
  // positive = otherUser owes me, negative = I owe otherUser
  final double amount;
  final String currency;
}

// ── Aggregate view ────────────────────────────────────────────────────────────
class _BalanceSummary extends ConsumerWidget {
  const _BalanceSummary({required this.groups, required this.currentUser});
  final List<GroupEntity> groups;
  final UserEntity currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    final allRows = <_BalanceRow>[];
    for (final group in groups) {
      final net = ref.watch(computeGroupBalancesProvider(group.id));
      net.forEach((otherUserId, amount) {
        if (amount.abs() < 0.01) return;
        final name = group.memberDisplayNames[otherUserId] ?? otherUserId;
        allRows.add(_BalanceRow(
          groupId: group.id,
          groupName: group.name,
          otherUserId: otherUserId,
          otherName: name,
          amount: amount,
          currency: group.currency,
        ));
      });
    }

    // debts first, then credits
    allRows.sort((a, b) => a.amount.compareTo(b.amount));

    double totalOwe = 0;
    double totalOwed = 0;
    for (final row in allRows) {
      if (row.amount < 0) totalOwe += row.amount.abs();
      else totalOwed += row.amount;
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'You owe',
                    amount: totalOwe,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Owed to you',
                    amount: totalOwed,
                    color: const Color(0xFFC3FD00),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (allRows.isEmpty)
          const SliverFillRemaining(child: _EmptyBalances())
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _BalanceRowTile(row: allRows[i], currentUser: currentUser),
              childCount: allRows.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ],
    );
  }
}

// ── Single balance row tile ───────────────────────────────────────────────────
class _BalanceRowTile extends StatelessWidget {
  const _BalanceRowTile({required this.row, required this.currentUser});
  final _BalanceRow row;
  final UserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iOwe = row.amount < 0;
    final absAmount = row.amount.abs();
    final amtStr = '₹${absAmount.toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => _showSettleUp(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iOwe
                  ? const Color(0xFFFF6B6B).withOpacity(0.15)
                  : const Color(0xFFC3FD00).withOpacity(0.15),
              child: Text(
                row.otherName.isNotEmpty
                    ? row.otherName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: iOwe
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFFC3FD00),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    iOwe
                        ? 'You owe ${row.otherName}'
                        : '${row.otherName} owes you',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.groupName,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amtStr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: iOwe
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFC3FD00),
                  ),
                ),
                if (iOwe)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC3FD00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Settle',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettleUp(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettleUpSheet(row: row, currentUser: currentUser),
    );
  }
}

// ── Settle Up bottom sheet ────────────────────────────────────────────────────
class _SettleUpSheet extends ConsumerStatefulWidget {
  const _SettleUpSheet({required this.row, required this.currentUser});
  final _BalanceRow row;
  final UserEntity currentUser;

  @override
  ConsumerState<_SettleUpSheet> createState() => _SettleUpSheetState();
}

class _SettleUpSheetState extends ConsumerState<_SettleUpSheet> {
  late final TextEditingController _amountCtrl;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.row.amount.abs().toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _markSettled() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);

    final iOwe = widget.row.amount < 0;
    final fromUserId = iOwe ? widget.currentUser.id : widget.row.otherUserId;
    final toUserId = iOwe ? widget.row.otherUserId : widget.currentUser.id;

    final result = await ref.read(balanceRepositoryProvider).settleUp(
          groupId: widget.row.groupId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
          currency: widget.row.currency,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      ok: (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFFC3FD00), size: 18),
                SizedBox(width: 8),
                Text('Marked as settled ✓'),
              ],
            ),
            backgroundColor: Color(0xFF1E1E1E),
          ),
        );
      },
      err: (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.message)),
      ),
    );
  }

  Future<void> _payViaUpi() async {
    final amount = _amountCtrl.text.replaceAll(',', '');
    final note = Uri.encodeComponent('Splitbo: ${widget.row.groupName}');
    final name = Uri.encodeComponent(widget.row.otherName);
    final uri = Uri.parse('upi://pay?pn=$name&am=$amount&cu=INR&tn=$note');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: open GPay on web or if no UPI apps installed
      await launchUrl(
        Uri.parse('https://gpay.app.goo.gl/'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iOwe = widget.row.amount < 0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                iOwe
                    ? 'Settle up with ${widget.row.otherName}'
                    : '${widget.row.otherName} settles up',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.row.groupName,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Amount input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixText: '₹  ',
                  prefixStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFC3FD00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _noteCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFC3FD00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (!kIsWeb && iOwe) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _payViaUpi,
                        icon: const Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFFC3FD00), size: 18),
                        label: const Text(
                          'Pay via UPI / GPay / PhonePe',
                          style: TextStyle(
                            color: Color(0xFFC3FD00),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC3FD00)),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _markSettled,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC3FD00),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            const Color(0xFFC3FD00).withOpacity(0.4),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.black),
                            )
                          : const Text(
                              'Mark as Settled',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyBalances extends StatelessWidget {
  const _EmptyBalances();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 72,
            color: const Color(0xFFC3FD00).withOpacity(0.35),
          ),
          const SizedBox(height: 20),
          Text(
            'All settled up! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No outstanding balances across your groups.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
