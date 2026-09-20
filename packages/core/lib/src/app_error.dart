// packages/core/lib/src/app_error.dart

import 'package:meta/meta.dart';

@immutable
sealed class AppError {
  const AppError(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => '${runtimeType}(message: $message, code: $code)';
}

final class NetworkError extends AppError {
  const NetworkError([
    String message = 'No internet connection. Check your network and try again.',
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}

final class AuthError extends AppError {
  const AuthError([
    String message = 'Authentication required. Please sign in.',
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}

final class PermissionError extends AppError {
  const PermissionError([
    String message = "You don't have permission to do that.",
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}

final class NotFoundError extends AppError {
  const NotFoundError([
    String message = 'The requested item could not be found.',
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}

final class ValidationError extends AppError {
  const ValidationError(
    String message, {
    this.field,
    String? code,
    Object? cause,
  }) : super(message, code: code, cause: cause);

  final String? field;
}

final class ServerError extends AppError {
  const ServerError([
    String message = 'Something went wrong on our end. Please try again.',
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}

final class UnknownError extends AppError {
  const UnknownError([
    String message = 'An unexpected error occurred.',
    String? code,
    Object? cause,
  ]) : super(message, code: code, cause: cause);
}
