// packages/domain/lib/src/usecases/balances/watch_balances_usecase.dart

import '../../entities/balance_entity.dart';
import '../../repositories/balance_repository.dart';
import '../usecase.dart';

class WatchBalancesUseCase implements StreamUseCase<List<BalanceEntity>, String> {
  const WatchBalancesUseCase(this._repo);
  final BalanceRepository _repo;

  /// [params] is the current user's ID.
  @override
  Stream<List<BalanceEntity>> call(String params) =>
      _repo.watchBalances(params);
}
