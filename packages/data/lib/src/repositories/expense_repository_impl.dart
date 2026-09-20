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
      return Ok(dto.toEntity());
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<ExpenseEntity, AppError>> updateExpense({
    required String expenseId,
    String? description,
    double? amount,
    String? paidBy,
    List<SplitEntity>? splits,
    ExpenseCategory? category,
    String? notes,
    String? receiptUrl,
  }) async {
    // Requires groupId — not available here. Feature packages call repo
    // methods via the use-case which should pass groupId as context.
    return const Err(UnknownError(
      'updateExpense not yet implemented in client. Use Cloud Function.',
    ));
  }

  @override
  Future<Result<void, AppError>> deleteExpense(String expenseId) async {
    return const Err(UnknownError(
      'deleteExpense requires groupId. Pass via use-case context.',
    ));
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
