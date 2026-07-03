# Phase 02 — Dashboard UI Foundation

---

## Phase Status

**Status:** Not Started

**Previous Phase:** Phase 01 – Project Initialization ✅

**Next Phase:** Phase 03 – Navigation & Application Layout

---

# Objective

Replace the temporary initialization screen with the first permanent Dashboard UI.

This phase establishes the visual foundation of the application.

No business logic, database integration, navigation, or backend functionality will be implemented.

The objective is to create a polished, modern, reusable dashboard layout that will remain the application's permanent home screen throughout future phases.

---

# Scope

## Included

- Permanent Dashboard UI
- Modern Material 3 interface
- Responsive layout
- Reusable UI widgets
- Statistics section
- Categories section
- Floating Action Button
- Dashboard welcome section
- Search icon in AppBar
- Approved color palette
- Proper spacing and padding
- Clean widget hierarchy

---

## Explicitly Excluded

Do NOT implement any of the following:

- SQLite
- Local database
- CRUD
- Universal Entry
- Google Drive Sync
- Authentication
- Search functionality
- Navigation
- Routes
- Providers
- Business logic
- File handling
- Documents
- Settings
- Favorites
- Member management
- Real statistics
- Real data
- Encryption
- API integration

Everything displayed must use placeholder values only.

---

# Files To Modify

```
lib/features/home/home_screen.dart
```

---

# Files To Create

```
lib/widgets/stat_card.dart

lib/widgets/category_card.dart

lib/widgets/dashboard_card.dart
```

No additional Dart files may be created.

---

# Folder Structure Impact

No folders shall be added or removed.

Existing project architecture remains unchanged.

Only the Widgets folder receives new reusable widgets.

---

# Widget Hierarchy

```
MaterialApp
│
└── HomeScreen
        │
        ├── AppBar
        │
        ├── DashboardCard
        │
        ├── Statistics Section
        │       │
        │       ├── StatCard
        │       ├── StatCard
        │       └── StatCard
        │
        ├── Categories Section
        │       │
        │       ├── CategoryCard
        │       ├── CategoryCard
        │       ├── CategoryCard
        │       ├── CategoryCard
        │       ├── CategoryCard
        │       └── CategoryCard
        │
        └── FloatingActionButton
```

---

# Dashboard Layout

AppBar

```
Family Vault                         🔍
```

No hamburger menu.

No profile button.

No settings button.

---

Welcome Card

Displays a welcome message.

Example:

```
Welcome

Manage your family's important information securely.
```

This is only visual.

No user personalization.

---

Statistics

Exactly three cards.

```
Accounts

Documents

Last Backup
```

Use placeholder values.

Example:

```
34

18

2 days ago
```

These values are static.

---

Categories

Exactly six cards.

```
Personal

Corporate

Share Market

Joint

Documents

Information
```

No additional categories.

No navigation.

No click behavior.

---

Floating Action Button

Location:

Bottom-right

Icon:

+

No action attached.

It will open Universal Entry in a future phase.

---

# UI Requirements

Must follow:

```
Material 3
```

Approved palette only:

```
Primary

#007979
```

```
Secondary

#24B1B1
```

```
Background

#FFF0E4
```

```
Cards

#FFE0C5
```

Design goals:

- Premium appearance
- Banking application feel
- Spacious layout
- Rounded corners
- Soft elevation
- Large touch targets
- Responsive sizing

No additional colors.

No gradients.

No animations.

No glassmorphism.

No custom fonts.

---

# Technical Rules

Must use:

- Stateless widgets where possible
- Theme values from AppTheme
- Reusable widgets
- Clean separation of UI

Do NOT duplicate UI code.

No business logic.

No providers.

No controllers.

No services.

No repositories.

No models.

No database calls.

---

# Placeholder Data

Statistics

```
Accounts

34
```

```
Documents

18
```

```
Last Backup

2 days ago
```

Categories

```
Personal

Corporate

Share Market

Joint

Documents

Information
```

These values exist only for layout verification.

---

# Acceptance Criteria

The phase is complete only if:

- Dashboard replaces initialization screen
- UI matches approved design
- All widgets are reusable
- Theme is respected
- Placeholder values display correctly
- No runtime errors
- Windows build succeeds
- Android build succeeds

---

# Testing Checklist

Verify:

- Windows application launches
- Android application launches
- No overflow
- No RenderFlex errors
- Responsive resizing works
- Search icon visible
- Floating Action Button visible
- Theme applied correctly
- Placeholder cards visible
- No debug banner

---

# Risks

Potential risks:

- Widget duplication
- Inconsistent spacing
- Hardcoded colors
- Non-responsive layouts
- Tight coupling inside HomeScreen

These should be avoided.

---

# Dependencies

Requires completed:

- Phase 01

Blocks:

- Phase 03
- Phase 04
- Phase 05

---

# Exit Criteria

Phase 02 is considered complete only when:

- Dashboard UI fully implemented
- Windows build verified
- Android build verified
- `flutter analyze` reports no errors
- Git commit created
- Git push completed
- Documentation updated

---

## Architect Notes

This phase establishes the permanent visual identity of Family Vault.

All future features must integrate into this dashboard rather than replacing it.

The dashboard layout created in this phase becomes the long-term foundation for the application.