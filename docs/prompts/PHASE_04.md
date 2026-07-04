# Phase 04 — Universal Entry Framework

---

## Phase Status

**Status:** Not Started

**Previous Phase:** Phase 03 – Navigation & Application Layout ✅

**Next Phase:** Phase 05 – Dynamic Entry Forms

---

# Objective

Build the Universal Entry navigation framework.

The Floating Action Button becomes functional and launches a guided entry workflow.

No information is saved.

No database is used.

No forms are implemented.

This phase only creates the reusable workflow that every future data entry will follow.

---

# Scope

## Included

- Universal Entry screen
- Category selection
- Owner selection (placeholder)
- Confirmation screen
- Navigation between steps
- Back navigation
- Shared layout

---

## Explicitly Excluded

Do NOT implement:

- SQLite
- CRUD
- Forms
- TextFields
- Validation
- Save functionality
- Search
- Authentication
- Providers
- Models
- Services
- Repositories
- Business logic
- Google Drive Sync

---

# User Flow

```
Dashboard

↓

+

↓

Universal Entry

↓

Choose Category

↓

Choose Owner

↓

Confirmation

↓

Back to Dashboard
```

---

# Files To Modify

```
lib/features/home/home_screen.dart

lib/navigation/app_router.dart
```

---

# Files To Create

```
lib/features/universal_entry/universal_entry_screen.dart

lib/features/universal_entry/category_selection_screen.dart

lib/features/universal_entry/owner_selection_screen.dart

lib/features/universal_entry/confirmation_screen.dart
```

No additional Dart files.

---

# Folder Structure

```
features/

    universal_entry/

        universal_entry_screen.dart

        category_selection_screen.dart

        owner_selection_screen.dart

        confirmation_screen.dart
```

---

# Navigation Rules

FAB

↓

Universal Entry

↓

Category

↓

Owner

↓

Confirmation

↓

Dashboard

Use only Navigator.push() and Navigator.pop().

No routing packages.

---

# Placeholder Data

Categories:

- Personal
- Corporate
- Share Market
- Joint
- Documents
- Information

Owners:

- Primary Owner
- Secondary Owner

These are temporary placeholders.

---

# UI Requirements

Follow DESIGN_SYSTEM.md.

Every screen shall include:

- AppBar
- Title
- Consistent spacing
- Material 3
- Theme colors only

No hardcoded colors.

---

# Technical Rules

Use StatelessWidget wherever possible.

No business logic.

No providers.

No models.

No persistence.

---

# Acceptance Criteria

- FAB opens Universal Entry.
- Category selection works.
- Owner selection works.
- Confirmation screen appears.
- Back navigation works.
- Dashboard remains unchanged.
- Windows build succeeds.
- Android build succeeds.
- flutter analyze reports zero issues.

---

# Testing Checklist

Verify:

- FAB navigation.
- Category navigation.
- Owner navigation.
- Confirmation navigation.
- Back navigation.
- Windows.
- Android.
- No overflow.
- No analyzer warnings.

---

# Risks

- Navigation duplication.
- Tight coupling.
- Future form integration.

Avoid unnecessary abstraction.

---

# Dependencies

Requires:

- Phase 01
- Phase 02
- Phase 03

Blocks:

- Phase 05

---

# Exit Criteria

Phase 04 is complete only when:

- Universal Entry workflow is functional.
- All placeholder screens navigate correctly.
- Windows verified.
- Android verified.
- flutter analyze clean.
- Git commit created.
- Git push completed.
- Documentation updated.

---

# Architect Notes

This phase builds the navigation framework only.

Future phases will attach dynamic forms and persistence without changing this navigation structure.