// packages/domain/lib/src/repositories/expense_repository.dart

import 'package:core/core.dart';

import '../entities/expense_entity.dart';

abstract interface class ExpenseRepository {
  /// Real-time stream of all expenses in a group, newest first.
  Stream<List<ExpenseEntity>> watchExpenses(String groupId);

  Future<Result<ExpenseEntity, AppError>> getExpense(String expenseId);

  Future<Result<ExpenseEntity, AppError>> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String currency,
    required String paidBy,
    required List<SplitEntity> splits,
    required ExpenseCategory category,
    String? notes,
    String? receiptUrl,
  });

  Future<Result<ExpenseEntity, AppError>> updateExpense({
    required String groupId,
    required String expenseId,
    String? description,
    double? amount,
    String? paidBy,
    List<SplitEntity>? splits,
    ExpenseCategory? category,
    String? notes,
    String? receiptUrl,
  });

  Future<Result<void, AppError>> deleteExpense({
    required String groupId,
    required String expenseId,
  });

  /// Upload a receipt image and return its Storage URL.
  Future<Result<String, AppError>> uploadReceipt({
    required String groupId,
    required String expenseId,
    required String localFilePath,
  });
}
