# Splitbo Design Reference

**Generated:** 2026-09-21  
**Sources:** `/docs/brand/marketing-assets/` (visual mockups), `/docs/research/competitive/` (Splitwise screenshots), all feature screen `.dart` files, `PRD.md`, `CLAUDE_CODE_REVIEW.md`

Read this document before touching any UI file. Each action item is numbered, scoped to a single file, and ready to execute without follow-up questions.

---

## 1. Brand Identity

### 1.1 Colors

| Token | Hex | Role |
|-------|-----|------|
| `backgroundDefault` | `#0A0A0A` | Screen background (use `context.colors.backgroundDefault`) |
| `surfaceRaised` | `#1A1A1A` | Cards, bottom sheets, modals (use `context.colors.surfaceRaised`) |
| `borderDefault` | `#2C2C2C` | Dividers, card borders |
| `brandPrimary` | `#C3FD00` | Primary CTAs, active tab, positive amounts, brand accent |
| `textPrimary` | `#FFFFFF` | Headlines, primary body text |
| `textSecondary` | `#9E9E9E` | Subtitles, timestamps, placeholder text |
| `textDisabled` | `#4A4A4A` | Disabled controls |
| Semantic positive | `#C3FD00` | "You get back" amounts |
| Semantic negative | `#FF6B6B` | "You owe" amounts (use this — not orange, not red) |
| Semantic warning | `#FFB347` | Leave group / caution actions |

**Hard rule:** Never use `Colors.green`, `Colors.lightGreen`, `Color(0xFF1DB954)`, or any green variant other than `Color(0xFFC3FD00)`. This is guardrail G5.

### 1.2 Typography

**Font family:** Sora (confirmed from brand sheet `1000006200.jpg` and `1000006201.jpg`)

| Role | Weight | Size | Usage |
|------|--------|------|-------|
| Screen title / greeting headline | Bold (w800) | 26 px | "Good to see you, Vikas!" |
| Section header | Bold (w700) | 17–20 px | "Your Groups", "Recent Activity" |
| List item primary | SemiBold (w600) | 14–15 px | Group name, expense description |
| List item secondary | Regular (w400) | 12–13 px | Date, member count, subtitle |
| CTA button | Bold (w700) | 15–16 px | "Get Started", "New Expense" |
| Amount (featured) | ExtraBold (w800) | 28 px | Grand total in Totals tab |
| Amount (list) | Bold (w700) | 14–15 px | Per-row amounts |

The Sora font must be added to `pubspec.yaml` if not already present. Currently no explicit font declaration was found — all text falls back to system fonts.

### 1.3 Logo and Wordmark

- **Icon mark:** Z-slash with percent dot — neon green on black
- **Wordmark:** "Split" in white + "Bo" in `#C3FD00`, same weight and size
- **Tagline:** "Split bills. Keep friends." in `textSecondary`
- **App icon (dark):** Icon mark on pure black rounded square
- **App icon (light):** Icon mark on white square

The wordmark is already implemented correctly in `_SplitboAppBar` in `home_screen.dart` using `Text.rich`.

### 1.4 Component Standards

**Primary CTA button:**
```dart
SizedBox(
  height: 52,
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFC3FD00),
      foregroundColor: Colors.black,
      elevation: 0,
      shape: const StadiumBorder(),
    ),
    // ...
  ),
)
```

**Cards / list row containers:**
- Background: `colors.surfaceRaised` (`#1A1A1A`)
- Border radius: `14`
- Padding: `horizontal: 16, vertical: 13`
- Border: only on cards that need emphasis — `Border.all(color: colors.borderDefault)`

**Icon containers (action icons):**
- Size: 38–42 px
- Shape: circle or `BorderRadius.circular(10)` square
- Background: `colors.brandPrimary.withOpacity(0.12–0.15)`
- Icon color: `colors.brandPrimary`
- Icon size: 18–20 px

**SnackBars (guardrail G4 — mandatory):**
```dart
SnackBar(
  content: Text('message', style: TextStyle(color: Colors.white)),
  backgroundColor: Color(0xFF1E1E1E),
)
```

**Balance amounts:**
- Green `Color(0xFFC3FD00)` for "you get back" / positive net
- Red `Color(0xFFFF6B6B)` for "you owe" / negative net
- Never use plain white for financial amounts that carry direction

---

## 2. Competitive Analysis — What Splitwise Does Well

Based on direct screenshots in `/docs/research/competitive/` (WA0001–WA0022), all captured from Splitwise v26.8 on an Indian account (₹ denomination).

### 2.1 Home / Friends tab (WA0001, WA0016)
- **Overall balance banner at top:** "You are all settled up!" or "You are owed ₹X" with a filter icon — immediately answers the user's most important question without scrolling
- **Friends list as primary tab:** Each friend row shows running net balance (green = they owe, orange = you owe), not just a name
- **"Add friends" pill button** in app bar + search icon — two quick entry points

