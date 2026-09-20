// packages/domain/lib/src/repositories/auth_repository.dart
//
// Interface only — no Firebase imports. Implemented in packages/data.

import 'package:core/core.dart';

import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  /// Stream of the currently signed-in user. Emits null when signed out.
  Stream<UserEntity?> watchAuthState();

  /// Returns the current user synchronously (null if signed out).
  UserEntity? get currentUser;

  Future<Result<UserEntity, AppError>> signInWithGoogle();

  Future<Result<UserEntity, AppError>> signInWithApple();

  /// OTP-based phone sign-in — Phase 1 MVP for India.
  Future<Result<void, AppError>> sendPhoneOtp(String phoneNumber);
  Future<Result<UserEntity, AppError>> verifyPhoneOtp(
    String verificationId,
    String smsCode,
  );

  Future<Result<UserEntity, AppError>> updateProfile({
    String? displayName,
    String? avatarUrl,
  });

  Future<Result<void, AppError>> signOut();

  Future<Result<void, AppError>> deleteAccount();
}
