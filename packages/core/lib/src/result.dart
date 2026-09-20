// packages/core/lib/src/result.dart
//
// Railway-oriented Result type. Prefer this over throwing exceptions across
// package boundaries — exceptions are invisible in function signatures.

/// Discriminated union: either a success value [S] or a failure value [F].
sealed class Result<S, F> {
  const Result();

  bool get isOk  => this is Ok<S, F>;
  bool get isErr => this is Err<S, F>;

  S get value => (this as Ok<S, F>).value;
  F get error => (this as Err<S, F>).error;

  S? get valueOrNull => isOk ? value : null;
  F? get errorOrNull => isErr ? error : null;

  T fold<T>({
    required T Function(S value) ok,
    required T Function(F error) err,
  }) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final error) => err(error),
      };

  Result<T, F> map<T>(T Function(S value) transform) => switch (this) {
        Ok(:final value) => Ok(transform(value)),
        Err(:final error) => Err(error),
      };

  Result<S, G> mapError<G>(G Function(F error) transform) => switch (this) {
        Ok(:final value) => Ok(value),
        Err(:final error) => Err(transform(error)),
      };

  Future<Result<T, F>> asyncMap<T>(
    Future<T> Function(S value) transform,
  ) async =>
      switch (this) {
        Ok(:final value) => Ok(await transform(value)),
        Err(:final error) => Err(error),
      };

  /// Chains a fallible operation — flat-maps over the success branch.
  Future<Result<T, F>> andThen<T>(
    Future<Result<T, F>> Function(S value) next,
  ) =>
      switch (this) {
        Ok(:final value) => next(value),
        Err(:final error) => Future.value(Err(error)),
      };

  @override
  String toString() => switch (this) {
        Ok(:final value) => 'Ok($value)',
        Err(:final error) => 'Err($error)',
      };
}

final class Ok<S, F> extends Result<S, F> {
  const Ok(this.value);
  @override
  final S value;

  @override
  bool operator ==(Object other) =>
      other is Ok<S, F> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Err<S, F> extends Result<S, F> {
  const Err(this.error);
  @override
  final F error;

  @override
  bool operator ==(Object other) =>
      other is Err<S, F> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

/// Convenience: wrap a throwing call and catch it as [AppError]-like F.
/// Usage: final result = await guardAsync(() => myRepo.fetch());
Future<Result<S, F>> guardAsync<S, F>(
  Future<S> Function() block,
  F Function(Object error, StackTrace st) onError,
) async {
  try {
    return Ok(await block());
  } catch (e, st) {
    return Err(onError(e, st));
  }
}
