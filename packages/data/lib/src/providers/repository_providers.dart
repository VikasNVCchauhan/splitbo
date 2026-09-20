// packages/data/lib/src/providers/repository_providers.dart
// Manual Riverpod providers — no code-gen, no build_runner needed.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository_impl.dart';
import '../repositories/balance_repository_impl.dart';
import '../repositories/expense_repository_impl.dart';
import '../repositories/group_repository_impl.dart';
import 'firebase_providers.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(
      auth: ref.watch(firebaseAuthProvider),
      firestore: ref.watch(firebaseFirestoreProvider),
      googleSignIn: ref.watch(googleSignInProvider),
    ));

final authStateProvider = StreamProvider<UserEntity?>((ref) =>
    ref.watch(authRepositoryProvider).watchAuthState());

// ── Groups ────────────────────────────────────────────────────────────────────

final groupRepositoryProvider = Provider<GroupRepository>((ref) =>
    GroupRepositoryImpl(firestore: ref.watch(firebaseFirestoreProvider)));

final watchGroupsProvider = StreamProvider<List<GroupEntity>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchGroups(user.id);
});

// ── Expenses ──────────────────────────────────────────────────────────────────

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return ExpenseRepositoryImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    currentUserId: user?.id ?? '',
  );
});

// Family provider — watch expenses for a specific group
final watchExpensesProvider =
    StreamProvider.family<List<ExpenseEntity>, String>((ref, groupId) =>
        ref.watch(expenseRepositoryProvider).watchExpenses(groupId));

// ── FCM token ─────────────────────────────────────────────────────────────────

// Watch auth state and save FCM token to user doc whenever user signs in.
// Consumed in _AppShell so it auto-runs while the shell is mounted.
final saveFcmTokenProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return;

  final messaging = FirebaseMessaging.instance;
  try {
    final token = await messaging.getToken();
    if (token == null) return;
    await ref
        .read(firebaseFirestoreProvider)
        .collection('${dbPrefix}users')
        .doc(user.id)
        .update({'fcmTokens': FieldValue.arrayUnion([token])});
  } catch (_) {
    // Non-fatal — app works without push tokens
  }
});

final balanceRepositoryProvider = Provider<BalanceRepository>((ref) =>
    BalanceRepositoryImpl(firestore: ref.watch(firebaseFirestoreProvider)));

final watchBalancesProvider = StreamProvider<List<BalanceEntity>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(balanceRepositoryProvider).watchBalances(user.id);
});

final watchGroupBalanceProvider = StreamProvider.family<BalanceEntity?,
    ({String groupId, String userId})>((ref, args) =>
    ref.watch(balanceRepositoryProvider).watchGroupBalance(
          groupId: args.groupId,
          userId: args.userId,
        ));
