// packages/data/lib/src/repositories/balance_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../dto/balance_dto.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  BalanceRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _balances(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('balances');

  CollectionReference<Map<String, dynamic>> _settlements(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('settlements');

  @override
  Stream<List<BalanceEntity>> watchBalances(String userId) {
    // Firestore doesn't support collection-group queries on nested fields
    // without an index. The CF writes a per-user summary doc at:
    //   userBalances/{userId}  →  { groupBalances: [...] }
    // For MVP we watch each group's balance doc for the user.
    // This is replaced by a collectionGroup query once the index exists.
    return _firestore
        .collectionGroup('balances')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BalanceDto.fromFirestore(d).toEntity())
            .toList());
  }

  @override
  Stream<BalanceEntity?> watchGroupBalance({
    required String groupId,
    required String userId,
  }) =>
      _balances(groupId)
          .doc(userId)
          .snapshots()
          .map((doc) => doc.exists ? BalanceDto.fromFirestore(doc).toEntity() : null);

  @override
  Future<Result<void, AppError>> settleUp({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    String? note,
  }) async {
    try {
      await _settlements(groupId).add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'amount': amount,
        'currency': currency,
        if (note != null) 'note': note,
        'createdAt': FieldValue.serverTimestamp(),
        // Cloud Function `onSettlementCreated` watches this collection
        // and recalculates balances automatically.
        'status': 'pending',
      });
      return const Ok(null);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  AppError _mapError(FirebaseException e) => switch (e.code) {
        'permission-denied' => PermissionError("You don't have permission.", e.code),
        'not-found'         => NotFoundError('Not found.', e.code),
        'unavailable'       => const NetworkError(),
        _                   => ServerError(e.message ?? 'Database error.', e.code),
      };
}
