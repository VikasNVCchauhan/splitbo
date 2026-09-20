# Splitbo

> **Split bills. Keep friends.**

**Live App: [https://vikasnvcchauhan.github.io/splitbo/](https://vikasnvcchauhan.github.io/splitbo/)**

Splitbo is a modern expense-splitting app built with Flutter Web + Firebase. Track shared expenses across groups, settle balances, and scan receipts with AI — all with a clean dark-first UI.

---

## Features

- **Groups & Expenses** — Create groups, add expenses, and track who owes what in real time
- **AI Receipt Scanning** — Photograph or upload a bill (image/PDF/DOCX) and Gemini 1.5 Flash auto-fills amount, merchant, and category by understanding full receipt context
- **Google Sign-In** — Firebase Authentication with Google OAuth
- **Real-time Balances** — Firestore-backed live balance calculations across all group members
- **Settle Up** — Clear balances with one tap
- **Dark-first Design** — Brand green `#C3FD00` on black, matching the Splitbo marketing assets

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter (Web, with mobile-ready structure) |
| State | Riverpod (manual, no code-gen) |
| Navigation | go_router |
| Backend | Firebase (Auth, Firestore, Storage) |
| OCR / AI | Gemini 1.5 Flash (multimodal) |
| Monorepo | Melos |
| Architecture | Clean Architecture (domain / data / features) |

---

## Project Structure

```
splitbo/
├── app/                        # Flutter app entry point
│   ├── lib/
│   │   ├── firebase_options.dart   # Firebase config (web)
│   │   ├── main.dart
│   │   └── src/
│   │       ├── app/            # Bootstrap + root widget
│   │       └── routing/        # go_router shell + bottom nav
│   └── web/                    # Web-specific assets & index.html
│
├── packages/
│   ├── core/                   # AppError, Result<T>, Logger
│   ├── domain/                 # Entities, repository interfaces, use-cases
│   ├── data/                   # Firebase repository implementations, DTOs
│   ├── design_system/          # Theme, colors, typography, shared components
│   └── features/
│       ├── auth/               # Sign-in screen
│       ├── balances/           # Home screen (balances + groups overview)
│       ├── expenses/           # Add expense screen (with OCR)
│       ├── groups/             # Groups list screen
│       ├── activity/           # Activity feed screen
│       └── settings/           # Settings screen
│
├── docs/                       # PRD, architecture docs, brand guidelines, marketing assets
├── firebase/                   # Firestore rules + composite index definitions
├── functions/                  # Cloud Functions (placeholder)
├── .github/workflows/          # GitHub Actions: build + deploy to GitHub Pages + Firebase
├── melos.yaml                  # Monorepo config
└── pubspec.yaml                # Root pubspec
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — stable channel, Dart ≥ 3.5.0
- [Melos](https://melos.invertase.dev/) — monorepo tooling
- Chrome browser

```bash
dart pub global activate melos
```

### Clone & Run

```bash
git clone https://github.com/VikasNVCchauhan/splitbo.git
cd splitbo

# Install all package dependencies
flutter pub get

# Run the web app on Chrome (debug mode — skips Google Sign-In, goes straight to home)
cd app
flutter run -d chrome --web-port 3000
```

App opens at **http://localhost:3000**

> **Debug mode bypass:** In `kDebugMode`, the auth guard is skipped and the app opens directly to the home screen. This is intentional for local UI development — no Firebase account needed to build and test locally.

---

## Developer Onboarding — New Team Member Checklist

Follow these steps when setting up on a new machine.

### 1. Request Google Account Access

Ask the project owner to add your Google account to the Firebase project:
- Firebase Console → **Project Settings** → **Users and permissions** → Add member

### 2. Add Your Localhost to OAuth Whitelist

For Google Sign-In to work on your local machine (release mode / production testing):

1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=splitbo)
2. Open the OAuth 2.0 Client ID named `splitbo`
3. Under **Authorised JavaScript origins**, add: `http://localhost:3000`
4. Click **Save** — takes ~30 seconds to propagate

### 3. Firebase Project Details

| Field | Value |
|-------|-------|
| Project ID | `splitbo` |
| Project Console | https://console.firebase.google.com/project/splitbo |
| Auth Provider | Google Sign-In (enabled) |
| Firestore Region | `nam5` (us-central) |

Firestore collections:

| Collection | Prefix in dev | Description |
|-----------|--------------|-------------|
| `users` | `dev_users` | User profiles |
| `groups` | `dev_groups` | Expense groups |
| `expenses` | `dev_expenses` | Expenses per group |
| `balances` | `dev_balances` | Per-user balance snapshots |

> **Dev vs Prod isolation:** When running locally (`kDebugMode = true`), all Firestore reads/writes go to `dev_*` collections. Production data is never touched during local development.

### 4. GitHub Repository

| Field | Value |
|-------|-------|
| Repo | https://github.com/VikasNVCchauhan/splitbo |
| Live URL | https://vikasnvcchauhan.github.io/splitbo/ |
| Default branch | `main` |

Every push to `main` automatically:
- Builds the Flutter web app
- Deploys to GitHub Pages (live URL above)
- Deploys Firestore security rules + composite indexes to Firebase

### 5. GitHub Secrets (CI/CD)

The following secret is required in the GitHub repo for the auto-deploy to work. The project owner manages this.

| Secret Name | Purpose |
|------------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON for deploying Firestore rules/indexes |

To regenerate this key (if it expires or needs rotation):
1. Go to [Firebase Console → Project Settings → Service Accounts](https://console.firebase.google.com/project/splitbo/settings/serviceaccounts/adminsdk)
2. Click **Generate new private key**
3. Go to [GitHub → Settings → Secrets → Actions](https://github.com/VikasNVCchauhan/splitbo/settings/secrets/actions)
4. Update the `FIREBASE_SERVICE_ACCOUNT` secret with the new JSON content

> **Never commit the service account JSON to the repo.** It is only stored in GitHub Secrets.

### 6. Firestore Composite Indexes

Indexes are defined in [`firebase/firestore.indexes.json`](firebase/firestore.indexes.json) and deployed automatically by GitHub Actions.

Current indexes:

| Collection | Fields | Purpose |
|-----------|--------|---------|
| `groups` | `memberIds` (array-contains) + `createdAt` (desc) | Home screen groups list |
| `expenses` | `groupId` (asc) + `createdAt` (desc) | Group expense feed |
| `expenses` | `paidBy` (asc) + `createdAt` (desc) | Balance calculations |
| `balances` | `userId` (asc) + `groupId` (asc) | Balance lookups |

---

## Architecture

Splitbo uses a layered Clean Architecture across Melos packages:

```
UI (features) → domain (entities + use-cases) → data (Firebase implementations)
```

- **`core`** — Pure Dart. `AppError` sealed class, `Result<T>` type with `.fold(ok:, err:)`, logger.
- **`domain`** — No Flutter deps. Defines `GroupEntity`, `ExpenseEntity`, etc. and abstract repository interfaces.
- **`data`** — Implements repositories using Firestore. All Firestore calls return `Stream<Result<T>>`.
- **`design_system`** — Single source of truth for colors (`brandPrimary = #C3FD00`), text styles, and reusable widgets.
- **`features/*`** — Each screen is a self-contained package. Uses Riverpod providers from `data` and entities from `domain`.

### State Management

Manual Riverpod — no code generation. Key provider types used:

```dart
// Real-time stream from Firestore
final watchGroupsProvider = StreamProvider<Result<List<GroupEntity>>>(...);

// Auth state
final authStateProvider = StreamProvider<UserEntity?>(...);
```

---

## OCR Receipt Scanning

On the Add Expense screen, tap **Scan Receipt** to:

1. Take a photo, pick from gallery, or upload a PDF/DOCX
2. The file is sent to **Gemini 1.5 Flash** with a structured prompt
3. Gemini understands full receipt context and returns JSON: `{amount, description, category, notes}`
4. Fields are auto-filled in the form — review and save

The Gemini API key is bundled in the app (same Firebase project key). Enable the **Generative Language API** in Google Cloud Console if OCR returns errors.

---

## Brand

| Token | Value |
|-------|-------|
| Brand Green | `#C3FD00` |
| Background | `#000000` |
| Surface | `#111111` / `#1A1A1A` |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#9E9E9E` |

Logo mark is an SVG `CustomPainter` — dot + curved blade + crescent with punched hole, matching the original brand SVG exactly.

---

## Architecture Diagram

Use this prompt in any AI image generator (Midjourney, DALL·E, Ideogram, etc.):

```
A clean, dark-background software architecture diagram for a mobile app called "Splitbo".
Use a dark (#0D0D0D) background with neon green (#C3FD00) accent lines and white text labels.
Show four horizontal layers stacked vertically with arrows between them:

Layer 1 (top) — "Flutter UI" in dark card boxes:
  SignInScreen | HomeScreen | GroupsScreen | AddExpenseScreen | ActivityScreen

Layer 2 — "Riverpod State" in rounded pill shapes:
  authStateProvider | watchGroupsProvider | watchExpensesProvider

Layer 3 — "Domain" in outlined boxes:
  Entities (User, Group, Expense, Balance) | Use-Cases | Repository Interfaces

Layer 4 — "Data / Firebase" in solid dark boxes:
  Firebase Auth | Firestore | Firebase Storage | Gemini 1.5 Flash (OCR)

On the right side, show a vertical "Packages" sidebar listing:
  core | domain | data | design_system | features/*

Use thin neon-green (#C3FD00) connector arrows between layers.
Typography: monospace font, all labels in white or neon green.
Overall aesthetic: GitHub dark mode meets a fintech dashboard.
No gradients, no shadows, flat and minimal.
```

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit with context: `git commit -m "feat: add settle-up flow"`
4. Open a PR against `main`

---

## Roadmap

- [x] Firestore security rules
- [ ] Native iOS / Android builds
- [ ] Push notifications (Firebase Messaging)
- [ ] Invite members via link
- [ ] Export expenses to CSV/PDF
- [ ] Offline support

---

## License

Private — all rights reserved. Contact the Splitbo team before use or redistribution.
