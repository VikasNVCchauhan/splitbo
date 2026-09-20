// packages/domain/lib/src/repositories/group_repository.dart

import 'package:core/core.dart';

import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  /// Real-time stream of all groups the current user belongs to.
  Stream<List<GroupEntity>> watchGroups(String userId);

  /// Single group by ID — useful for deep-link entry points.
  Future<Result<GroupEntity, AppError>> getGroup(String groupId);

  Future<Result<GroupEntity, AppError>> createGroup({
    required String name,
    required String description,
    required String currency,
    required List<String> memberIds,
  });

  Future<Result<GroupEntity, AppError>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
  });

  Future<Result<void, AppError>> addMembers({
    required String groupId,
    required List<String> userIds,
  });

  Future<Result<void, AppError>> removeMember({
    required String groupId,
    required String userId,
  });

  /// Hard delete — only group creator can call this.
  /// Cloud Function cascades to expenses and balance docs.
  Future<Result<void, AppError>> deleteGroup(String groupId);

  /// Search users by phone/email to invite to a group.
  Future<Result<List<({String id, String displayName, String? avatarUrl})>, AppError>>
      searchUsers(String query);
}
