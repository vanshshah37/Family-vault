# Phase 09 — Universal Search & Category Filtering

---

## Phase Status

Status: Not Started

Previous Phase:
Phase 08 — Dashboard Live Data ✅

Next Phase:
To be defined after Phase 09 completion.

---

# Objective

Replace the existing Search placeholder screen with a functional universal search system that allows users to search across all locally stored entries and optionally narrow results by category.

Search must work entirely with the existing SQLite persistence layer and repository architecture.

The implementation must preserve all functionality completed in Phases 01–08, including:

- Dashboard.
- Universal Entry creation.
- Dynamic forms.
- SQLite persistence.
- Full CRUD.
- Live Dashboard statistics.
- Existing navigation.
- Existing Design System.

---

# Scope

## Included

- Replace the current placeholder `SearchScreen`.
- Load all saved entries through `EntryRepository`.
- Search across all saved entries.
- Case-insensitive text matching.
- Ignore leading and trailing whitespace in the search query.
- Search across:
  - category;
  - owner;
  - dynamic field names;
  - dynamic field values.
- Optional category filtering.
- Open `EntryDetailsScreen` from a search result.
- Refresh loaded entries after returning from Entry Details.
- Reflect edits immediately after returning.
- Remove deleted entries from results after returning.
- Loading state.
- Initial state.
- Empty database state.
- No-results state.
- Error state.
- Responsive layout for Windows and Android.

---

# Explicitly Excluded

Do NOT implement:

- SQLite Full-Text Search.
- Raw SQL search queries.
- New repository search methods.
- Database schema changes.
- Database migrations.
- New dependencies.
- Riverpod.
- Provider.
- Streams.
- Database listeners.
- Global search state.
- Search history.
- Recent searches.
- Search suggestions.
- Autocomplete.
- Fuzzy search.
- Typo correction.
- Ranking algorithms.
- Relevance scoring.
- Advanced filtering.
- Sorting controls.
- Date-range filtering.
- Owner filtering.
- Search persistence.
- Search analytics.
- Background search.
- Pagination.
- Infinite scrolling.
- Debouncing unless analysis proves it is necessary.
- Redesigning unrelated screens.

---

# Search Data Source

Search must use the existing:

`EntryRepository().loadEntries()`

Expected data flow:

SearchScreen

→ EntryRepository.loadEntries()

→ List<Entry>

→ In-memory search and filtering

Do NOT:

- Import `DatabaseService` into the Search UI.
- Import `sqflite` into the Search UI.
- Execute raw SQL from the Search UI.
- Add repository methods such as:
  - `searchEntries()`
  - `loadEntriesByCategory()`
  - `filterEntries()`

For the current project scale, loading entries once and filtering them in memory is acceptable.

---

# Searchable Data

Each entry must be searchable by:

## 1. Category

Examples:

- Personal
- Corporate
- Share Market
- Joint
- Documents
- Information

Example query:

`documents`

May match entries in the Documents category.

---

## 2. Owner

Examples:

- Primary Owner
- Secondary Owner

Example query:

`primary`

May match entries owned by Primary Owner.

---

## 3. Dynamic Field Names

Examples:

- Account Number
- Bank Name
- Document Name
- Document Type
- Issue Date
- Description

Example query:

`document name`

May match entries containing that field.

---

## 4. Dynamic Field Values

Examples:

- Aadhaar Card
- HDFC Bank
- 9876543210
- Passport
- Ahmedabad

Example query:

`aadhaar`

May match an entry whose dynamic field value contains `Aadhaar Card`.

---

# Matching Rules

Search matching must be:

- Case-insensitive.
- Substring-based.
- Whitespace-trimmed.

Examples:

Query:

`aadhaar`

Matches:

`Aadhaar Card`

Query:

`HDFC`

Matches:

`hdfc bank`

Query:

`  passport  `

Must behave as:

`passport`

No fuzzy matching is required.

No typo correction is required.

---

# Empty Query Behaviour

When the search query is empty:

- Do not display every saved entry automatically.
- Show a simple initial search prompt.

Recommended text:

`Search your saved information`

If a category filter is selected while the query remains empty, the implementation may display entries belonging to that category.

This behavior must be explicitly analyzed before implementation.

---

# Category Filtering

The Search screen may provide one category filter control with these options:

- All
- Personal
- Corporate
- Share Market
- Joint
- Documents
- Information

The filter must use the existing shared category source from:

`lib/core/constants/categories.dart`

Do not duplicate the six category definitions manually.

The `All` option may be defined locally within `SearchScreen`.

Filtering rules:

- `All` → no category restriction.
- Selected category → only entries from that category may appear.

If both a query and category filter are active:

An entry must:

1. Belong to the selected category.
2. Match the search query.

Example:

Query:

`aadhaar`

Filter:

`Documents`

Result:

Only Documents-category entries matching `aadhaar`.

---

# Search Result Presentation

Each result must provide enough information to identify the entry without exposing excessive detail.

Recommended information:

- Category.
- Owner.
- One useful preview value from dynamic fields.

Do not display every dynamic field directly in the result card.

