/// Data package — Firebase-backed repository implementations and Riverpod providers.
///
/// The ONLY package allowed to import firebase_* packages.
/// app/ (composition root) imports this to wire repositories into the DI graph.
library data;

// DTOs (internal — exported only so app can reference concrete types if needed)
export 'src/dto/user_dto.dart';
export 'src/dto/group_dto.dart';
export 'src/dto/expense_dto.dart';
export 'src/dto/balance_dto.dart';

// Repository implementations
export 'src/repositories/auth_repository_impl.dart';
export 'src/repositories/group_repository_impl.dart';
export 'src/repositories/expense_repository_impl.dart';
export 'src/repositories/balance_repository_impl.dart';

// Riverpod providers — the primary API surface for app/
export 'src/providers/firebase_providers.dart';
export 'src/providers/repository_providers.dart';
