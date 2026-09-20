// packages/domain/lib/src/usecases/auth/watch_auth_state_usecase.dart

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class WatchAuthStateUseCase implements StreamUseCase<UserEntity?, NoParams> {
  const WatchAuthStateUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Stream<UserEntity?> call(NoParams params) => _repo.watchAuthState();
}