Tapping a result must open:

`EntryDetailsScreen`

Existing Details/Edit/Delete functionality must be reused.

Do not duplicate Entry Details UI.

---

# Refresh After Details

Flow:

SearchScreen

→ Search Result

→ EntryDetailsScreen

→ Edit or Delete

→ Return to SearchScreen

When control returns to SearchScreen:

- Reload entries through `EntryRepository().loadEntries()`.
- Reapply the current search query.
- Reapply the current category filter.

Expected behavior after Edit:

- Updated values immediately affect search results.

Expected behavior after Delete:

- Deleted entry immediately disappears.

Do not reset the user's query or category filter after returning.

---

# Screen State

`SearchScreen` may be converted from `StatelessWidget` to `StatefulWidget`.

Use only local widget state.

Suggested state may include:

- All loaded entries.
- Filtered results.
- Current search query.
- Selected category.
- Loading status.
- Error status.

Do not introduce application-wide state management.

---

# Search Trigger Strategy

Search may update:

- on every `TextField.onChanged`, or
- through a Search button.

Preferred behavior:

Use `onChanged` for immediate local filtering because all data is already loaded in memory.

No debounce is required for the current expected dataset size.

Do not add timers or debounce packages unless analysis proves they are necessary.

---

# Initial State

Before the user enters a query:

Show:

`Search your saved information`

Do not show all entries by default when:

- query is empty; and
- category filter is `All`.

---

# Category-Only State

If:

- query is empty; and
- a specific category is selected;

show all entries from that selected category.

This makes the category filter independently useful.

---

# Empty Database State

If there are no saved entries:

Show a clear message such as:

`No saved entries yet`

The Search screen must remain stable and usable.

---

# No Results State

If entries exist but no entry matches the active query/filter:

Show:

`No matching entries found`

Do not treat this as an error.

---

# Loading State

While entries are loading:

Show a simple loading state consistent with the existing Design System.

A `CircularProgressIndicator` is acceptable.

Do not show stale or fake results.

---

# Error State

If loading entries fails:

- Do not crash.
- Do not expose raw exception text.
- Show a user-friendly message.
- Keep the Search screen stable.
- No complex retry architecture is required.

Suggested text:

`Could not load saved entries`

---

# Responsive Behaviour

The Search screen must work on:

- Android phones.
- Tablets.
- Windows desktop.

Requirements:

- No RenderFlex overflow.
- No clipped search field.
- No clipped filter controls.
- No buttons hidden behind Android system navigation.
- Use `SafeArea` where appropriate.
- Search results must remain readable at narrow and wide widths.

Do not redesign the entire application.

---

# Existing Files Expected To Be Modified

Expected:

- `lib/features/search/search_screen.dart`

Potentially:

- `lib/navigation/app_router.dart`

only if analysis proves navigation changes are necessary.

Do not modify other files without explicit architectural justification during analysis.

---

# New Files

No new files are required by default.

Do not create:

- Search repository.
- Search service.
- Search provider.
- Search controller.
- Search model.

unless analysis proves a new abstraction is genuinely necessary and it is explicitly approved before implementation.

For this phase, local SearchScreen logic is preferred.

---

# Navigation

Continue using the existing navigation architecture.

Search result:

SearchScreen

→ EntryDetailsScreen

→ Edit/Delete

→ SearchScreen

The Search screen should await the Details route so it can reload entries when control returns.

Do not introduce:

- Named routes.
- Routing packages.
- Global navigation keys.
- Custom transitions.

---

# Widget Hierarchy

Expected hierarchy:

SearchScreen (StatefulWidget)

├── Scaffold

│   ├── AppBar
│   │   └── Title: Search

│   └── SafeArea

│       └── Search Content

│           ├── Search TextField

│           ├── Category Filter

│           └── Main Content

│               ├── Loading State
│               │   └── CircularProgressIndicator

│               ├── Initial State
│               │   └── Search Prompt

│               ├── Empty Database State
│               │   └── Empty Message

│               ├── No Results State
│               │   └── No Results Message

│               ├── Error State
│               │   └── Error Message

│               └── Results List
│                   └── Search Result Item × N

---

# Data Flow

SearchScreen opens

↓

Load entries through EntryRepository

↓

Store entries locally

↓

User types query and/or selects category

↓

Normalize query

↓

Apply category restriction

↓

Search:

- category;
- owner;
- dynamic field names;
- dynamic field values.

↓

Render matching entries

---

# Refresh Flow

Search Result tapped

↓

Open existing EntryDetailsScreen

↓

User may:

- view;
- edit;
- delete.

↓

Return to SearchScreen

↓

Reload all entries

↓

Reapply existing query

↓

Reapply existing category filter

↓

Render current results

---

# Reuse Requirements

Must reuse:

- `EntryRepository`.
- `Entry` model.
- `EntryDetailsScreen`.
- Existing category constants.
- Existing Design System.
- Existing navigation patterns.

Do not duplicate:

- Entry Details screen.
- Category constants.
- CRUD logic.
- Database logic.
- Dynamic form logic.