### 2.2 Add Expense flow (WA0002, WA0003, WA0004)
- **5 split method tabs** rendered as icon pill buttons (=, exact amount "1.23", %, bar-chart for shares, +/-) — visually distinct, not a dropdown
- **Running tracker** pinned at bottom of split screen: "₹30 of ₹3,000 · ₹2,970 left" — always visible so user knows their progress
- **Custom numpad** (not system keyboard) for amount entry — faster, no keyboard dismiss needed
- **"Choose payer"** is a separate minimal screen: just a member list with a single checkmark + "Multiple people" row at the bottom

### 2.3 Group Detail (WA0005, WA0008)
- **Cover photo extends behind status bar** — `extendBodyBehindAppBar: true`, title overlays the photo with blur/gradient
- **Horizontal scrolling tab bar** at natural content level: Settle up | Charts | Balances | Totals | Whiteboard | Export — users can always see there are more tabs
- **Empty state is actionable:** Not just "no expenses" — shows "Add members" primary button + "Share a link" secondary
- **"Add expense" extended FAB** in bottom-right, only on Expenses tab
- **Group type icons** (✈️ Trip, 🏠 Home, ❤️ Couple, 📋 Other) — set at creation, not just decorative

### 2.4 Activity Feed (WA0015)
- Sentence-format events: "Nikki added **Ooty day 1** in **South trip**." — not just an expense title
- Color-coded amount line below: "You get back ₹2,955.00" in green / "You owe ₹35.00" in orange
- Actor avatar overlaid bottom-right on the category icon thumbnail (dual-avatar treatment)
- Sticky "Add expense" FAB on this screen too

### 2.5 Account / Settings (WA0012, WA0013)
- Preferences section with divider: Notifications → Security → Appearance
- Help & Support section: Help center, Contact us, Rate app
- Clean log-out button (just text, no icon, centered)
- Security page: single "Authenticate with Face ID" toggle — no clutter
- Pro upsell (WA0006): charts, unlimited expenses, currency conversion, receipt itemization are all Pro-locked in Splitwise. **Splitbo ships all of these free** — this is the core brand differentiation to highlight

---

## 3. Screen-by-Screen Design Spec

### 3.1 Sign-In Screen
**File:** `packages/features/auth/lib/src/sign_in_screen.dart`

**What currently exists:**
- Black background, SplitBo logo + tagline, stacked animated expense cards, "Get Started" green button, "Sign In" text link — both call `_signIn()` (Google OAuth)

**What the approved mockup shows (`UI/login/1000006173.jpg`, `1000006194.jpg`):**
- Logo centered, tagline below, animated stacked expense cards as the visual hero, "Share expenses, not stress." body copy, full-width green "Get Started" button, "Sign In" text link below in green, optional "Skip" link at top-right

**Gaps:**
1. Both "Get Started" and "Sign In" currently call the same `_signIn()`. The mockup implies they're distinct paths (new user vs returning), but since the only auth method is Google, they can call the same function — however the visual hierarchy must make "Get Started" the primary and "Sign In" clearly secondary (smaller, text-only, brand green color — already done).
2. The SnackBar in `_signIn()` uses raw `backgroundColor: _surface` instead of `Color(0xFF1E1E1E)`. These are the same value (`_surface = Color(0xFF1A1A1A)`), but use `Color(0xFF1E1E1E)` per guardrail G4 for SnackBars specifically.
3. No "Skip" / guest mode button. Per PRD this is not required for MVP.

**Action items:**
1. In `sign_in_screen.dart` line 29: change `backgroundColor: _surface` to `backgroundColor: const Color(0xFF1E1E1E)` and add `style: const TextStyle(color: Colors.white)` to the `Text(err.message)` inside the SnackBar content. This fixes the G4 guardrail violation.

---

### 3.2 Home Screen
**File:** `packages/features/balances/lib/src/home_screen.dart`

**What currently exists:**
- Greeting "Hi [name]! 👋" (plain text, both words same color)
- 3 `_ActionRow` list tiles stacked: Add Expense, Add Friend, Settle Up
- Large green "+ New Expense" pill button
- "Recent Groups" section header with "See all" link
- Up to 3 `_RecentGroupRow` cards (emoji avatar + group name + member count/total)

**What the approved mockup shows (two variants):**

*Variant A — `UI/home/1000006199.jpg`* (preferred, matches current ActionRow pattern):
- Greeting: "Good to see you, Vikas!" (name in brand green `#C3FD00`)
- Subtitle: "Split. Track. Settle. Repeat."
- 3 large action rows: "Split a Bill / Share expenses instantly", "Add Expense / Keep track together", "Settle Up / Close your balances" — icon circle + title + subtitle + chevron (matches current `_ActionRow` structure closely)
- "Your Groups" with circular group photo thumbnails in a horizontal row (Goa Trip, Office Buddies, Flatmates, + New Group button)
- Bottom nav: Home | Expenses | Groups | Profile (4 tabs) + center "+" FAB

*Variant B — `UI/home/1000006204.jpg`* (more detailed):
- Greeting: "Good to see you again, Vikas!" with name in green
- 4-icon grid: "Split Bill" | "Add Expense" | "View Stats" | "Groups"
- Recent activity list showing expenses with balance context ("You owe ₹570", "All settled", "You get ₹410")
- Bottom nav: Home | Friends | + FAB | Activity | Profile (5 tabs)

