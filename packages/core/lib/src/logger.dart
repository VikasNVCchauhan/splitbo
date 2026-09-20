// packages/core/lib/src/logger.dart
//
// Structured logger interface.
// The data package wires in a Crashlytics-backed implementation at runtime.
// In tests, inject a NoOpLogger or a recording spy.

import 'package:meta/meta.dart';

enum LogLevel { debug, info, warning, error }

abstract interface class AppLogger {
  void debug(String message, {String? tag, Object? extra});
  void info(String message, {String? tag, Object? extra});
  void warning(String message, {String? tag, Object? extra});
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Default implementation: prints to console in debug builds only.
/// Replace via ProviderScope override in production (see data package).
@visibleForTesting
final class PrintLogger implements AppLogger {
  const PrintLogger({this.minLevel = LogLevel.debug});
  final LogLevel minLevel;

  @override
  void debug(String message, {String? tag, Object? extra}) =>
      _log(LogLevel.debug, message, tag: tag, extra: extra);

  @override
  void info(String message, {String? tag, Object? extra}) =>
      _log(LogLevel.info, message, tag: tag, extra: extra);

  @override
  void warning(String message, {String? tag, Object? extra}) =>
      _log(LogLevel.warning, message, tag: tag, extra: extra);

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, extra: error);
    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }

  void _log(LogLevel level, String message, {String? tag, Object? extra}) {
    if (level.index < minLevel.index) return;
    final prefix = switch (level) {
      LogLevel.debug   => '🔍 DEBUG',
      LogLevel.info    => 'ℹ️  INFO ',
      LogLevel.warning => '⚠️  WARN ',
      LogLevel.error   => '🔴 ERROR',
    };
    final tagPart = tag != null ? ' [$tag]' : '';
    final extraPart = extra != null ? ' | $extra' : '';
    // ignore: avoid_print
    print('$prefix$tagPart $message$extraPart');
  }
}

/// No-op logger for tests that don't care about log output.
final class NoOpLogger implements AppLogger {
  const NoOpLogger();

  @override
  void debug(String message, {String? tag, Object? extra}) {}
  @override
  void info(String message, {String? tag, Object? extra}) {}
  @override
  void warning(String message, {String? tag, Object? extra}) {}
  @override
  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {}
}
