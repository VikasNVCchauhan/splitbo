# Splitbo — Firestore Architecture

## Design Principles

- **Read-optimised**: Firestore is a document database billed per read/write. Denormalise aggressively for reads; use Cloud Functions for write-time aggregation.
- **Query-first**: Every collection shape is driven by the queries the UI needs, not by normalisation dogma.
- **Sub-1MB documents**: Firestore caps docs at 1 MB. Arrays (memberIds, splits) stay bounded by business rules (max 50 members per group, max 20 splits per expense).
- **Partition by user**: `memberIds array-contains` is the primary access pattern — no cross-user fan-out at query time.
- **Eventual consistency is fine**: Balance totals are cached and written by Cloud Functions. Brief staleness (< 2 s) is acceptable; the real-time stream corrects it.

---

## Collections

### `users/{userId}`

```
{
  id:           string        // = Firebase Auth UID
  displayName:  string
  email:        string
  avatarUrl:    string?
  fcmTokens:    string[]      // one per device/browser — pruned by Cloud Functions
  createdAt:    Timestamp
  updatedAt:    Timestamp
}
```

**Access pattern**: `users/{userId}` — always by document ID. No collection-level queries from clients.

---

### `groups/{groupId}`

```
{
  id:                 string
  name:               string
  description:        string
  currency:           string        // ISO 4217: INR, USD, EUR…
  memberIds:          string[]      // UIDs — max 50
  memberDisplayNames: map           // {uid: "Alice"} — denorm for UI
  memberAvatarUrls:   map           // {uid: "https://…"} — denorm for UI
  createdBy:          string        // UID
  createdAt:          Timestamp
  updatedAt:          Timestamp
  totalExpenses:      number        // cached by Cloud Function on expense write
  archivedAt:         Timestamp?    // soft-delete
}
```

**Access patterns**:
- Home screen: `memberIds array-contains userId, orderBy createdAt DESC` → composite index
- Group detail: `groups/{groupId}` by ID

**Scale note**: `memberIds` array is fine up to ~10,000 elements in Firestore but business rule caps at 50. `array-contains` on indexed fields is O(1).

---

### `expenses/{expenseId}`

```
{
  id:          string
  groupId:     string        // FK — not a subcollection so cross-group queries work
  description: string
  amount:      number        // always positive; currency in group doc
  currency:    string
  paidBy:      string        // UID
  splits: [
    { userId: string, amount: number }  // must sum to amount
  ]
  category:    string        // enum: food | transport | accommodation | …
  receiptUrl:  string?
  notes:       string?
  createdBy:   string
  createdAt:   Timestamp
  updatedAt:   Timestamp
  deletedAt:   Timestamp?    // soft-delete
}
```

**Access patterns**:
- Group feed: `groupId == X, orderBy createdAt DESC` → composite index
- Activity feed: watch multiple groups, merge client-side (already implemented)
- User's paid: `paidBy == userId, orderBy createdAt DESC` → composite index (for reimbursements)

**Scale note**: Top-level collection (not subcollection of groups) enables cross-group queries needed for Activity feed and enterprise reporting without collection group queries.

---

### `balances/{userId_groupId}`

```
{
  userId:     string
  groupId:    string
  netAmount:  number     // positive = others owe this user; negative = user owes
  currency:   string
  updatedAt:  Timestamp
}
```

Document ID pattern: `{userId}_{groupId}` — enables O(1) lookup without a query.

**Written by**: Cloud Function on every expense create/update/delete (Firestore transaction for atomicity).

---

### `settlements/{settlementId}` *(Phase 2)*

```
{
  groupId:    string
  payerId:    string
  payeeId:    string
  amount:     number
  currency:   string
  note:       string?
  settledAt:  Timestamp
  createdBy:  string
}
```

Settles a balance between two users. Cloud Function updates both balance documents atomically.

---

### `invites/{inviteId}` *(Phase 2)*

```
{
  groupId:    string
  createdBy:  string
  createdAt:  Timestamp
  expiresAt:  Timestamp    // 7 days default
  usedBy:     string[]     // UIDs who joined via this link
  maxUses:    number?      // null = unlimited
}
```

Invite links reference this doc. Current v1 uses `groupId` directly in the URL (no expiry). Phase 2 upgrades to proper invite docs.

---

### Enterprise collections *(Phase 3)*

```
organizations/{orgId}
  - name, plan, adminIds[], createdAt

org_members/{orgId_userId}
  - orgId, userId, role (admin|manager|employee), department, costCentre

reimbursements/{reimId}
  - orgId, employeeId, expenseId, amount, status (pending|approved|rejected|paid)
  - submittedAt, approvedBy, approvedAt, paidAt, rejectionReason

policies/{policyId}
  - orgId, name, rules: [{category, maxAmount, requiresReceipt}]
```

---

## Indexes

All indexes are in `firebase/firestore.indexes.json` and deployed automatically by GitHub Actions.

| Collection | Fields | Use case |
|-----------|--------|---------|
| `groups` | `memberIds CONTAINS` + `createdAt DESC` | Home screen list |
| `expenses` | `groupId ASC` + `createdAt DESC` | Group expense feed |
| `expenses` | `paidBy ASC` + `createdAt DESC` | Balance calc + reimbursements |
| `balances` | `userId ASC` + `groupId ASC` | Balance lookup |

---

## Security Rules Design

See `firebase/firestore.rules`. Key principles:
- Users can only read/write their own `users/{userId}` doc
- Group read/write requires `request.auth.uid in resource.data.memberIds`
- Expense read/write requires membership in the expense's group (checked via `groups/{expenseId.groupId}`)
- Balance docs are write-locked to server (Cloud Functions only via Admin SDK)

---

## Scalability Limits & Mitigations

| Limit | Firestore ceiling | Our mitigation |
|-------|------------------|---------------|
| Doc size | 1 MB | `splits[]` capped at 50; `memberIds[]` capped at 50 |
| Write rate per doc | 1/sec sustained | `balances` updated by CF only; no client writes |
| `array-contains` index | Works at any scale | Used for `memberIds` — primary read pattern |
| Large groups (>100 members) | Reads get expensive | Phase 3: subcollection `group_members` + server-side pagination |
| Cross-group activity feed | N Firestore listeners | Acceptable up to ~20 groups; Phase 2: denorm to `user_activity` collection |

---

## Data Flow

```
Client adds expense
  → ExpenseRepositoryImpl.addExpense() writes to expenses/{id}
  → Cloud Function triggers on expenses/{id} onCreate
      → Updates groups/{groupId}.totalExpenses (increment)
      → Recalculates and writes balances/{userId_groupId} for each member
      → Sends FCM push to all group members
  → All clients watching watchExpensesProvider(groupId) receive update
  → All clients watching watchBalancesProvider() receive updated balance
```

The current v1 does not have Cloud Functions deployed — `totalExpenses` and `balances` are stale until Phase 2. Balance reads still work via client-side calculation from expense splits.

---

## Phase 2 Cloud Functions (planned)

```
onExpenseWrite(groupId, expenseId)
  → recalculate balances (atomic transaction)
  → update groups.totalExpenses
  → send FCM push to group members

onGroupMemberAdd(groupId, userId)
  → copy user's displayName + avatar into group.memberDisplayNames

onUserProfileUpdate(userId)
  → fan-out updated displayName to all groups user is a member of

onInviteUsed(inviteId, userId)
  → add userId to group.memberIds (enforces maxUses + expiry)
```
