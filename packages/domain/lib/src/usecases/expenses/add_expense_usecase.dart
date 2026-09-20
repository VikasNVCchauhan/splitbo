// packages/domain/lib/src/usecases/expenses/add_expense_usecase.dart

import 'package:core/core.dart';
import 'package:meta/meta.dart';

import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';
import '../usecase.dart';

@immutable
class AddExpenseParams {
  const AddExpenseParams({
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splits,
    this.currency = 'INR',
    this.category = ExpenseCategory.other,
    this.notes,
    this.receiptUrl,
  });

  final String groupId;
  final String description;
  final double amount;
  final String currency;
  final String paidBy;
  final List<SplitEntity> splits;
  final ExpenseCategory category;
  final String? notes;
  final String? receiptUrl;
}

class AddExpenseUseCase implements UseCase<ExpenseEntity, AddExpenseParams> {
  const AddExpenseUseCase(this._repo);
  final ExpenseRepository _repo;

  @override
  Future<Result<ExpenseEntity, AppError>> call(AddExpenseParams params) {
    if (params.description.trim().isEmpty) {
      return Future.value(
        const Err(ValidationError('Description cannot be empty.', field: 'description')),
      );
    }
    if (params.amount <= 0) {
      return Future.value(
        const Err(ValidationError('Amount must be greater than zero.', field: 'amount')),
      );
    }

    // Split amounts must sum to total (within a 1-paisa tolerance).
    final splitTotal = params.splits.fold(0.0, (sum, s) => sum + s.amount);
    if ((splitTotal - params.amount).abs() > 0.01) {
      return Future.value(
        const Err(ValidationError(
          'Split amounts must add up to the total expense amount.',
          field: 'splits',
        )),
      );
    }

    return _repo.addExpense(
      groupId: params.groupId,
      description: params.description.trim(),
      amount: params.amount,
      currency: params.currency,
      paidBy: params.paidBy,
      splits: params.splits,
      category: params.category,
      notes: params.notes,
      receiptUrl: params.receiptUrl,
    );
  }
}
