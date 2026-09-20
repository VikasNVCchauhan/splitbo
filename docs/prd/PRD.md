# Splitbo — Product Requirements Document

**Version:** 1.0  
**Date:** September 18, 2026  
**Domain options:** splitbo.in / splitbo.com / splitbo.app

---

## 1. Overview

Splitbo is a cross-platform expense-splitting app that lets groups of people track shared expenses, see who owes what, and settle up easily. It runs identically on iOS, Android, and Web from a single codebase, with Firebase as the backend.

The reference product is Splitwise. Splitbo delivers all core Splitwise features in a free, India-first product with better INR handling, UPI-aware settlement notes, and no paywalled features.

---

## 2. Problem Statement

Splitwise's core splitting features are locked behind a ₹1,399/year Pro plan (charts, currency conversion, receipt scan). Indian users — whose primary use cases are group trips, flat-mate bills, and friend expenses denominated in INR — get a degraded free experience. Splitbo ships all essential features free, targets India first, and grows globally.

---

## 3. Goals

| Goal | Metric |
|------|--------|
| Cross-platform parity | Same feature set on iOS, Android, Web |
| Free core features | No expense limits, no paywall on splits/charts |
| India-first | INR default, UPI payment notes, Indian phone number support |
| Firebase backend | Realtime sync, offline support, scalable auth |
| App Store + Play Store launch | Published on both stores at v1.0 |

### Non-Goals (v1)
- AI receipt OCR / itemization
- Multi-currency conversion (single currency per group)
- In-app payments / UPI integration
- WhatsApp/SMS bot interface
- Business expense management

---

## 4. User Personas

**Vikas — Trip Organizer**  
Travels with friends 3–4x/year. Pays upfront for hotels/transport and needs others to reimburse him. Currently uses Splitwise but frustrated by the Pro wall on charts.

**Nikki — Flat-mate**  
Shares rent, electricity, groceries with 2 others. Needs running balances, not just one-off trips.

**Rashmi — Occasional Splitter**  
Joins groups for specific trips, doesn't want to manage a complex app. Needs simple "view what I owe" and settle-up flow.

---

## 5. Core Features — MVP v1

### 5.1 Authentication
- Email + password sign-up / login
- Google Sign-In (OAuth)
- Phone number OTP (Firebase Phone Auth) — India focus
- Profile: display name, photo, email, phone, default currency

### 5.2 Friends
- Add friends by email, phone, or from device contacts
- Friend list shows overall balance per friend (green = they owe you, orange = you owe them)
- Tap a friend to see all shared expenses and the running balance
- "Settle up" button to record a payment

### 5.3 Groups
- Create group with name, type (Trip / Home / Couple / Other), and optional cover photo
- Group types shown with icons (airplane, house, heart, list)
- Add members by friend list or invite link (dynamic link)
- Group detail tabs: **Expenses · Balances · Totals · Whiteboard**
- Simplify debts toggle (minimise number of payments within group)
- Delete / archive group

### 5.4 Expenses
- Add expense to a group or directly with a friend
- Fields: description, amount, currency (default INR), date, category, notes, receipt photo
- **Paid by**: single person or split across multiple payers
- **Split methods**:
  - Equal (÷ among selected members)
  - Exact amounts (specify per person)
  - Percentages (must sum to 100%)
  - Shares / units
  - Adjustment (+/− on top of equal)
- Running tracker: "₹X of ₹Y · ₹Z left" during entry
- Edit / delete expense (with activity log entry)
- Expense categories: Food, Transport, Accommodation, Entertainment, Groceries, Utilities, Other

### 5.5 Balances & Settlement
- Per-group balance list: who owes whom how much
- Overall friend balance across all groups
- "Settle up" flow: record a manual payment, optionally add payment note (e.g. UPI transaction ID)
- Simplify debts: collapse N payments into minimum transactions