**Decision:** Use Variant A layout with the balance context from Variant B. The 3-row action layout is already implemented — keep it, but add a 4th action row for "View Stats" (navigates to a group's Charts tab or a summary). The groups section should show circular thumbnails.

**Action items:**
2. In `home_screen.dart` lines 32–38, change the greeting `Text` widget from `'Hi $firstName! 👋'` to use `Text.rich` so the name appears in brand green:
   ```dart
   Text.rich(
     TextSpan(
       children: [
         TextSpan(
           text: 'Good to see you, ',
           style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary, height: 1.1),
         ),
         TextSpan(
           text: '$firstName!',
           style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.brandPrimary, height: 1.1),
         ),
       ],
     ),
   )
   ```

3. In `home_screen.dart` line 41, change subtitle from `'Split smarter. Live better.'` to `'Split. Track. Settle. Repeat.'` — matches the confirmed mockup copy.

4. In `home_screen.dart` line 57, change the "Add Friend" `_ActionRow` subtitle from `'Add someone to split expenses with'` to `'Share expenses instantly'` for the "Split a Bill" action, and change the icon from `Icons.person_add_outlined` to `Icons.people_outlined`, and the title to `'Split a Bill'`. (The "Add Friend" CTA is redundant on the home screen since a Friends tab handles friend management. Replace it with "Split a Bill" which is the most common first action for new users per the mockup.)

5. In `home_screen.dart`, replace the 3 `_RecentGroupRow` cards in the groups section with a horizontal `SizedBox(height: 100)` containing a `ListView.builder` (horizontal, `scrollDirection: Axis.horizontal`) of circular group thumbnails. Each thumbnail is 72 px wide, shows the emoji avatar from `_RecentGroupRow._avatar` in a circle, group name truncated to 1 line below it (max 8 chars), and taps to `context.push('/groups/${group.id}')`. Add a last item that is a dashed-border circle with `Icons.add` icon and label "New Group" that navigates to `/groups/new`. Sample structure:
   ```dart
   SizedBox(
     height: 100,
     child: ListView.builder(
       scrollDirection: Axis.horizontal,
       itemCount: recent.length + 1, // +1 for "New Group"
       itemBuilder: (context, index) {
         if (index == recent.length) return _NewGroupCircle();
         return _GroupCircle(group: recent[index]);
       },
     ),
   )
   ```
   Remove the old `_RecentGroupRow` build path for the groups section. Keep `_RecentGroupRow` class in the file for possible future re-use or delete it if not used elsewhere.

6. In `home_screen.dart`, add a 4th `_ActionRow` below the existing three (after the Settle Up row, before the `SizedBox(height: 20)`):
   ```dart
   _ActionRow(
     icon: Icons.bar_chart_rounded,
     title: 'View Stats',
     subtitle: 'See spending charts for your groups',
     onTap: () => context.go('/groups'),
   ),
   ```
   This navigates to groups where the user can then open a group's Charts tab. Update the title copy to reflect availability.

7. In `home_screen.dart`, add a net balance summary widget between the greeting subtitle and the first `_ActionRow`. Read from `balancesProvider` (or compute from `watchGroupsProvider` if the denormalized balance cache is not yet wired client-side). Show a single-line chip: if net > 0 show "You are owed ₹[X] overall" in green; if net < 0 show "You owe ₹[X] overall" in `Color(0xFFFF6B6B)`; if net == 0 show "All settled up 🎉" in `textSecondary`. Render as a `Container` with `surfaceRaised` background, `borderRadius: 10`, padding `horizontal: 14, vertical: 10`, with an icon on the left. If data is unavailable, show nothing (hide the widget, do not show an error).

---

### 3.3 Groups List Screen
**File:** Look up with `find . -name "groups_screen.dart" -o -name "groups_list_screen.dart"` from the repo root — not yet read but exists under `packages/features/groups/`.

**What the approved mockup shows (`UI/groups/1000006197.jpg`):**
- AppBar: settings gear icon top-right (no title text, just gear)
- Hero area: SplitBo icon + "SplitBo" wordmark + tagline centered
- Large full-width green "Create a Group" button with `+` icon
- "Your Groups" section header + "See all" link
- Group list rows: 52 px circular photo avatar | group name (bold) + member count (secondary) | total amount (bold) | chevron

**Competitor pattern (Splitwise):**
- Groups shown as list with cover photo thumbnails, member count, net balance amount (you owe / you're owed)

**Action items:**
8. In the groups list screen file, ensure the "Create a Group" button is the first element in the body (above the list), full-width, 52 px height, green pill button with `+ Create a Group` label. If a FAB is currently used, replace it with this inline button OR keep the FAB AND add the inline button as an empty-state CTA.

9. In the groups list screen, each `GroupCard` or list row should show:
   - Left: 52 px circle with group photo or emoji/letter avatar (matching `_RecentGroupRow` avatar logic)
   - Middle: Group name in `textPrimary` (w600, 15 px) + `X members` in `textSecondary` (12 px)
   - Right: Total amount in `brandPrimary` (w700, 15 px) + chevron in `textSecondary`
   - This matches both the mockup and the existing `_RecentGroupRow` widget — consolidate into one reusable `GroupListRow` widget used by both home and groups screens.

---

### 3.4 Group Detail Screen
**File:** `packages/features/groups/lib/src/group_detail_screen.dart`

**What currently exists:**
- LinkedIn-style cover (gradient banner + overlapping circle avatar) + tab bar with 5 tabs: Expenses | Charts | Balances | Totals | Whiteboard
- Expenses tab: list of `_ExpenseRow` cards (icon + description + "Xh ago · Category" + amount + more_vert)
- Charts tab: horizontal bar chart by category — implemented
- Balances tab: per-payer "paid / owes" list — member shown as "Member (uid truncated...)" — not display names
- Totals tab: grand total card + by-category breakdown
- Whiteboard tab: `_ComingSoon` placeholder

**What the approved mockup shows (`UI/group-detail/1000006193.jpg`, right device):**
- Cover with real group photo (hero image), group name + member count overlaid on photo
- Tab bar: Expenses | Balances (only 2 visible — others are scrollable off-screen)
- Expense rows: category icon | description (bold) + date (secondary, "DD Mon YYYY") + "Split among N" (secondary) | amount in green (right-aligned) | chevron

**Competitor pattern (Splitwise WA0005, WA0008):**
- Tab bar order: Settle up (action button) | Charts | Balances | Totals | Whiteboard | Export
- Cover photo extends fully behind status bar
- "Settle up" is an action button in the tab bar (not a tab), or a top-level FAB

**Action items:**
10. In `group_detail_screen.dart` inside `_ExpenseList.build()` (around line 1786), change the expense row subtitle from `'$when · ${e.category.label}'` to `'${_fmtDate(e.createdAt)} · Split among ${_splitCount(e)}'`. Add helper methods:
    ```dart
    String _fmtDate(DateTime dt) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
    int _splitCount(ExpenseEntity e) => e.splits?.length ?? group.memberCount;
    ```
    This matches the mockup exactly.

11. In `group_detail_screen.dart` `_BalancesTab.build()` (around line 1033), replace `'Member (${entry.key.substring(0, 6)}…)'` with a proper display name lookup. Add a `membersProvider` (or use `watchGroupsProvider` + `userProvider`) to resolve uid → displayName. If the lookup is not immediately available, fall back to `'${entry.key.substring(0, 6)}…'` but add a `TODO(balances-display-names)` comment so it's searchable.

12. In `group_detail_screen.dart`, implement the Whiteboard tab (currently `_ComingSoon`). Replace `const _ComingSoon(label: 'Whiteboard')` with a `_WhiteboardTab` widget that:
    - Shows a full-height `TextField` with `maxLines: null`, `expands: true`
    - Initial value from `group.whiteboard` (already a field on `GroupEntity`)
    - On change (debounced 800 ms), calls `ref.read(groupRepositoryProvider).updateGroup(groupId: group.id, whiteboard: newValue)`
    - Styling: `fillColor: Colors.black`, border `Colors.transparent`, text in white, hint "Write anything… shared grocery list, trip notes, reminders." in `textSecondary`
    - This satisfies PRD section 5.3 and resolves pending item P5 from `CLAUDE_CODE_REVIEW.md`.

13. In `group_detail_screen.dart`, add a "Settle Up" floating action button or button row to the **Balances tab** (index 2). When there are outstanding balances, show a full-width green "Settle Up" pill button pinned at the bottom of the `_BalancesTab` `ListView`. On tap, call `context.push('/balances')` (the existing BalanceScreen route). This surfaces the settle-up CTA where users are most likely to act on it.

14. In `_GroupDetailBodyState`, reorder the tabs to match the competitor + mockup priority. Change:
    ```dart
    tabs: const [
      Tab(text: 'Expenses'),
      Tab(text: 'Balances'),   // moved from index 2 to index 1
      Tab(text: 'Charts'),     // moved from index 1 to index 2
      Tab(text: 'Totals'),
      Tab(text: 'Whiteboard'),
    ],
    ```
    And reorder the `TabBarView` children to match. Balances is more important than Charts for daily use. The FAB (`floatingActionButton`) is currently shown when `_tab.index == 0` — update condition to `_tab.index == 0` (still Expenses tab after reorder, no change needed in FAB logic).

---

### 3.5 Add Expense Screen
**File:** `packages/features/expenses/lib/src/add_expense_screen.dart`

**What currently exists:** Not fully read, but referenced extensively in `CLAUDE_CODE_REVIEW.md` — has split method UI, payer selection, receipt scan (OCR via Cloud Function per F4 fix).

**What the competitor does well (Splitwise WA0002, WA0003, WA0004):**
- 5 split method pill tabs rendered as icon buttons, not a dropdown
- Running tracker "₹X of ₹Y · ₹Z left" pinned at the bottom while entering amounts — always visible
- Custom numpad instead of system keyboard for the split amount entry
- "Choose payer" is a separate full-screen step, not an inline dropdown

**Action items:**
15. In `add_expense_screen.dart`, ensure the split method selector renders as 5 horizontally-scrolling pill/icon tabs, not a dropdown or radio group. The 5 icons (confirmed from Splitwise pattern, also referenced in PRD 5.4) are: equal (=), exact (1.23), percentage (%), shares (bars), adjustment (+/-). Each tab should be a `Container` with `borderRadius: 8`, `padding: 10`, selected state uses `brandPrimary` background with black icon, unselected uses `surfaceRaised` with `textSecondary` icon.

16. In `add_expense_screen.dart`, add a persistent running tracker row pinned above the keyboard/numpad during the split amount entry step. This row shows: `'₹${enteredTotal.toStringAsFixed(2)} of ₹${expense.amount.toStringAsFixed(2)}'` (in brand green) + `'  ·  ₹${remaining.toStringAsFixed(2)} left'` (in `textSecondary` if positive, `Color(0xFFFF6B6B)` if negative/over). This tracker exists in Splitwise and is essential UX — users need to know when they've fully allocated the amount.

---

### 3.6 Activity Screen
**File:** `packages/features/activity/lib/src/activity_screen.dart`

**What currently exists:**
- Derives activity from `watchExpensesProvider` across all groups — not from a dedicated `/activity` Firestore collection
- Renders each expense as a basic row: category icon + description + group name + amount
- Sorted by `createdAt` descending

**What the competitor does well (Splitwise WA0015):**
- Sentence-format text: "Nikki **added** "Ooty day 1" **in** "South trip"." — tells a story
- Color-coded amount line: "You get back ₹2,955.00" (green) or "You owe ₹35.00" (orange) — immediate financial context per item
- Actor avatar overlaid on the category icon (category icon is the bg, actor's profile photo circle overlaid bottom-right)
- Sticky "Add expense" FAB

**Action items:**
17. In `activity_screen.dart`, update `_ActivityFeed` to render each item in sentence format. Currently the `ListView.builder` at line 78 renders a generic expense row. Replace the item content with:
    - Top line: `Text.rich` — `'[paidBy display name] added '` (white w400) + `'"[description]"'` (white w600) + `' in '` (white w400) + `'"[groupName]"'` (white w600)
    - Second line: `'[DD Mon YYYY]'` in `textSecondary`
    - Third line (conditional): if `expense.paidBy == currentUserId`, show nothing OR "You paid ₹X"; if current user is in splits and `paidBy != currentUserId`, compute `splits[currentUserId] - (paidBy == currentUserId ? expense.amount : 0)` and show "You get back ₹[net]" in green or "You owe ₹[net]" in `Color(0xFFFF6B6B)`
    - Note: Full actor-name resolution requires the auth user's uid from `ref.watch(authStateProvider)`. The current user's uid is available via `ref.watch(authStateProvider).valueOrNull?.uid`.

18. In `activity_screen.dart`, add a `FloatingActionButton.extended` with brand green background and label "Add Expense" that calls `context.push('/expense/new')`. This matches Splitwise's pattern of keeping the add-expense CTA on every screen, and is what new users will look for on the Activity screen.

---

### 3.7 Settings / Profile Screen
**File:** `packages/features/settings/lib/src/settings_screen.dart`

**What currently exists (first 80 lines read):**
- AppBar title: "Profile"
- Profile avatar (88 px diameter) + edit pencil badge + user name/email displayed below

**What the competitor does well (Splitwise WA0012, WA0013):**
- Screen title: "Account" (not "Profile")
- User info section at top (avatar + name + email)
- **Preferences** section header + rows: Notifications → Security → Appearance
- **Help & Support** section header + rows: Help center → Contact us → Rate app
- Log out as a centered text button at the bottom (no section header)
- Security sub-screen: just a single "Authenticate with Face ID" toggle

**Action items:**
19. In `settings_screen.dart`, change the AppBar title from `'Profile'` to `'Account'` to match the competitor and PRD section 5.7.

20. In `settings_screen.dart`, ensure the settings rows below the profile header are grouped with section headers. The correct section structure is:
    ```
    [Profile header — avatar + name + email + edit tap]
    
    PREFERENCES
    - Notifications  →
    - Security       →  (Face ID toggle sub-screen)
    - Appearance     →  (Light / Dark / System — currently missing)
    - Default Currency →
    
    DATA
    - Export expenses →  (CSV export per PRD 5.7)
    
    HELP
    - Help Center    →
    - Rate Splitbo   →
    
    [Log out — centered text, textSecondary color, no icon]
    ```
    Add section header `Text` widgets styled as: `fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.8` with `UPPERCASE` text. Add 8 px top padding before each section.

21. In `settings_screen.dart`, add an "Appearance" settings row that navigates to a new `AppearanceScreen` (or shows an inline bottom sheet) with 3 options: Light, Dark, System — rendered as a segmented control with brand green for selected state. This resolves PRD section 5.7 requirement. Wire to `ThemeMode` via a Riverpod `StateProvider<ThemeMode>` stored in `SharedPreferences`.

22. In `settings_screen.dart`, confirm the "Export expenses" row exists and calls the CSV export function. If missing, add it under the DATA section header. The export logic already exists in `group_detail_screen.dart` as `_exportCsv()` — extract it to a shared utility in `packages/core/` so both screens can call it.

---

### 3.8 Friends Screen (Not Yet Built)

**Status:** Marked as P4 in `CLAUDE_CODE_REVIEW.md` — "Not built". Required by PRD section 5.2.

**What the competitor does (Splitwise WA0016):**
- App bar: search icon (left) + "Add friends" pill button (right)
- "You are all settled up!" headline if all balanced
- Friends list: each row shows friend avatar + name + net balance (green = they owe, `Color(0xFFFF6B6B)` = you owe) + chevron
- "Add more friends" outlined button as a CTA below the list
- "Add expense" FAB bottom-right

**Action items:**
23. Create `packages/features/friends/lib/src/friends_screen.dart`. The screen must:
    - Use `Scaffold` with `backgroundColor: colors.backgroundDefault`
    - App bar with search `IconButton` + "Add Friends" as a pill `OutlinedButton` (border `brandPrimary`, text `brandPrimary`)
    - If friend list is empty: centered empty state with icon + "No friends yet" + "Add friends to start splitting" + green "Add Friends" primary button
    - If friend list is non-empty: headline "You are all settled up! 🎉" (green) or "You owe ₹X overall" / "You are owed ₹X overall" (color-coded)
    - `ListView` of friends: avatar circle + display name + net balance chip + chevron
    - Balance chip: "gets back ₹X" in `Color(0xFFC3FD00)` or "owes ₹X" in `Color(0xFFFF6B6B)`
    - `FloatingActionButton.extended` with "Add Expense" label + `Icons.receipt_long` icon, brand green

24. Register this screen in `app/lib/src/routing/app_router.dart` as `/friends` route, and ensure the bottom nav bar includes the Friends tab at index 0 (matching Splitwise's tab order: Friends | Groups | Activity | Account).

---

## 4. Design Principles

### 4.1 Layout Rules
- **Max 2 text elements per list row:** title (primary, bold) + subtitle (secondary, regular). Never put 3 lines of text in a list row.
- **Max 3 UI elements per horizontal row:** icon/avatar | content column | trailing (amount + chevron). Never exceed this.
- **Padding standard:** Screen-level horizontal padding is always `20`. Card internal padding is `horizontal: 16, vertical: 13`.
- **Spacing between cards in a list:** `bottom: 10` margin (not using `ListView` default `separatorBuilder`).
- **Bottom nav safe area:** All list `padding` bottom values for scrollable lists must be `100` minimum (56 px nav bar + 44 px safe area) to prevent content hiding under the nav bar.

### 4.2 Dark Theme Tokens
Always use design system tokens via `context.colors` rather than hardcoded hex values in feature screens. The only acceptable hardcoded colors are in screens that don't have design system access (e.g., `sign_in_screen.dart` which uses `const _green`, `const _bg`, `const _surface` — these match the token values and are acceptable until the screen is migrated to use `context.colors`).

| Token | Value | Notes |
|-------|-------|-------|
| `context.colors.backgroundDefault` | `#0A0A0A` | Screen scaffold bg |
| `context.colors.surfaceRaised` | `#1A1A1A` | Cards, sheets |
| `context.colors.borderDefault` | `#2C2C2C` | Card borders, dividers |
| `context.colors.brandPrimary` | `#C3FD00` | Accent, active, CTA |
| `context.colors.brandPrimaryLt` | Light green tint | Avatar bg for current user |
| `context.colors.brandPrimaryDk` | Dark green | Avatar initials on light bg |
| `context.colors.textPrimary` | `#FFFFFF` | Headlines, primary |
| `context.colors.textSecondary` | `#9E9E9E` | Subtitles, timestamps |
| `context.colors.textDisabled` | `#4A4A4A` | Disabled state |

**Hardcode only when a screen has no `context.colors` access and migration would be a large diff.** In all other cases, use tokens.

### 4.3 Interaction Rules
- **Tap targets:** All tappable rows must be at least 48 px tall (Flutter's default accessible hit area). Use `GestureDetector` wrapping a `Container` or use `InkWell` for ripple effects on lighter backgrounds.
- **Loading states:** Use `CircularProgressIndicator(color: colors.brandPrimary, strokeWidth: 2)` everywhere. No `LinearProgressIndicator` unless it's a step-by-step flow.
- **Empty states:** Every list must have an empty state widget. Minimum: centered icon (`textDisabled`, 36–40 px) + headline (`textPrimary`, 15 px) + subtitle (`textSecondary`, 13 px) + optional primary CTA button.
- **Error states:** Show `_EmptyState`-style widget with `Icons.wifi_off_rounded` or `Icons.error_outline`. Never show raw error strings to users; wrap them.
- **Modals / Bottom sheets:** Always use `DraggableScrollableSheet` for content that might overflow. Always include a drag handle (40×4 px `Container`, `textSecondary` 40% opacity, 12 px margin top). Always include a close `IconButton`.

### 4.4 Navigation Structure (Tab Bar)
The bottom navigation bar must have exactly these 4–5 tabs in this order, matching both the marketing mockup and the Splitwise pattern:

**4-tab version (current implementation):**
```
Home  |  Activity  |  Groups  |  Profile
```

**5-tab version (post-Friends-tab implementation — target state):**
```
Friends  |  Groups  |  [+ FAB center]  |  Activity  |  Account
```

The center FAB (brand green circle with white `+`) dismisses the tab bar visually and opens the Add Expense modal. This matches the mockup in `UI/groups/1000006197.jpg`.

---

## 5. Pending Implementation Queue

Priority order: P1 = blocking MVP quality, P5 = polish / future sprint.

| # | Priority | Screen | Change | File |
|---|----------|--------|--------|------|
| 1 | P1 | Sign-In | Fix SnackBar to use `Color(0xFF1E1E1E)` bg + white text (guardrail G4) | `packages/features/auth/lib/src/sign_in_screen.dart` |
| 2 | P1 | Home | Change greeting to `Text.rich` with name in `brandPrimary` green | `packages/features/balances/lib/src/home_screen.dart` |
| 3 | P1 | Home | Change subtitle to "Split. Track. Settle. Repeat." | `packages/features/balances/lib/src/home_screen.dart` |
| 4 | P1 | Home | Replace 2nd `_ActionRow` ("Add Friend") with "Split a Bill" (icon: `Icons.people_outlined`, subtitle: "Share expenses instantly") | `packages/features/balances/lib/src/home_screen.dart` |
| 5 | P1 | Group Detail | Reorder tabs: Expenses → Balances → Charts → Totals → Whiteboard | `packages/features/groups/lib/src/group_detail_screen.dart` |
| 6 | P1 | Group Detail | Change expense row subtitle from `'$when · $category'` to `'$formattedDate · Split among $N'` | `packages/features/groups/lib/src/group_detail_screen.dart` |
| 7 | P1 | Activity | Add "Add Expense" `FloatingActionButton.extended` (brand green) navigating to `/expense/new` | `packages/features/activity/lib/src/activity_screen.dart` |
| 8 | P1 | Settings | Change AppBar title from "Profile" to "Account" | `packages/features/settings/lib/src/settings_screen.dart` |
| 9 | P1 | Settings | Add section headers (PREFERENCES, DATA, HELP) with `fontSize: 12, letterSpacing: 0.8, UPPERCASE` | `packages/features/settings/lib/src/settings_screen.dart` |
| 10 | P2 | Home | Replace 3 `_RecentGroupRow` list cards with horizontal circular thumbnail row (72 px circles + "New Group" circle at end) | `packages/features/balances/lib/src/home_screen.dart` |
| 11 | P2 | Home | Add net balance summary chip between subtitle and action rows (reads from balance provider) | `packages/features/balances/lib/src/home_screen.dart` |
| 12 | P2 | Home | Add 4th `_ActionRow` — "View Stats" with `Icons.bar_chart_rounded` navigating to `/groups` | `packages/features/balances/lib/src/home_screen.dart` |
| 13 | P2 | Group Detail | Replace `_ComingSoon` Whiteboard tab with `TextField` (`maxLines: null`) writing to `group.whiteboard` via `updateGroup()` debounced 800 ms | `packages/features/groups/lib/src/group_detail_screen.dart` |
| 14 | P2 | Group Detail | Fix Balances tab member names — replace truncated uid with display name lookup | `packages/features/groups/lib/src/group_detail_screen.dart` |
| 15 | P2 | Group Detail | Add "Settle Up" green pill button pinned at bottom of Balances tab | `packages/features/groups/lib/src/group_detail_screen.dart` |
| 16 | P2 | Activity | Reformat feed items to sentence-format "Actor added X in Group" with color-coded "You get back / You owe" line | `packages/features/activity/lib/src/activity_screen.dart` |
| 17 | P2 | Settings | Add "Appearance" row navigating to Light/Dark/System segmented control sub-screen | `packages/features/settings/lib/src/settings_screen.dart` |
| 18 | P2 | Add Expense | Ensure split method selector renders as 5 icon pill tabs, not dropdown | `packages/features/expenses/lib/src/add_expense_screen.dart` |
| 19 | P2 | Add Expense | Add persistent "₹X of ₹Y · ₹Z left" tracker pinned above keyboard during split entry | `packages/features/expenses/lib/src/add_expense_screen.dart` |
| 20 | P3 | Friends | Build `FriendsScreen` with friend list, balance per friend (green/red), "Add Friends" app bar button, "Add Expense" FAB | Create `packages/features/friends/lib/src/friends_screen.dart` |
| 21 | P3 | Friends | Register `/friends` route in router and add Friends as first bottom nav tab | `app/lib/src/routing/app_router.dart` |
| 22 | P3 | Groups List | Add large green "Create a Group" button at top of screen (above group list, below any hero area) | Groups list screen file (locate with: `find packages/features/groups -name "*.dart"`) |
| 23 | P3 | Settings | Add "Export expenses" row under DATA section (reuse `_exportCsv` logic from group detail) | `packages/features/settings/lib/src/settings_screen.dart` |
| 24 | P4 | Sign-In | Add email/password sign-in form as secondary option below Google sign-in (per PRD 5.1) | `packages/features/auth/lib/src/sign_in_screen.dart` |
| 25 | P4 | Sign-In | Add phone OTP option (per PRD 5.1 — India-first) | `packages/features/auth/lib/src/sign_in_screen.dart` |
| 26 | P4 | Settings | Add "Security" row with Face ID / biometric toggle sub-screen (one `Switch` tile, matches Splitwise pattern) | `packages/features/settings/lib/src/settings_screen.dart` |
| 27 | P5 | Home | Migrate remaining `Colors.black` usages in `sign_in_screen.dart` and `group_detail_screen.dart` to `context.colors.backgroundDefault` (or `const Color(0xFF0A0A0A)`) for token consistency | `packages/features/auth/lib/src/sign_in_screen.dart`, `packages/features/groups/lib/src/group_detail_screen.dart` |
| 28 | P5 | All | Add Sora font to `pubspec.yaml` and apply via `ThemeData.fontFamily: 'Sora'` — currently all screens fall back to system font | `app/pubspec.yaml`, `app/lib/src/app.dart` or equivalent theme file |

---

## 6. Asset Inventory

### Brand Image Files Referenced

| File | Content |
|------|---------|
| `docs/brand/marketing-assets/UI/home/1000006170.jpg` | Home screen mockup v1 — 2×2 icon grid layout |
| `docs/brand/marketing-assets/UI/home/1000006199.jpg` | Home screen mockup v2 — 3 action rows + circular group thumbnails |
| `docs/brand/marketing-assets/UI/home/1000006204.jpg` | Home screen mockup v3 — 4-icon grid + activity list with balance context |
| `docs/brand/marketing-assets/UI/login/1000006173.jpg` | Sign-in screen mockup — confirmed current implementation matches |
| `docs/brand/marketing-assets/UI/login/1000006194.jpg` | Sign-in screen mockup alternate angle |
| `docs/brand/marketing-assets/UI/groups/1000006197.jpg` | Groups list screen mockup — circular thumbnails, "Create a Group" button |
| `docs/brand/marketing-assets/UI/group-detail/1000006193.jpg` | Group detail mockup — Expenses + Balances tabs, expense rows with "Split among N" |
| `docs/brand/marketing-assets/UI/brand-sheets/1000006200.jpg` | Official brand sheet v1 — colors, typography, logo variants, app icon |
| `docs/brand/marketing-assets/UI/brand-sheets/1000006201.jpg` | Official brand sheet v2 — iconography set, wordmark, UI concept |
| `docs/brand/marketing-assets/Logo/` | 20+ logo variants for all use cases |

### Competitor Screenshots (Splitwise v26.8, Indian account)

| File range | Screens captured |
|------------|-----------------|
| WA0001 | Splitwise onboarding — overall balance + group list |
| WA0002 | Split options — 5 method tabs + running tracker + custom numpad |
| WA0003 | Enter paid amounts — minimal screen with tracker |
| WA0004 | Choose payer — member list with checkmark |
| WA0005 | Group detail (Trip Jaipur) — empty state with "Start adding expenses" |
| WA0006 | Splitwise Pro upsell — ₹1,399/yr paywall (Splitbo ships these free) |
| WA0007 | Group detail — another empty state variant |
| WA0008 | Group detail — Totals/Whiteboard/Export tabs |
| WA0009 | Group detail or expense list |
| WA0010 | Create group — name field + type selector (Trip/Home/Couple/Other) + photo picker |
| WA0011 | Add expense form |
| WA0012 | Account screen — Preferences + Help sections + Log out |
| WA0013 | Security settings — Face ID toggle only |
| WA0014 | Notifications settings |
| WA0015 | Activity feed — sentence format + color-coded amounts |
| WA0016 | Friends list — settled state + "Add more friends" |
| WA0017–WA0022 | Additional detail screens, duplicate angles |

---

## 7. Architectural Notes Relevant to UI

- **No `@riverpod` code-gen** (guardrail G2). All providers are manually written `Provider<T>`. Do not add `@riverpod` annotations.
- **`dbPrefix` on all Firestore reads/writes** (guardrail G3). Every new provider or repository method must use `'${dbPrefix}collectionName'`.
- **`context.colors` access pattern:** Feature screens use `final colors = context.colors;` at the top of `build()`. This is the correct pattern for design token access.
- **No credentials in Dart source** (guardrail G6). The Gemini API key was already moved to Cloud Functions (F4). Do not add any new API keys to client code.
- **`group_detail_screen.dart` is 2235 lines** — it is a large file. When adding the Whiteboard implementation (item 13 above), keep the `_WhiteboardTab` class in this file for co-location, but consider extracting Charts/Balances/Totals into separate files if the file grows past 2500 lines.
