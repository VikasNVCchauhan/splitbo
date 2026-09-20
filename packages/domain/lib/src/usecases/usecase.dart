// packages/domain/lib/src/usecases/usecase.dart
//
// Base contracts for use-cases. Two flavours:
//   • UseCase<T, P>       — one-shot async, returns Result
//   • StreamUseCase<T, P> — real-time stream (Firestore onSnapshot)

import 'package:core/core.dart';

/// Async use-case — call once, get a Result back.
abstract interface class UseCase<Type, Params> {
  Future<Result<Type, AppError>> call(Params params);
}

/// Stream use-case — subscribes to a real-time data source.
abstract interface class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

/// Convenience for use-cases that take no parameters.
final class NoParams {
  const NoParams();
}
