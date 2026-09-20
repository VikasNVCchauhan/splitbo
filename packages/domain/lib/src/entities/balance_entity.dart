// packages/domain/lib/src/entities/balance_entity.dart
//
// Balances are computed exclusively by Cloud Functions and stored in Firestore.
// Clients NEVER write to balance documents — they only read/watch them.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A single directed debt: [fromUserId] owes [toUserId] [amount].
@immutable
class BalanceDetail extends Equatable {
  const BalanceDetail({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  final String fromUserId;
  final String toUserId;

  /// Always positive — direction is encoded in from/to fields.
  final double amount;

  @override
  List<Object?> get props => [fromUserId, toUserId, amount];
}

/// Pre-computed balance for one user within one group.
@immutable
class BalanceEntity extends Equatable {
  const BalanceEntity({
    required this.groupId,
    required this.userId,
    required this.net,
    required this.details,
    required this.updatedAt,
    this.currency = 'INR',
  });

  final String groupId;
  final String userId;

  /// Positive = others owe this user. Negative = this user owes others.
  final double net;

  final List<BalanceDetail> details;
  final DateTime updatedAt;
  final String currency;

  bool get isSettled => net.abs() < 0.01;
  bool get isOwed    => net > 0.01;
  bool get owes      => net < -0.01;

  /// Debts this user owes to specific others.
  List<BalanceDetail> get myDebts =>
      details.where((d) => d.fromUserId == userId).toList();

  /// Amounts others owe to this user.
  List<BalanceDetail> get owedToMe =>
      details.where((d) => d.toUserId == userId).toList();

  @override
  List<Object?> get props => [groupId, userId, net, details, updatedAt, currency];
}
