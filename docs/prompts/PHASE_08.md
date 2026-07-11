# Phase 08 — Dashboard Live Data

---

## Phase Status

Status: Not Started

Previous Phase:
Phase 07 — CRUD Engine ✅

Next Phase:
To be defined after Phase 08 completion.

---

# Objective

Replace the Dashboard's static placeholder statistics with real data loaded from the existing SQLite persistence layer.

The Dashboard must display live information derived from saved entries and automatically refresh after the user returns from create, edit, or delete flows.

The existing architecture, database schema, CRUD engine, navigation system, and Design System must remain intact.

---

# Scope

## Included

- Replace static Dashboard statistics with live SQLite-backed values.
- Display the total number of saved entries.
- Display the total number of entries in the Documents category.
- Display the most recently updated entry date/time.
- Refresh Dashboard data after returning from the Universal Entry creation flow.
- Refresh Dashboard data after returning from an Entry List flow where edit or delete operations may have occurred.
- Loading state.
- Empty-state handling.
- Error-state handling.
- Repository-based data access only.

---

## Explicitly Excluded

Do NOT implement:

- Search functionality.
- Filtering system.
- Sorting controls.
- Google Drive sync.
- Backup functionality.
- Authentication.
- Encryption.
- Image or file attachments.
- Import/export.
- Database migrations.
- Database schema changes.
- New dependencies.
- Riverpod state management.
- Global state.
- Background refresh.
- Real-time database listeners.
- Category count badges.
- Dashboard redesign.
- Animations.
- Custom transitions.

---

# Live Dashboard Statistics

The existing three placeholder statistics must become:

## 1. Total Entries

Label:

Accounts

Value:

Total number of all saved entries.

Example:

34

---

## 2. Documents

Label:

Documents

Value:

Total number of saved entries whose category is exactly:

Documents

Example:

18

---

## 3. Last Updated

Label:

Last Updated

Value:

The most recent `updatedAt` value among all saved entries.

Recommended display:

- Today
- Yesterday
- `dd/mm/yyyy`

If there are no saved entries:

Never

Do not display the old static placeholder:

2 days ago

Do not implement continuous relative-time updates.

---

# Existing Static Data Removal

Remove the hardcoded placeholder statistics from `HomeScreen`.

The following type of implementation must no longer be the source of Dashboard values:

```dart
static const List<_StatItem> _stats = [
  _StatItem(
    icon: Icons.account_balance_wallet_rounded,
    value: '34',
    label: 'Accounts',
  ),
  _StatItem(
    icon: Icons.description_rounded,
    value: '18',
    label: 'Documents',
  ),
  _StatItem(
    icon: Icons.cloud_done_rounded,
    value: '2 days ago',
    label: 'Last Backup',
  ),
];
```

The visual appearance of the existing `StatCard` widgets must remain unchanged.

---

# Files To Modify

Expected files:

- `lib/features/home/home_screen.dart`

Additional existing files may only be modified if analysis proves the modification is necessary for the approved Phase 08 scope.

Do not modify files merely for cleanup or refactoring.

---

# Files To Create

No new files are required by default.

If analysis determines that one small dedicated model/helper is architecturally justified, it must be explicitly proposed during the analysis phase before implementation.

Do not create new files without approval.

---

# Repository Usage

The Dashboard must access persistence through:

`EntryRepository`

The Dashboard must NOT:

- Import `DatabaseService`.
- Import `sqflite`.
- Execute raw SQL.
- Access the database directly.

For this phase, use the existing:

`loadEntries()`

Do NOT add repository methods such as:

- `getDashboardStatistics()`
- `countEntries()`
- `countEntriesByCategory()`
- `getLastUpdatedEntry()`

unless explicitly approved after analysis.

The expected implementation is:

`HomeScreen → EntryRepository.loadEntries() → calculate Dashboard values in memory`

This avoids unnecessary persistence-layer expansion for a small dataset at the current project stage.

---

# HomeScreen State

`HomeScreen` may be converted from:

`StatelessWidget`

to:

`StatefulWidget`

if required to support:

- asynchronous loading;
- refresh after navigation returns;
- loading state;
- error state.

Do not introduce Riverpod or any other state-management system for this phase.

Use local widget state only.

---

# Refresh Behaviour

## After Universal Entry Creation Flow

Current flow:

Dashboard

→ FAB

→ Universal Entry Wizard

→ Finish

→ Dashboard

When control returns to the Dashboard, live statistics must reload.

The Dashboard must reflect the newly saved entry without requiring an application restart.

---

## After Entry List / CRUD Flow

Current flow:

Dashboard

→ Category

→ Entry List

→ Entry Details

→ Edit or Delete

→ Back to Dashboard

When control returns to the Dashboard, live statistics must reload.

The Dashboard must reflect edits and deletions without requiring an application restart.

---

# Navigation

Existing navigation architecture must remain intact.

`AppRouter` may be adjusted only if required to allow the Dashboard to await navigation completion.

Do not introduce:

- Named routes.
- Routing packages.
- Global navigation keys.
- Custom transitions.

Continue using:

- `Navigator.push`
- `MaterialPageRoute`
- `Future` returned by navigation operations.

---

# Loading State

While Dashboard statistics are loading:

- Do not show fake placeholder values.
- Do not show stale hardcoded values.

Use a simple loading state consistent with the existing Design System.

Possible acceptable implementations:

- `CircularProgressIndicator`
- Temporary neutral stat values such as `—`

The implementation must not cause layout shifts or overflow.

---

# Empty State

If there are no entries:

- Accounts → `0`
- Documents → `0`
- Last Updated → `Never`

The Dashboard itself remains fully usable.

The FAB remains available.

Category cards remain available.

---

# Error State

If loading entries fails:

