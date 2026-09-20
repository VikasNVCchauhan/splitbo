// packages/domain/lib/src/usecases/balances/settle_up_usecase.dart

import 'package:core/core.dart';
import 'package:meta/meta.dart';

import '../../repositories/balance_repository.dart';
import '../usecase.dart';

@immutable
class SettleUpParams {
  const SettleUpParams({
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.currency = 'INR',
    this.note,
  });

  final String groupId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currency;
  final String? note;
}

class SettleUpUseCase implements UseCase<void, SettleUpParams> {
  const SettleUpUseCase(this._repo);
  final BalanceRepository _repo;

  @override
  Future<Result<void, AppError>> call(SettleUpParams params) {
    if (params.amount <= 0) {
      return Future.value(
        const Err(ValidationError('Settlement amount must be greater than zero.')),
      );
    }
    if (params.fromUserId == params.toUserId) {
      return Future.value(
        const Err(ValidationError('Cannot settle up with yourself.')),
      );
    }
    return _repo.settleUp(
      groupId: params.groupId,
      fromUserId: params.fromUserId,
      toUserId: params.toUserId,
      amount: params.amount,
      currency: params.currency,
      note: params.note,
    );
  }
}
