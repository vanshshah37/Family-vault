# Phase 07 — CRUD Engine

---

## Phase Status

Status: Not Started

Previous Phase:
Phase 06 — SQLite Persistence ✅

Next Phase:
Phase 08 — Dashboard Live Data

---

# Objective

Implement full CRUD operations for saved entries.

Users must be able to:

- View entries
- Open entries
- Edit entries
- Delete entries

The existing architecture must remain unchanged.

---

# Scope

## Included

- Entry List screen
- Entry Details screen
- Edit Entry
- Delete Entry
- Refresh after CRUD operations
- Repository integration

---

## Explicitly Excluded

Do NOT implement:

- Search
- Filters
- Sorting
- Google Drive Sync
- Encryption
- Images
- Documents
- Export
- Import
- Authentication
- Backup

---

# User Flow

Dashboard

↓

Category

↓

Entry List

↓

Entry Details

↓

Edit

↓

Save

OR

Delete

↓

Back to List

---

# Files To Modify

lib/navigation/app_router.dart

lib/features/home/home_screen.dart

lib/repositories/entry_repository.dart

---

# Files To Create

lib/features/entries/entry_list_screen.dart

lib/features/entries/entry_details_screen.dart

lib/features/entries/edit_entry_screen.dart

---

# Folder Structure

features/

    entries/

        entry_list_screen.dart

        entry_details_screen.dart

        edit_entry_screen.dart

---

# Repository

Add only:

Future<void> updateEntry(Entry entry)

Future<void> deleteEntry(int id)

No other repository methods.

---

# Database

Database schema remains unchanged.

Use the existing table.

No migrations.

---

# Navigation

Category selection should now open Entry List instead of a placeholder screen.

Entry List

↓

Entry Details

↓

Edit

Back

↓

Entry List

---

# UI Rules

Keep Design System unchanged.

No redesign.

No animations.

No custom transitions.

---

# Entry List

Display:

- Category
- Owner
- Created Date

Tap:

Open details.

---

# Entry Details

Display all stored fields.

Buttons:

- Edit
- Delete

---

# Edit

Reuse the dynamic form system.

Pre-fill existing values.

Save updates through EntryRepository.

---

# Delete

Confirmation dialog.

Delete permanently.

Return to Entry List.

---

# Technical Rules

Continue using:

Repository pattern

DatabaseService

Entry model

Constructor parameter passing

Async/await

Avoid:

Business logic inside widgets

Raw SQL inside UI

Global variables

---

# Acceptance Criteria

User can:

View entries

Edit entries

Delete entries

Refresh list

Windows works

Android works

flutter analyze has zero issues.

---

# Testing Checklist

Verify:

Multiple entries

Editing

Deleting

Persistence

Refresh

Windows

Android

Analyzer

---

# Risks

State refresh

Navigation stack

Edit serialization

Delete confirmation

---

# Dependencies

Requires:

Phase 01

Phase 02

Phase 03

Phase 04

Phase 05

Phase 06

Blocks:

Phase 08

---

# Exit Criteria

CRUD fully operational.

Analyzer clean.

Windows verified.

Android verified.

Git commit created.

Git push completed.

Documentation updated.

---

# Architect Notes

Do not duplicate the Dynamic Entry renderer.

Edit Entry must reuse the existing dynamic form system created in Phase 05.

Repository remains the only database access layer.

The Entry List becomes the foundation for future Search and Filtering.