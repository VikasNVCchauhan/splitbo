// packages/data/lib/src/repositories/auth_repository_impl.dart

import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../dto/user_dto.dart';
import '../providers/firebase_providers.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('${dbPrefix}users');

  @override
  Stream<UserEntity?> watchAuthState() =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return _fetchOrCreateUser(user);
      });

  @override
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      displayName: user.displayName ?? user.email ?? 'User',
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<Result<UserEntity, AppError>> signInWithGoogle() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // On web, use Firebase popup — avoids page redirect losing state
        final provider = GoogleAuthProvider();
        result = await _auth.signInWithPopup(provider);
      } else {
        final account = await _googleSignIn.signIn();
        if (account == null) {
          return const Err(AuthError('Google sign-in was cancelled.'));
        }
        final auth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        result = await _auth.signInWithCredential(credential);
      }

      final entity = await _fetchOrCreateUser(result.user!);
      return Ok(entity);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<UserEntity, AppError>> signInWithApple() async {
    try {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final result = await _auth.signInWithProvider(provider);
      final entity = await _fetchOrCreateUser(result.user!);
      return Ok(entity);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> sendEmailSignInLink(String email) async {
    try {
      final settings = ActionCodeSettings(
        // Update this URL to your Firebase Hosting domain once configured.
        url: 'https://splitbo-7cbe0f307bfe.firebaseapp.com/auth/link',
        handleCodeInApp: true,
        iOSBundleId: 'com.splitbo.app',
        androidPackageName: 'com.splitbo.app',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );
      await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: settings);
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString()));
    }
  }

  @override
  Future<Result<void, AppError>> sendPhoneOtp(String phoneNumber) {
    final completer = Completer<Result<void, AppError>>();
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Android auto-retrieval — sign in immediately.
        await _auth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete(const Ok(null));
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.complete(Err(_mapAuthError(e)));
      },
      codeSent: (verificationId, _) {
        _pendingVerificationId = verificationId;
        if (!completer.isCompleted) completer.complete(const Ok(null));
      },
      codeAutoRetrievalTimeout: (_) {
        if (!completer.isCompleted) {
          completer.complete(const Err(AuthError('OTP retrieval timed out.')));
        }
      },
    );
    return completer.future;
  }

  String? _pendingVerificationId;

  @override
  Future<Result<UserEntity, AppError>> verifyPhoneOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final id = verificationId.isNotEmpty
          ? verificationId
          : _pendingVerificationId ?? '';
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final entity = await _fetchOrCreateUser(result.user!);
      return Ok(entity);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<UserEntity, AppError>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Err(AuthError());
      if (displayName != null) await user.updateDisplayName(displayName);
      if (avatarUrl != null) await user.updatePhotoURL(avatarUrl);
      await _users.doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
      final entity = await _fetchOrCreateUser(user);
      return Ok(entity);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      return const Ok(null);
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Err(AuthError());
      await _users.doc(user.uid).delete();
      await user.delete();
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<UserEntity> _fetchOrCreateUser(User firebaseUser) async {
    // Build entity from Firebase Auth — works even if Firestore is unavailable
    final fallback = UserEntity(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User',
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      avatarUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
    try {
      final doc = await _users.doc(firebaseUser.uid).get();
      if (doc.exists) return UserDto.fromFirestore(doc).toEntity();
      await _users.doc(firebaseUser.uid).set(UserDto.fromEntity(fallback).toFirestore());
      return fallback;
    } catch (_) {
      // Firestore unavailable / rules blocking — return auth-only entity
      return fallback;
    }
  }

  AppError _mapAuthError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          AuthError('Invalid credentials. Please try again.', e.code),
        'too-many-requests' =>
          const NetworkError('Too many attempts. Please wait a moment.'),
        'network-request-failed' => const NetworkError(),
        'invalid-verification-code' =>
          const AuthError('Incorrect OTP. Please check and try again.'),
        'session-expired' =>
          const AuthError('OTP expired. Please request a new code.'),
        _ => ServerError(e.message ?? 'Authentication failed.', e.code, e),
      };
}
