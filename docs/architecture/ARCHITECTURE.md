# Splitbo — Technical Architecture

**Version:** 1.0  
**Date:** September 18, 2026

---

## 1. Core Principle — One App, All Platforms

> **There is NO separate iOS app, Android app, or web app.**
> One repository. One TypeScript codebase. One release cycle.

The same source code compiles to:
- A native **iOS binary** (.ipa) → App Store
- A native **Android binary** (.aab) → Google Play
- A **Progressive Web App** (PWA) → Firebase Hosting (splitbo.app / splitbo.in)

All three targets share 100% of business logic, state management, services, and the Firebase backend. Platform-specific adaptations (StatusBar, biometric APIs) are handled by Expo's cross-platform abstraction — no forked code paths.

---

## 2. Tech Stack Decision

### Framework: React Native + Expo SDK 52

| Option | iOS | Android | Web | Notes |
|--------|-----|---------|-----|-------|
| **React Native + Expo** | ✅ | ✅ | ✅ (react-native-web) | Best ecosystem, Firebase JS SDK, Expo handles store builds |
| Flutter | ✅ | ✅ | ✅ | Equally valid — Dart adds learning curve |
| Ionic / Capacitor | ✅ | ✅ | ✅ | WebView-based, lower native feel |

**Decision: React Native + Expo SDK 52**

Reasons:
- Single JavaScript/TypeScript codebase → iOS, Android, and Web, zero duplication
- Expo EAS Build produces signed `.ipa` and `.aab` ready for App Store / Play Store
- Firebase JS SDK (`firebase/app`, `firebase/firestore`, etc.) works identically on all three platforms
- `react-native-web` bridges native components to DOM — same components, no rewrites
- Largest community + best tooling for indie/startup pace

### Backend: Firebase (Google Cloud)

