/// Domain package — pure-Dart entities, repository interfaces, and use-cases.
///
/// Zero Flutter dependencies. Zero Firebase dependencies.
library domain;

// Entities
export 'src/entities/user_entity.dart';
export 'src/entities/group_entity.dart';
export 'src/entities/expense_entity.dart';
export 'src/entities/balance_entity.dart';

// Repository interfaces
export 'src/repositories/auth_repository.dart';
export 'src/repositories/group_repository.dart';
export 'src/repositories/expense_repository.dart';
export 'src/repositories/balance_repository.dart';

// Use-case base
export 'src/usecases/usecase.dart';

// Auth use-cases
export 'src/usecases/auth/watch_auth_state_usecase.dart';
export 'src/usecases/auth/sign_out_usecase.dart';

// Groups use-cases
export 'src/usecases/groups/watch_groups_usecase.dart';
export 'src/usecases/groups/create_group_usecase.dart';

// Expenses use-cases
export 'src/usecases/expenses/add_expense_usecase.dart';

// Balances use-cases
export 'src/usecases/balances/watch_balances_usecase.dart';
export 'src/usecases/balances/settle_up_usecase.dart';
