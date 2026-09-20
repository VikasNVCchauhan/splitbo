// packages/domain/lib/src/usecases/groups/create_group_usecase.dart

import 'package:core/core.dart';
import 'package:meta/meta.dart';

import '../../entities/group_entity.dart';
import '../../repositories/group_repository.dart';
import '../usecase.dart';

@immutable
class CreateGroupParams {
  const CreateGroupParams({
    required this.name,
    required this.memberIds,
    this.description = '',
    this.currency = 'INR',
  });

  final String name;
  final String description;
  final List<String> memberIds;
  final String currency;
}

class CreateGroupUseCase implements UseCase<GroupEntity, CreateGroupParams> {
  const CreateGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<GroupEntity, AppError>> call(CreateGroupParams params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        const Err(ValidationError('Group name cannot be empty.', field: 'name')),
      );
    }
    if (params.memberIds.isEmpty) {
      return Future.value(
        const Err(ValidationError('A group needs at least one member.', field: 'memberIds')),
      );
    }
    return _repo.createGroup(
      name: params.name.trim(),
      description: params.description.trim(),
      currency: params.currency,
      memberIds: params.memberIds,
    );
  }
}
