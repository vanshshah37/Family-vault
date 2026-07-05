# Phase 05 — Dynamic Entry System

---

## Phase Status

**Status:** Not Started

**Previous Phase:** Phase 04 – Universal Entry Framework ✅

**Next Phase:** Phase 06 – SQLite & Persistence

---

# Objective

Transform the Universal Entry wizard into a reusable dynamic entry engine.

Instead of ending at a placeholder confirmation screen, the wizard shall generate category-specific forms based on reusable form definitions.

This phase builds the complete UI framework for data entry.

No information shall be stored permanently.

---

# Scope

## Included

- Dynamic form engine
- Category-specific forms
- Form definitions
- Reusable field rendering
- Review screen
- Navigation updates
- Placeholder user input
- Stateless UI wherever possible

---

## Explicitly Excluded

Do NOT implement:

- SQLite
- CRUD
- Save functionality
- Local storage
- Validation
- Search
- Google Drive Sync
- Authentication
- Encryption
- File Picker
- Image Picker
- Attachments
- Providers
- Repositories
- Services

---

# User Flow

```
Dashboard

↓

+

↓

Universal Entry

↓

Category Selection

↓

Owner Selection

↓

Dynamic Entry Form

↓

Review Screen

↓

Finish

↓

Dashboard
```

Nothing is saved.

Finish only returns to Dashboard.

---

# Files To Modify

```
lib/navigation/app_router.dart

lib/features/universal_entry/owner_selection_screen.dart
```

---

# Files To Create

```
lib/core/models/form_field_definition.dart

lib/core/constants/form_definitions.dart

lib/features/universal_entry/dynamic_entry_screen.dart

lib/features/universal_entry/review_entry_screen.dart
```

No additional Dart files may be created without approval.

---

# Folder Structure

```
core/

    models/
        form_field_definition.dart

    constants/
        form_definitions.dart

features/

    universal_entry/

        dynamic_entry_screen.dart

        review_entry_screen.dart
```

---

# Form Engine

Each category shall map to a predefined list of fields.

Example:

Personal

```
Name

Email

Phone

Address
```

Corporate

```
Company Name

GST Number

Registration Number
```

Share Market

```
Broker

Demat Number

Trading Account
```

Joint

```
Primary Holder

Secondary Holder

Relationship
```

Documents

```
Document Name

Document Type

Issue Date
```

Information

```
Title

Description
```

---

# Field Types

Supported field types:

- Text
- Multiline Text
- Number
- Date

No dropdowns.

No file upload.

No image selection.

No custom widgets.

---

# Dynamic Rendering

The UI shall render fields dynamically from the form definitions.

Avoid hardcoding different forms.

One reusable rendering mechanism shall support every category.

---

# Review Screen

Display:

- Selected Category
- Selected Owner
- Entered Values

Buttons:

```
Back

Finish
```

Finish returns to Dashboard.

No save operation.

---

# Navigation Rules

Flow:

```
Owner Selection

↓

Dynamic Entry

↓

Review

↓

Dashboard
```

Use only:

- Navigator.push()
- Navigator.pop()

No routing packages.

---

# UI Requirements

Follow DESIGN_SYSTEM.md.

Requirements:

- Material 3
- Theme colors only
- Consistent spacing
- Standard padding
- Reusable widgets

No hardcoded colors.

---

# Technical Rules

Use:

- StatelessWidget wherever possible
- Lightweight UI models
- Shared constants
- Constructor parameter passing

Avoid:

- Business logic
- Global variables
- Services
- Providers
- Repository pattern

---

# Acceptance Criteria

Phase is complete only if:

- Dynamic form changes with category
- Review screen displays entered values
- Finish returns to Dashboard
- No persistence exists
- Windows build succeeds
- Android build succeeds
- flutter analyze reports zero issues

---

# Testing Checklist

Verify:

- Every category loads the correct fields
- Text entry works
- Navigation works
- Review screen displays data correctly
- Finish returns to Dashboard
- Android
- Windows
- No overflow
- No analyzer warnings

---

# Risks

Potential risks:

- Hardcoded form layouts
- Duplicate field definitions
- Tight coupling
- Future incompatibility with SQLite

Avoid unnecessary complexity.

---

# Dependencies

Requires:

- Phase 01
- Phase 02
- Phase 03
- Phase 04

Blocks:

- Phase 06

---

# Exit Criteria

Phase 05 is complete only when:

- Dynamic form engine works
- Review screen works
- Dashboard flow remains intact
- Windows verified
- Android verified
- flutter analyze reports zero issues
- Git commit created
- Git push completed
- Documentation updated

---

# Architect Notes

This phase introduces the reusable Dynamic Entry Engine.

Future phases will connect SQLite to this engine without changing the UI.

Every new category introduced in the future should only require adding a new form definition rather than creating an entirely new screen.