---

# Technical Rules

Use:

- `StatefulWidget`.
- Local state.
- `async` / `await`.
- `EntryRepository().loadEntries()`.
- In-memory filtering.
- Existing `Entry` model.
- Existing category constants.
- `DateTime` only if needed.
- Existing Material widgets.

Avoid:

- Direct database access.
- Raw SQL.
- New dependencies.
- Global state.
- Riverpod.
- Provider.
- Streams.
- Search-specific persistence layer.
- Premature abstraction.

---

# Acceptance Criteria

Phase 09 is complete when:

- Search placeholder has been replaced by functional search.
- Search matches category.
- Search matches owner.
- Search matches dynamic field names.
- Search matches dynamic field values.
- Matching is case-insensitive.
- Matching is substring-based.
- Leading/trailing query whitespace is ignored.
- Category filtering works.
- Existing shared categories are reused.
- Empty query + All shows initial prompt.
- Empty query + specific category shows that category's entries.
- Empty database state works.
- No-results state works.
- Loading state works.
- Error state works.
- Search result opens existing Entry Details screen.
- Returning after edit refreshes results.
- Returning after delete removes deleted entry.
- Current query is preserved after returning.
- Current category filter is preserved after returning.
- No database schema changes.
- No new dependencies.
- Existing CRUD remains operational.
- Universal Entry remains operational.
- Dashboard remains operational.
- Windows works.
- Android works.
- `flutter analyze` reports zero issues.

---

# Testing Checklist

Verify:

1. Open Search with no entries:
   - Shows `No saved entries yet`.

2. With entries available, open Search with empty query and `All`:
   - Shows initial search prompt.

3. Search by category:
   - Example: `documents`.

4. Search by owner:
   - Example: `primary`.

5. Search by dynamic field name:
   - Example: `document name`.

6. Search by dynamic field value:
   - Example: `aadhaar`.

7. Search with different letter case:
   - `AADHAAR` must still match `Aadhaar Card`.

8. Search with surrounding spaces:
   - `  aadhaar  ` must behave as `aadhaar`.

9. Select a specific category with empty query:
   - All entries in that category appear.

10. Use query + category together:
    - Both restrictions apply.

11. Search for impossible text:
    - Shows `No matching entries found`.

12. Open a result:
    - Existing Entry Details screen opens.

13. Edit a result:
    - Return to Search.
    - Updated entry affects current results immediately.

14. Delete a result:
    - Return to Search.
    - Deleted result disappears immediately.

15. Confirm current query remains after Details/Edit/Delete.

16. Confirm selected category remains after Details/Edit/Delete.

17. Test narrow Android screen:
    - No overflow.
    - Search field visible.
    - Filter controls usable.
    - Results readable.

18. Test Windows desktop.

19. Restart app:
    - Search still works with persisted SQLite data.

20. Run:

`flutter analyze`

Expected:

`No issues found!`

---

# Risks

## 1. JSON decoding

Dynamic values are stored as JSON. Search logic must decode safely and must not crash if malformed stored data exists.

## 2. Search state lost after navigation

The query and category filter must remain in local state when returning from Details.

## 3. Deleted entry remains visible

Search data must reload after returning from Entry Details.

## 4. Edit changes whether an entry matches

After editing, the current query must be reapplied because an entry may newly match or stop matching.

## 5. Filter overflow on mobile

Displaying seven filter options horizontally could overflow narrow screens.

The analysis must determine an appropriate responsive Material control.

## 6. Excessive rebuilding

Filtering on each keystroke is acceptable for the current small dataset, but implementation should avoid unnecessary database reloads while typing.

## 7. Privacy exposure

Do not show every dynamic field in search result previews.

---

# Dependencies

Requires:

- Phase 01 — Project Initialization.
- Phase 02 — Dashboard UI.
- Phase 03 — Navigation.
- Phase 04 — Universal Entry Wizard.
- Phase 05 — Dynamic Forms.
- Phase 06 — SQLite Persistence.
- Phase 07 — CRUD Engine.
- Phase 08 — Dashboard Live Data.

---

# Exit Criteria

Phase 09 is complete when:

- Universal search works.
- Category filtering works.
- Search results open existing Details screen.
- Results refresh after edit/delete.
- Query and filter state are preserved during navigation.
- All loading/empty/error/no-results states work.
- Mobile responsiveness is verified.
- Windows is verified.
- Android is verified.
- No new dependencies were added.
- No database schema changes were made.
- `flutter analyze` reports zero issues.
- Git commit created.
- Git push completed.

---

# Architect Notes

Keep this phase intentionally local and simple.

The app currently has a small local SQLite dataset. Loading all entries once and filtering them in memory is the correct tradeoff at this stage.

Do not add SQL search queries, Full-Text Search, repository expansion, state-management infrastructure, or search-specific services prematurely.

Search should reuse the CRUD system rather than create parallel details/edit/delete flows.

The existing `SearchScreen` placeholder from Phase 03 should evolve into the real Search screen rather than introducing another screen.

Validation remains a known future requirement. Do not mix input validation into Phase 09.