import '../providers/firebase_providers.dart';
// packages/data/lib/src/repositories/group_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../dto/group_dto.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('${dbPrefix}groups');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('${dbPrefix}users');

  @override
  Stream<List<GroupEntity>> watchGroups(String userId) => _groups
      .where('memberIds', arrayContains: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GroupDto.fromFirestore(d).toEntity())
          .toList());

  @override
  Future<Result<GroupEntity, AppError>> getGroup(String groupId) async {
    try {
      final doc = await _groups.doc(groupId).get();
      if (!doc.exists) return const Err(NotFoundError('Group not found.'));
      return Ok(GroupDto.fromFirestore(doc).toEntity());
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<GroupEntity, AppError>> createGroup({
    required String name,
    required String description,
    required String currency,
    required List<String> memberIds,
  }) async {
    try {
      final docRef = _groups.doc();
      final now = DateTime.now();
      final dto = GroupDto(
        id: docRef.id,
        name: name,
        description: description,
        memberIds: memberIds,
        createdBy: memberIds.first,
        createdAt: now,
        currency: currency,
      );
      await docRef.set(dto.toFirestore());
      // Write nameLower for prefix search queries
      await docRef.update({'nameLower': name.toLowerCase()});
      return Ok(dto.toEntity());
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<GroupEntity, AppError>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (name != null) 'name': name,
        if (name != null) 'nameLower': name.toLowerCase(),
        if (description != null) 'description': description,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
      await _groups.doc(groupId).update(updates);
      return getGroup(groupId);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> addMembers({
    required String groupId,
    required List<String> userIds,
  }) async {
    try {
      await _groups.doc(groupId).update({
        'memberIds': FieldValue.arrayUnion(userIds),
      });
      return const Ok(null);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _groups.doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
      return const Ok(null);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<Result<void, AppError>> deleteGroup(String groupId) async {
    try {
      // Cloud Function cascades expenses + balances.
      await _groups.doc(groupId).delete();
      return const Ok(null);
    } on FirebaseException catch (e) {
      return Err(_mapError(e));
    } catch (e) {
      return Err(UnknownError(e.toString(), null, e));
    }
  }

  @override
  Future<
      Result<
          List<({String id, String displayName, String? avatarUrl})>,
          AppError>> searchUsers(String query) async {
    try {
      final q = query.trim().toLowerCase();
      // Search by displayName prefix (Firestore doesn't support full-text).
      final snap = await _users
          .where('displayName', isGreaterThanOrEqualTo: q)
          .where('displayName', isLessThan: '${q}z')
          .limit(20)
          .get();
      final results = snap.docs
          .map((d) => (
                id: d.id,
                displayName: d['displayName'] as String? ?? '',
                avatarUrl: d['avatarUrl'] as String?,
              ))
          .toList();
      return Ok(results);
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
