import '../providers/firebase_providers.dart';
// packages/data/lib/src/repositories/expense_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../dto/expense_dto.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required FirebaseFirestore firestore,
    required String currentUserId,
  })  : _firestore = firestore,
        _currentUserId = currentUserId;

  final FirebaseFirestore _firestore;
  final String _currentUserId;

  CollectionReference<Map<String, dynamic>> _expenses(String groupId) =>
      _firestore.collection('${dbPrefix}groups').doc(groupId).collection('expenses');

  @override
  Stream<List<ExpenseEntity>> watchExpenses(String groupId) => _expenses(groupId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ExpenseDto.fromFirestore(d).toEntity())
          .toList());

  @override
  Future<Result<ExpenseEntity, AppError>> getExpense(String expenseId) async {
    // expenseId format: "{groupId}_{docId}" — stored in the expense itself.
    // For simplicity, query across all groups is not supported on client.
    return const Err(UnknownError(
      'getExpense requires groupId. Use watchExpenses instead.',
    ));
  }

  @override
  Future<Result<ExpenseEntity, AppError>> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String currency,
    required String paidBy,
    required List<SplitEntity> splits,
    required ExpenseCategory category,
    String? notes,
    String? receiptUrl,
  }) async {
    try {
      final docRef = _expenses(groupId).doc();
      final now = DateTime.now();
      final dto = ExpenseDto(
        id: docRef.id,
        groupId: groupId,
        description: description,
        amount: amount,
        currency: currency,
        paidBy: paidBy,
        splits: splits
            .map((s) => {'userId': s.userId, 'amount': s.amount})
            .toList(),
        category: category.name,
        receiptUrl: receiptUrl,
        notes: notes,
        createdBy: _currentUserId,
        createdAt: now,
        updatedAt: now,
      );
      await docRef.set(dto.toFirestore());
      await _firestore
          .collection('${dbPrefix}groups')
          .doc(groupId)
          .update({'totalExpenses': FieldValue.increment(amount)});
      return Ok(dto.toEntity());
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<ExpenseEntity, AppError>> updateExpense({
    required String groupId,
    required String expenseId,
    String? description,
    double? amount,
    String? paidBy,
    List<SplitEntity>? splits,
    ExpenseCategory? category,
    String? notes,
    String? receiptUrl,
  }) async {
    try {
      final docRef = _expenses(groupId).doc(expenseId);
      if (amount != null) {
        final snap = await docRef.get();
        final oldAmount = (snap.data()?['amount'] as num?)?.toDouble() ?? 0.0;
        await _firestore
            .collection('${dbPrefix}groups')
            .doc(groupId)
            .update({'totalExpenses': FieldValue.increment(amount - oldAmount)});
      }
      final updates = <String, dynamic>{
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        if (paidBy != null) 'paidBy': paidBy,
        if (splits != null)
          'splits': splits
              .map((s) => {'userId': s.userId, 'amount': s.amount})
              .toList(),
        if (category != null) 'category': category.name,
        if (notes != null) 'notes': notes,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await docRef.update(updates);
      final updated = await docRef.get();
      return Ok(ExpenseDto.fromFirestore(updated).toEntity());
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      final docRef = _expenses(groupId).doc(expenseId);
      final snap = await docRef.get();
      final amount = (snap.data()?['amount'] as num?)?.toDouble() ?? 0.0;
      await docRef.delete();
      await _firestore
          .collection('${dbPrefix}groups')
          .doc(groupId)
          .update({'totalExpenses': FieldValue.increment(-amount)});
      return const Ok(null);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<String, AppError>> uploadReceipt({
    required String groupId,
    required String expenseId,
    required String localFilePath,
  }) async {
    // TODO(mobile): wire dart:io File upload once mobile targets are added.
    return const Err(UnknownError('Receipt upload requires mobile platform.'));
  }

  AppError _mapError(FirebaseException e) => switch (e.code) {
        'permission-denied' => PermissionError("You don't have permission.", e.code),
        'not-found'         => NotFoundError('Not found.', e.code),
        'unavailable'       => const NetworkError(),
        _                   => ServerError(e.message ?? 'Database error.', e.code),
      };
}
