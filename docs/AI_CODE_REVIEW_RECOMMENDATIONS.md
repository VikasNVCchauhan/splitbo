# Splitbo Code Review Recommendations

This document summarizes the current repository findings and gives another AI coding assistant a focused implementation brief.

## Repository Context

- Project: Splitbo
- Framework: Flutter Web and mobile-ready Flutter structure
- State management: Riverpod
- Navigation: go_router
- Backend: Firebase Authentication, Firestore, Storage, and Messaging
- Architecture: Melos monorepo with `domain`, `data`, `core`, `design_system`, and feature packages
- Default branch: `main`

## Important Constraints

- Do not rewrite unrelated files.
- Preserve the existing Clean Architecture boundaries.
- Keep public APIs stable unless a change is required to fix a defect.
- Add focused tests for every behavior changed.
- Do not commit credentials, private keys, service-account JSON, or new client-side API secrets.
- Verify the result with formatting, static analysis, and tests where the Flutter SDK is available.

## Recommended Implementation Order

### 1. Fix the stale widget test

File: `app/test/widget_test.dart`

The test still references `MyApp`, a counter, and `Icons.add`, but the application now uses `SplitboApp` and has no counter screen. Replace the generated counter test with a test that reflects the current app or with focused tests for the app bootstrap and routing.

Acceptance criteria:

- No reference to `MyApp` remains in the test suite unless it is intentionally reintroduced.
- Tests build the current application or test an isolated current widget.
- `flutter test` passes for the app package.

### 2. Register the missing balances route

Files:

- `app/lib/src/routing/app_router.dart`
- `packages/features/balances/lib/src/home_screen.dart`

The home screen navigates to `/balances`, and `BalanceScreen` exists, but the route is not registered in the router.

Acceptance criteria:

- `/balances` resolves to `BalanceScreen`.
- The Settle Up action no longer produces a routing error.
- Add a routing or widget test for this path if practical.

### 3. Replace the expense detail placeholder

File: `app/lib/src/routing/app_router.dart`

The expense detail route currently renders `_PlaceholderScreen`. Either implement the real expense detail screen and load the correct expense data, or remove the route until it is supported so users are not sent to a misleading placeholder.

Acceptance criteria:

- No production navigation path presents a fake expense detail screen.
- Missing or inaccessible expenses show a useful error state.

### 4. Remove the Gemini key from Flutter Web client code

File: `packages/features/expenses/lib/src/add_expense_screen.dart`

The Gemini API key is embedded in client-side code. Anyone can extract it from the deployed web application. Move receipt parsing behind a secured backend endpoint or Firebase Cloud Function. Store the secret in server-side configuration or a secret manager, rotate the exposed key, and keep only a non-secret endpoint configuration in the client.

Acceptance criteria:

- No Gemini API key is committed in Dart, HTML, JavaScript, or generated web assets.
- Receipt scanning still returns the expected structured fields.
- Authentication, rate limiting, input-size limits, and error handling are enforced by the backend.
- The previously exposed key is rotated outside the repository.

### 5. Fix personal expense storage

Files:

- `packages/features/expenses/lib/src/add_expense_screen.dart`
- `packages/data/lib/src/repositories/expense_repository_impl.dart`

When no group is selected, the UI creates a synthetic group ID such as `personal_<userId>`, while the repository writes under a group expense collection and updates a parent group document that may not exist. Use a dedicated personal-expenses collection or explicitly create and manage the personal container.

Acceptance criteria:

- A user can create a personal expense without selecting a group.
- Personal expenses do not require a fake group document.
- Group expense behavior remains unchanged.
- Firestore rules cover personal expenses separately and securely.

### 6. Align Firestore rules with collection prefixes

Files:

- `packages/data/lib/src/providers/firebase_providers.dart`
- `firebase/firestore.rules`

The data layer uses the `dev_` prefix in debug mode, but the rules currently match unprefixed collection paths. Confirm the deployed data model and make rules explicitly cover the intended development and production collections without weakening authorization.

Acceptance criteria:

- Debug reads and writes use paths covered by Firestore rules.
- Production paths remain protected.
- Group access is based on membership in the relevant group document.
- Rules tests or emulator checks cover unauthorized reads and writes.

### 7. Make balance ownership consistent

Files:

- `firebase/firestore.rules`
- `docs/architecture/ARCHITECTURE.md`

The rules currently allow users to write their own balance documents, while the architecture documentation says balances are maintained by Cloud Functions and client writes should be blocked. Choose one authoritative model. The recommended production model is server-managed balances with client read access limited to the authenticated owner.

Acceptance criteria:

- Client users cannot forge balance values.
- Server-side balance updates remain functional.
- Documentation and rules describe the same model.

### 8. Reconcile receipt format documentation

The README mentions DOCX receipt support, while the file picker currently permits PDF and image formats only. Either implement DOCX parsing or update the documentation to list only supported formats.

Acceptance criteria:

- Documentation matches the actual accepted file types.
- Unsupported formats receive a clear user-facing error.

## Suggested Verification Commands

Run from the repository root after the Flutter SDK is installed:

```bash
flutter pub get
dart format . --set-exit-if-changed
melos run a
melos run t
```

For Firestore authorization changes, use the Firebase emulator or the repository's configured rules test workflow. Do not rely only on compilation to validate security rules.

## Definition of Done

- The selected findings are implemented with focused changes.
- Tests cover changed behavior and pass.
- Static analysis and formatting pass.
- No secrets are added to the repository.
- README and architecture documentation match the final behavior.
- `git diff` contains only the intended implementation, tests, and documentation updates.