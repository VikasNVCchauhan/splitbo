# Splitbo

> **Split bills. Keep friends.**

🌐 **Live App: [https://vikasnvcchauhan.github.io/splitbo/](https://vikasnvcchauhan.github.io/splitbo/)**

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
├── firebase/                   # Firebase config (rules, indexes)
├── functions/                  # Cloud Functions (placeholder)
├── tools/                      # Dev tools (contrast checker, token generator)
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

# Run the web app on Chrome
cd app
flutter run -d chrome --web-port 3000
```

App opens at **http://localhost:3000**

---

## Firebase Setup

The app connects to the `splitbo` Firebase project. `firebase_options.dart` is included in the repo so no additional Firebase setup is needed to run the app.

For Google Sign-In to work on your machine, you need to whitelist `localhost:3000` in Google Cloud Console:

1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
2. Open the OAuth 2.0 client for the `splitbo` project
3. Under **Authorised JavaScript origins**, add `http://localhost:3000`
4. Save and wait ~30 seconds for propagation

> **Note:** Firestore security rules are open during development. Tighten before any public release.

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
3. Gemini understands full receipt context (restaurant, utility bill, grocery, fuel, etc.) and returns JSON: `{amount, description, category, notes}`
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

Use this prompt in any AI image generator (Midjourney, DALL·E, Ideogram, etc.) to produce an architecture diagram for Splitbo:

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

- [ ] Firestore security rules
- [ ] Native iOS / Android builds
- [ ] Push notifications (Firebase Messaging)
- [ ] Invite members via link
- [ ] Export expenses to CSV/PDF
- [ ] Offline support

---

## License

Private — all rights reserved. Contact the Splitbo team before use or redistribution.