- Do not crash.
- Do not expose raw exception text.
- Keep the Dashboard usable.
- Show a simple user-friendly failure indication.
- Allow a later navigation return or rebuild to attempt loading again.

Do not add complex retry architecture.

---

# Date Logic

For the most recent update:

1. Load all entries.
2. Parse each `updatedAt` ISO8601 string.
3. Find the latest timestamp.
4. Format it for display.

Recommended output:

- Same local calendar day → `Today`
- Previous local calendar day → `Yesterday`
- Otherwise → `dd/mm/yyyy`
- No entries → `Never`

Do not add the `intl` package in this phase.

Use Dart's existing `DateTime` functionality.

---

# Widget Hierarchy

Expected hierarchy:

HomeScreen (StatefulWidget)

├── AppBar

│   ├── Title

│   └── Search Action

├── Scrollable Body

│   ├── DashboardCard

│   │   └── Welcome Content

│   ├── Statistics Section

│   │   ├── StatCard — Accounts

│   │   ├── StatCard — Documents

│   │   └── StatCard — Last Updated

│   └── Categories Grid

│       └── CategoryCard × 6

└── FloatingActionButton

    └── Universal Entry Flow

The visual structure from Phase 02 must remain unchanged.

---

# Data Flow

Dashboard opens

↓

HomeScreen requests entries from EntryRepository

↓

EntryRepository.loadEntries()

↓

List<Entry>

↓

HomeScreen calculates:

- Total entries
- Documents entries
- Latest updatedAt

↓

Existing StatCard widgets render live values

---

# Refresh Data Flow

Dashboard

↓

Open creation or CRUD flow

↓

Await navigation completion

↓

Return to Dashboard

↓

Reload entries

↓

Recalculate statistics

↓

Update UI

---

# Technical Rules

Continue using:

- Repository pattern.
- `EntryRepository`.
- Existing `Entry` model.
- Async/await.
- Constructor parameter passing.
- Existing Design System.
- Existing navigation architecture.

Avoid:

- Raw SQL in UI.
- Direct `DatabaseService` access from UI.
- Global variables.
- Riverpod.
- Provider.
- Streams.
- Database listeners.
- Premature abstraction.

---

# Architecture Rules

1. `EntryRepository` remains the persistence boundary.
2. `HomeScreen` may calculate simple derived statistics in memory.
3. Do not change the database schema.
4. Do not add new dependencies.
5. Do not redesign the Dashboard.
6. Do not duplicate existing widgets.
7. Keep Phase 08 focused only on live Dashboard data and refresh behaviour.

---

# Acceptance Criteria

Phase 08 is complete when:

- Dashboard Accounts value shows the actual total number of entries.
- Dashboard Documents value shows the actual number of Documents-category entries.
- Last Updated reflects the latest `updatedAt` timestamp.
- Empty database displays `0`, `0`, and `Never`.
- Creating an entry refreshes Dashboard statistics.
- Editing an entry refreshes Last Updated.
- Deleting an entry refreshes relevant counts.
- Dashboard remains usable during loading or failure.
- Existing Dashboard layout remains visually unchanged.
- Existing CRUD functionality remains intact.
- Existing Universal Entry flow remains intact.
- Windows works.
- Android works.
- `flutter analyze` reports zero issues.

---

# Testing Checklist

Verify:

1. Empty database:
   - Accounts = 0
   - Documents = 0
   - Last Updated = Never

2. Create one Personal entry:
   - Accounts increases by 1.
   - Documents remains unchanged.
   - Last Updated changes.

3. Create one Documents entry:
   - Accounts increases by 1.
   - Documents increases by 1.

4. Edit an existing entry:
   - Last Updated reflects the edit.

5. Delete a Personal entry:
   - Accounts decreases by 1.

6. Delete a Documents entry:
   - Accounts decreases by 1.
   - Documents decreases by 1.

7. Restart the app:
   - Statistics remain correct.

8. Test Windows.

9. Test Android.

10. Run:

`flutter analyze`

Expected:

`No issues found!`

---

# Risks

## 1. Dashboard not refreshing after navigation

If navigation is not awaited, statistics may remain stale until the app rebuilds.

## 2. Date parsing failure

Invalid `updatedAt` values could cause exceptions if parsing is not handled safely.

## 3. setState after dispose

Asynchronous loading must check `mounted` before updating state.

## 4. Duplicate loading

Poorly structured refresh logic could trigger unnecessary database reads.

## 5. Visual regression

Changing `HomeScreen` from stateless to stateful must not alter the approved Phase 02 layout.

---

# Dependencies

Requires:

- Phase 01 — Project Initialization
- Phase 02 — Dashboard UI
- Phase 03 — Navigation
- Phase 04 — Universal Entry Wizard
- Phase 05 — Dynamic Forms
- Phase 06 — SQLite Persistence
- Phase 07 — CRUD Engine

Blocks:

Future phases that depend on accurate live Dashboard data.

---

# Exit Criteria

Phase 08 is complete when:

- Live statistics are operational.
- Dashboard refresh works after create/edit/delete flows.
- Empty and error states work.
- No database schema changes were made.
- No new dependencies were added.
- CRUD remains fully operational.
- Universal Entry remains fully operational.
- Windows verified.
- Android verified.
- `flutter analyze` reports zero issues.
- Git commit created.
- Git push completed.

---

# Architect Notes

Keep this phase intentionally small.

The Dashboard does not need a dedicated state-management architecture yet.

For the current project scale, loading all entries and deriving three statistics in memory is acceptable and keeps the architecture simple.

Do not add repository query methods merely to optimize a dataset that is currently small.

Do not introduce Riverpod until application-wide shared state provides a real architectural benefit.

The Dashboard's existing visual design is already approved. Change data, not design.