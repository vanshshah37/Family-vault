# Phase 06 — SQLite & Persistence Foundation

---

## Phase Status

**Status:** Not Started

**Previous Phase:** Phase 05 – Dynamic Entry System ✅

**Next Phase:** Phase 07 – CRUD Engine

---

# Objective

Introduce local persistence using SQLite.

Connect the Dynamic Entry System to a local database without changing the UI.

The goal is to save and retrieve entries while keeping the architecture clean and reusable.

---

# Scope

## Included

- SQLite database initialization
- Database helper/service
- Entry model
- Save entry
- Load entries
- Auto-generated IDs
- Created timestamp
- Updated timestamp
- Repository pattern
- First persistence integration

---

## Explicitly Excluded

Do NOT implement:

- Update
- Delete
- Search
- Filtering
- Sorting
- Google Drive Sync
- Encryption
- Attachments
- Images
- Documents
- Export
- Import
- Favorites
- Authentication

---

# User Flow

Dashboard

↓

Universal Entry

↓

Dynamic Form

↓

Review

↓

Save

↓

SQLite

↓

Return Dashboard

---

# Files To Modify

```
lib/features/universal_entry/review_entry_screen.dart
```

---

# Files To Create

```
lib/database/database_service.dart

lib/database/database_constants.dart

lib/models/entry.dart

lib/repositories/entry_repository.dart
```

---

# Folder Structure

```
database/

    database_service.dart

    database_constants.dart

models/

    entry.dart

repositories/

    entry_repository.dart
```

---

# Database

Use:

- sqflite

Store:

- id
- category
- owner
- createdAt
- updatedAt
- data

The dynamic form values may be serialized as JSON.

---

# Repository

All database access must go through EntryRepository.

No UI screen may call SQLite directly.

---

# UI Rules

The UI created in previous phases must remain visually unchanged.

Only the Finish button gains real save functionality.

---

# Technical Rules

Use:

- Repository pattern
- Model class
- Constructor passing
- Async/await

Avoid:

- Raw SQL inside UI
- Global variables
- Business logic inside widgets

---

# Acceptance Criteria

- SQLite initializes successfully.
- Entries are saved.
- Entries can be loaded.
- Finish saves to database.
- UI unchanged.
- Windows build succeeds.
- Android build succeeds.
- flutter analyze reports zero issues.

---

# Testing Checklist

Verify:

- Database creation
- Insert
- Read
- Multiple entries
- App restart
- Data persists
- Android
- Windows
- No analyzer warnings

---

# Risks

- Database schema changes
- Serialization bugs
- Async errors

Keep the persistence layer isolated from the UI.

---

# Dependencies

Requires:

- Phase 01
- Phase 02
- Phase 03
- Phase 04
- Phase 05

Blocks:

- Phase 07

---

# Exit Criteria

Phase 06 is complete only when:

- Entries persist after app restart.
- Repository is used everywhere.
- UI remains unchanged.
- flutter analyze reports zero issues.
- Windows verified.
- Android verified.
- Git commit created.
- Git push completed.
- Documentation updated.

---

# Architect Notes

The UI must not know how SQLite works.

The repository is the only layer allowed to communicate with the database.

Future features such as Search, Edit, Delete, Sync, and Backup will all use this persistence layer.