| Service | Purpose |
|---------|---------|
| Firebase Authentication | Email/password, Google OAuth, Phone OTP |
| Cloud Firestore | Primary database (realtime, offline-capable) |
| Cloud Functions (Node.js) | Balance recalculation, notifications, invite link validation |
| Firebase Storage | Profile photos, expense receipt images |
| Firebase Cloud Messaging | Push notifications (iOS APNs + Android FCM) |
| Firebase Dynamic Links | Group invite deep links |
| Firebase Hosting | Web app hosting (PWA) |

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│                                                          │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐    │
│  │  iOS App │   │Android   │   │  Web (Browser /  │    │
│  │ (Expo)   │   │App (Expo)│   │  Firebase Hosting│    │
│  └────┬─────┘   └────┬─────┘   └────────┬─────────┘    │
│       └──────────────┴──────────────────┘               │
│              React Native + Expo SDK                     │
│              react-native-web (for web target)           │
└────────────────────────┬────────────────────────────────┘
                         │ Firebase JS SDK (v10 modular)
┌────────────────────────▼────────────────────────────────┐
│                  FIREBASE BACKEND                         │
│                                                          │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  │
│  │  Auth   │  │Firestore │  │ Storage  │  │   FCM   │  │
│  └─────────┘  └────┬─────┘  └──────────┘  └────┬────┘  │
│                    │                            │        │
│             ┌──────▼─────────────────────┐     │        │
│             │    Cloud Functions (Node)  │─────┘        │
│             │  - onExpenseWrite          │              │
│             │  - onSettlementWrite       │              │
│             │  - sendNotification        │              │
│             │  - validateInviteLink      │              │
│             └───────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Frontend Project Structure

```
splitbo/
├── app/                          # Expo Router file-based navigation
│   ├── (auth)/
│   │   ├── welcome.tsx           # 3-slide onboarding carousel
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   └── phone-verify.tsx
│   ├── (tabs)/
│   │   ├── _layout.tsx           # Tab bar definition
│   │   ├── friends/
│   │   │   ├── index.tsx         # Friends list
│   │   │   └── [friendId].tsx    # Friend detail
│   │   ├── groups/
│   │   │   ├── index.tsx         # Groups list
│   │   │   ├── create.tsx        # Create group
│   │   │   └── [groupId]/
│   │   │       ├── index.tsx     # Group detail (tabs: expenses/balances/totals/whiteboard)
│   │   │       └── settings.tsx  # Group settings
│   │   ├── activity.tsx          # Global activity feed
│   │   └── account/
│   │       ├── index.tsx
│   │       ├── notifications.tsx
│   │       ├── security.tsx
│   │       └── appearance.tsx
│   └── _layout.tsx               # Root layout + AuthGuard
│
├── components/
│   ├── expense/
│   │   ├── AddExpenseModal.tsx
│   │   ├── ChoosePayerSheet.tsx
│   │   ├── SplitOptionsSheet.tsx
│   │   ├── EnterPaidAmountsSheet.tsx
│   │   └── ExpenseListItem.tsx
│   ├── settlement/
│   │   └── SettleUpModal.tsx
│   ├── group/
│   │   ├── GroupCard.tsx
│   │   ├── MemberAvatar.tsx
│   │   └── BalanceRow.tsx
│   ├── friend/
│   │   ├── FriendCard.tsx
│   │   └── AddFriendSheet.tsx
│   └── ui/
│       ├── Button.tsx
│       ├── Avatar.tsx
│       ├── BalanceBadge.tsx      # Green/orange amount chip
│       ├── CategoryIcon.tsx
│       ├── OfflineBanner.tsx
│       └── TabBarIcon.tsx
│
├── store/                        # Zustand stores
│   ├── authStore.ts
│   ├── friendsStore.ts
│   ├── groupsStore.ts
│   ├── expensesStore.ts
│   └── activityStore.ts
│
├── services/                     # Firebase interaction layer
│   ├── firebase.ts               # Firebase app init
│   ├── auth.ts                   # Auth helpers
│   ├── users.ts
│   ├── friends.ts
│   ├── groups.ts
│   ├── expenses.ts
│   ├── settlements.ts
│   ├── balances.ts               # Read denormalized balance cache
│   ├── activity.ts
│   └── storage.ts                # Photo upload helpers
│
├── utils/
│   ├── splitCalculator.ts        # Pure functions for split math
│   ├── simplifyDebts.ts          # Debt minimization algorithm
│   ├── currency.ts               # Format ₹ / $ / € amounts
│   └── contacts.ts               # Device contacts access
│
├── hooks/
│   ├── useCurrentUser.ts
│   ├── useGroupBalances.ts
│   ├── useExpenses.ts
│   └── useNetworkStatus.ts
│
├── constants/
│   ├── categories.ts             # Expense category list + icons
│   ├── currencies.ts
│   └── theme.ts                  # Color tokens, spacing, typography
│
├── functions/                    # Cloud Functions (Node.js)
│   └── src/
│       ├── index.ts
│       ├── onExpenseWrite.ts
│       ├── onSettlementWrite.ts
│       ├── sendNotification.ts
│       └── validateInviteLink.ts
│
├── app.json                      # Expo config
├── eas.json                      # EAS Build config (iOS + Android)
├── firebase.json                 # Firebase Hosting + Functions config
├── firestore.rules               # Security rules
├── firestore.indexes.json        # Composite indexes
└── storage.rules
```

---

## 4. Firestore Data Model

### 4.1 Collections Overview

```
/users/{userId}
/users/{userId}/friends/{friendUserId}
/groups/{groupId}
/expenses/{expenseId}
/settlements/{settlementId}
/balances/{userId}/friends/{friendUserId}    ← denormalized cache
/balances/{userId}/groups/{groupId}          ← denormalized cache
/activity/{activityId}
/invites/{inviteCode}
```

### 4.2 Document Schemas

#### `/users/{userId}`
```typescript
{
  uid: string
  email: string
  displayName: string
  photoURL: string | null
  phone: string | null
  defaultCurrency: "INR" | "USD" | ...
  fcmTokens: string[]           // for push notifications
  createdAt: Timestamp
}
```

#### `/users/{userId}/friends/{friendUserId}`
```typescript
{
  userId: string                // mirrors the doc ID
  status: "pending" | "accepted"
  addedAt: Timestamp
  addedBy: string               // who initiated
}
```

#### `/groups/{groupId}`
```typescript
{
  name: string
  type: "trip" | "home" | "couple" | "other"
  photoURL: string | null
  members: string[]             // array of userIds
  createdBy: string
  createdAt: Timestamp
  defaultCurrency: string
  simplifyDebts: boolean
  whiteboard: string            // free text, real-time field
  archived: boolean
}
```

#### `/expenses/{expenseId}`
```typescript
{
  groupId: string | null        // null = friend-to-friend expense
  friendId: string | null       // set when groupId is null
  description: string
  amount: number                // total, always positive
  currency: string
  category: string
  date: Timestamp
  notes: string | null
  receiptURL: string | null
  createdBy: string
  createdAt: Timestamp
  updatedAt: Timestamp
  deletedAt: Timestamp | null

  // Who paid (supports multiple payers)
  paidBy: { [userId: string]: number }

  // How it's split (how much each person owes, not what they paid)
  splits: { [userId: string]: number }

  splitMethod: "equal" | "exact" | "percent" | "shares" | "adjustment"
  participants: string[]        // userIds involved (for query filtering)
}
```

#### `/settlements/{settlementId}`
```typescript
{
  from: string                  // userId who paid
  to: string                    // userId who received
  amount: number
  currency: string
  groupId: string | null
  note: string | null           // e.g. "UPI ref: 123456"
  createdBy: string
  createdAt: Timestamp
}
```

#### `/balances/{userId}/friends/{friendUserId}`
```typescript
{
  balance: number               // positive = friendUser owes me, negative = I owe them
  currency: string
  lastUpdated: Timestamp
}
```

#### `/balances/{userId}/groups/{groupId}`
```typescript
{
  balance: number               // net position in group
  currency: string
  lastUpdated: Timestamp
}
```

#### `/activity/{activityId}`
```typescript
{
  type: "expense_added" | "expense_updated" | "expense_deleted"
       | "settlement_added" | "member_added" | "group_created" | "group_deleted"
  actorId: string
  affectedUsers: string[]       // for query: "show me my activity"
  groupId: string | null
  relatedId: string             // expense or settlement id
  createdAt: Timestamp
  snapshot: object              // denormalized data for display (no extra reads)
}
```

#### `/invites/{inviteCode}`
```typescript
{
  groupId: string
  createdBy: string
  createdAt: Timestamp
  expiresAt: Timestamp          // 7 days
  used: boolean
}
```

---

## 5. Cloud Functions

### `onExpenseWrite` (Firestore trigger)
Fires on create/update/delete of `/expenses/{expenseId}`.  
- Recalculates balances for all affected users (both the old and new state)
- Writes to `/balances/{userId}/friends/` and `/balances/{userId}/groups/`
- Creates an `/activity/` document

### `onSettlementWrite` (Firestore trigger)
Fires on create of `/settlements/{settlementId}`.  
- Adjusts balances for the two parties
- Creates an `/activity/` document

### `sendNotification` (called from above triggers)
- Looks up FCM tokens of affected users
- Sends targeted push notification via Firebase Admin SDK

### `validateInviteLink` (HTTPS callable)
- Validates invite code, marks as used, adds calling user to group members

---

## 6. Split Calculator Logic (`utils/splitCalculator.ts`)

```typescript
// Returns { [userId]: amountOwed } such that sum == totalAmount
// Remainder from rounding is assigned to the payer

type SplitInput =
  | { method: "equal"; participants: string[]; total: number; payerId: string }
  | { method: "exact"; amounts: Record<string, number> }
  | { method: "percent"; percents: Record<string, number>; total: number; payerId: string }
  | { method: "shares"; shares: Record<string, number>; total: number; payerId: string }

function calculateSplits(input: SplitInput): Record<string, number>
```

Key invariant: `Object.values(result).reduce((a,b) => a+b, 0) === total` (within floating-point tolerance, remainder goes to payer).

---

## 7. Debt Simplification (`utils/simplifyDebts.ts`)

Classic minimum cash flow problem (NP-hard in general but tractable for groups < 20):

1. Build net balance per member (total owed minus total paid)
2. Repeatedly pick the max creditor and max debtor
3. Match them: one transaction covers min(|creditor|, |debtor|)
4. Reduce until all balances are zero

Result: minimum number of transactions to settle all debts within a group.

---

## 8. Firestore Security Rules (approach)

```
// expenses: only participants can read; only authenticated users who are
//           members of the associated group can write
match /expenses/{expenseId} {
  allow read: if request.auth.uid in resource.data.participants;
  allow create: if request.auth.uid in
    get(/databases/$(database)/documents/groups/$(request.resource.data.groupId)).data.members;
  allow update, delete: if request.auth.uid == resource.data.createdBy
    || request.auth.uid in
    get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
}

// balances: only the owner can read their own balance cache
match /balances/{userId}/{sub=**} {
  allow read: if request.auth.uid == userId;
  allow write: if false;  // only Cloud Functions write balances
}
```

---

## 9. State Management (Zustand)

Each store subscribes to a Firestore `onSnapshot` listener and updates local state in real time.

```typescript
// groupsStore.ts
interface GroupsStore {
  groups: Group[]
  loading: boolean
  subscribe: (userId: string) => Unsubscribe
  createGroup: (data: CreateGroupInput) => Promise<string>
  addMember: (groupId: string, userId: string) => Promise<void>
}
```

Listeners are set up on login and torn down on logout. Offline persistence means the store hydrates from local Firestore cache even with no network.

---

## 10. Navigation (Expo Router)

Expo Router uses file-based routing (like Next.js).

- `/app/(auth)/` — unauthenticated routes (login, signup)
- `/app/(tabs)/` — main app behind auth guard, renders bottom tab bar
- Auth guard in `/app/_layout.tsx` redirects to `/welcome` if no user session

On web, the same routes become real browser URLs:
- `splitbo.app/groups/abc123` → Group detail page
- `splitbo.app/join/CODE` → Invite link landing page

---

## 11. Theming

Two themes (light / dark) defined in `constants/theme.ts`:

```typescript
export const Colors = {
  brand: {
    primary: "#1DB954",     // Splitbo green (same family as Splitwise but distinct)
    secondary: "#2D9CDB",
  },
  semantic: {
    positive: "#27AE60",    // you are owed
    negative: "#E07B39",    // you owe
    neutral: "#6B7280",
  },
  // ... background, surface, text tokens for light/dark
}
```

NativeWind (Tailwind CSS for React Native) handles utility classes. Custom design tokens override the default Tailwind palette.

---

## 12. Deployment

### Mobile (EAS Build + EAS Submit)
```bash
# Install EAS CLI
npm install -g eas-cli

# Configure builds
eas build:configure

# Build for both stores
eas build --platform all --profile production

# Submit to stores
eas submit --platform ios      # Uploads to App Store Connect
eas submit --platform android  # Uploads to Google Play
```

`eas.json` defines build profiles for `development`, `preview`, and `production`.

### Web (Firebase Hosting)
```bash
npm run build:web          # expo export --platform web
firebase deploy --only hosting
```

Web app lives at `https://splitbo.app` (or `splitbo.in`).

### Cloud Functions
```bash
cd functions && npm run build
firebase deploy --only functions
```

### CI/CD
GitHub Actions workflows:
- `pr.yml` — runs `tsc`, `eslint`, and unit tests on every PR
- `deploy-web.yml` — builds and deploys web on merge to `main`
- `deploy-functions.yml` — deploys functions on merge to `main`
- `eas-build.yml` — triggers EAS build on version tag push

---

## 13. Development Environment Setup

```bash
# Prerequisites
node >= 20
npm >= 10
expo-cli / eas-cli
firebase-tools

# Clone and install
git clone https://github.com/[org]/splitbo
cd splitbo
npm install

# Firebase project setup
firebase login
firebase use --add   # select your Firebase project

# Copy env template
cp .env.example .env.local
# Fill in FIREBASE_API_KEY, FIREBASE_PROJECT_ID, etc.

# Start development
npx expo start          # starts Metro bundler
# Press i → iOS simulator
# Press a → Android emulator
# Press w → Web browser

# Run Cloud Functions locally
cd functions
npm run serve           # starts functions emulator on :5001
```

---

## 14. Key Technical Decisions & Rationale

| Decision | Chosen | Why |
|----------|--------|-----|
| Navigation | Expo Router | File-based, web URL support built in |
| State management | Zustand | Minimal boilerplate, works well with Firestore listeners |
| Styling | NativeWind (Tailwind) | Shared utility classes across native + web |
| Balance updates | Cloud Functions (server-side) | Prevents client-side race conditions when multiple users add expenses simultaneously |
| Split storage | Store final amounts (not ratios) | Prevents recalculation drift; amounts are the source of truth |
| Offline | Firestore offline persistence + optimistic UI | User can add expenses on a plane, syncs on land |
| Image upload | Firebase Storage + resized thumbnails via extension | Keeps Firestore documents small |
| Invite links | Firebase Dynamic Links | Handles App Store redirect for new users, falls back to web |
