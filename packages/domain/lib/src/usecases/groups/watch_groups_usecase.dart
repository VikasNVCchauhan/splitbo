// packages/domain/lib/src/usecases/groups/watch_groups_usecase.dart

import '../../entities/group_entity.dart';
import '../../repositories/group_repository.dart';
import '../usecase.dart';

class WatchGroupsUseCase implements StreamUseCase<List<GroupEntity>, String> {
  const WatchGroupsUseCase(this._repo);
  final GroupRepository _repo;

  /// [params] is the current user's ID.
  @override
  Stream<List<GroupEntity>> call(String params) => _repo.watchGroups(params);
}
