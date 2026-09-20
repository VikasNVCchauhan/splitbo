// packages/domain/lib/src/repositories/balance_repository.dart
//
// READ-ONLY. Balances are computed by Cloud Functions.
// Clients never write to balance documents.

import 'package:core/core.dart';

import '../entities/balance_entity.dart';

abstract interface class BalanceRepository {
  /// Real-time stream of all group-level balances for a user.
  Stream<List<BalanceEntity>> watchBalances(String userId);

  /// Balance for a specific user within a specific group.
  Stream<BalanceEntity?> watchGroupBalance({
    required String groupId,
    required String userId,
  });

  /// Trigger a settle-up transaction.
  /// The Cloud Function records the payment and recalculates balances.
  Future<Result<void, AppError>> settleUp({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    String? note,
  });
}
