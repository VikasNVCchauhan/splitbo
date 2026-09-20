// packages/domain/lib/src/entities/expense_entity.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  utilities,
  entertainment,
  shopping,
  medical,
  education,
  other;

  String get label => switch (this) {
        ExpenseCategory.food          => 'Food & Drink',
        ExpenseCategory.transport     => 'Transport',
        ExpenseCategory.accommodation => 'Accommodation',
        ExpenseCategory.utilities     => 'Utilities',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.shopping      => 'Shopping',
        ExpenseCategory.medical       => 'Medical',
        ExpenseCategory.education     => 'Education',
        ExpenseCategory.other         => 'Other',
      };
}

@immutable
class SplitEntity extends Equatable {
  const SplitEntity({
    required this.userId,
    required this.amount,
  });

  final String userId;

  /// Exact amount this user owes (never a ratio — stored as final value).
  final double amount;

  SplitEntity copyWith({double? amount}) =>
      SplitEntity(userId: userId, amount: amount ?? this.amount);

  @override
  List<Object?> get props => [userId, amount];
}

@immutable
class ExpenseEntity extends Equatable {
  const ExpenseEntity({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splits,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.currency = 'INR',
    this.category = ExpenseCategory.other,
    this.receiptUrl,
    this.notes,
  });

  final String id;
  final String groupId;
  final String description;

  /// Total amount of this expense.
  final double amount;

  final String currency;

  /// userId of the person who paid. Multi-payer support is Phase 2.
  final String paidBy;

  /// One SplitEntity per member. Amounts must sum to [amount].
  final List<SplitEntity> splits;

  final ExpenseCategory category;
  final String? receiptUrl;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Amount owed to [paidBy] = total minus their own split.
  double owedToPayer(String payerId) {
    final payerSplit = splits
        .where((s) => s.userId == payerId)
        .fold(0.0, (sum, s) => sum + s.amount);
    return amount - payerSplit;
  }

  ExpenseEntity copyWith({
    String? description,
    double? amount,
    String? currency,
    String? paidBy,
    List<SplitEntity>? splits,
    ExpenseCategory? category,
    String? receiptUrl,
    String? notes,
    DateTime? updatedAt,
  }) =>
      ExpenseEntity(
        id: id,
        groupId: groupId,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        paidBy: paidBy ?? this.paidBy,
        splits: splits ?? this.splits,
        category: category ?? this.category,
        receiptUrl: receiptUrl ?? this.receiptUrl,
        notes: notes ?? this.notes,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        groupId,
        description,
        amount,
        currency,
        paidBy,
        splits,
        category,
        receiptUrl,
        notes,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
