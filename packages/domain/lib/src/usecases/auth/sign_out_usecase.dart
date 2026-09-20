// packages/domain/lib/src/usecases/auth/sign_out_usecase.dart

import 'package:core/core.dart';

import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repo);
  final AuthRepository _repo;

  @override
  Future<Result<void, AppError>> call(NoParams params) => _repo.signOut();
}