### 5.6 Activity Feed
- Global feed of all events: expense added, expense updated, expense deleted, settlement recorded, member added/removed
- Shows actor name, action, group name, amount, timestamp
- Color-coded: green = you get back, orange = you owe

### 5.7 Account & Settings
- Edit profile (name, photo, email, phone)
- Default currency preference
- Notification preferences (push notifications via FCM)
- Appearance: Light / Dark / System
- Security: Biometric lock (FaceID / fingerprint)
- Export group expenses as CSV
- Log out

### 5.8 Notifications (Push)
- Someone adds an expense that includes you
- Someone edits/deletes an expense that includes you
- Someone settles up with you
- Someone adds you to a group

---

## 6. Feature Details

### 6.1 Split Calculation Logic
All splits are stored as exact decimal amounts per user. On save, the system validates that `sum(splits) == total amount` and shows a rounding remainder that gets assigned to the payer. Balances are updated atomically via Cloud Functions.

### 6.2 Balance Denormalization
To avoid recalculating balances from all expenses on every load, Cloud Functions maintain a `/balances` cache updated on every expense create/update/delete/settlement. Client reads balances from cache, not from raw expenses.

### 6.3 Offline Support
Firestore's offline persistence is enabled. Users can browse existing data offline. Adding expenses while offline queues writes and syncs on reconnect. A banner indicates offline state.

### 6.4 Invite Links
Group invite links use Firebase Dynamic Links (or branch.io as fallback). Link opens the app (or web) and prompts the recipient to join the group.

### 6.5 Whiteboard
Free-text note area per group. Useful for trip to-dos, shared grocery lists, etc. Stored as a simple Firestore document, real-time synced.

---

## 7. Screens Map

```
App
├── Auth
│   ├── Welcome / Onboarding (3-slide carousel)
│   ├── Sign Up
│   ├── Log In
│   └── Phone OTP Verify
│
├── Main (Tab Bar)
│   ├── Friends Tab
│   │   ├── Friends List (overall balance per friend)
│   │   ├── Friend Detail (expense list + balance)
│   │   ├── Add Friends (search / contacts / email)
│   │   └── Add Expense (with friend)
│   │
│   ├── Groups Tab
│   │   ├── Groups List
│   │   ├── Create Group
│   │   ├── Group Detail
│   │   │   ├── Expenses sub-tab
│   │   │   ├── Balances sub-tab
│   │   │   ├── Totals sub-tab
│   │   │   └── Whiteboard sub-tab
│   │   ├── Group Settings
│   │   └── Add Members
│   │
│   ├── Activity Tab
│   │   └── Global Activity Feed
│   │
│   └── Account Tab
│       ├── Profile
│       ├── Notifications Settings
│       ├── Security Settings
│       ├── Appearance Settings
│       └── Export Data
│
└── Modals / Overlays
    ├── Add / Edit Expense
    │   ├── Choose Payer
    │   ├── Split Options
    │   └── Enter Paid Amounts
    └── Settle Up
```

---

## 8. Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| App launch time | < 2 s cold start |
| Expense save latency | < 1 s (with good connection) |
| Offline reads | Full history accessible |
| Auth token refresh | Handled transparently by Firebase SDK |
| Data consistency | Firestore transactions for balance updates |
| Push notification delivery | FCM, < 5 s after trigger |
| Platform support | iOS 16+, Android 8+, modern browsers (Chrome, Safari, Firefox) |
| Accessibility | WCAG AA contrast, screen-reader labels on interactive elements |

---

## 9. Success Metrics (v1 Launch)

- 500 registered users within 30 days of launch
- Average 3+ groups created per active user
- Day-7 retention > 40%
- Crash-free sessions > 99%
- App Store rating ≥ 4.2

---

## 10. Out of Scope (Post-v1 Roadmap)

- AI receipt scan & itemization
- Multi-currency with live FX rates
- In-app UPI payment integration
- Recurring expenses (subscriptions, rent)
- Budget tracking / spending analytics
- Group chat
- Web scraping bank statements for auto-import
- Business / team expense reports
