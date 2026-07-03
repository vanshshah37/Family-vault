# Phase 03 — Navigation & Application Layout

---

## Phase Status

**Status:** Not Started

**Previous Phase:** Phase 02 – Dashboard UI Foundation ✅

**Next Phase:** Phase 04 – Universal Entry System

---

# Objective

Transform the static Dashboard into a navigable application.

This phase introduces the permanent navigation architecture, application layout, and placeholder feature screens.

No database, business logic, providers, CRUD operations, or synchronization shall be implemented.

The goal is to establish the application's navigation backbone so every future feature integrates into an existing structure rather than replacing screens.

---

# Scope

## Included

- Navigation architecture
- Application routing
- Placeholder feature screens
- Search screen
- Category navigation
- Search button navigation
- Shared page layout
- Consistent AppBar styling
- Reusable placeholder page design
- Responsive navigation

---

## Explicitly Excluded

Do NOT implement:

- SQLite
- Local database
- CRUD
- Universal Entry
- Authentication
- Google Drive Sync
- Search functionality
- Search logic
- Business logic
- Providers
- Riverpod state
- Models
- Services
- Repositories
- File handling
- Encryption
- Documents management
- Settings
- Favorites
- Members
- Real statistics
- API integration

Every destination screen contains placeholder content only.

---

# Files To Modify

```
lib/features/home/home_screen.dart
```

---

# Files To Create

```
lib/navigation/app_router.dart

lib/features/personal/personal_screen.dart

lib/features/corporate/corporate_screen.dart

lib/features/share_market/share_market_screen.dart

lib/features/joint/joint_screen.dart

lib/features/documents/documents_screen.dart

lib/features/information/information_screen.dart

lib/features/search/search_screen.dart
```

No additional Dart files shall be created.

---

# Folder Structure Impact

```
lib/

navigation/
    app_router.dart

features/

    home/

    personal/

    corporate/

    share_market/

    joint/

    documents/

    information/

    search/
```

No existing folders shall be removed.

---

# Navigation Architecture

Use Flutter's built-in navigation.

```
Navigator

↓

MaterialPageRoute
```

No external routing packages.

Do NOT install:

- go_router
- auto_route
- beamer
- vrouter

---

# Widget Hierarchy

```
MaterialApp

↓

HomeScreen

↓

CategoryCard

↓

Navigator

↓

Feature Screen
```

Search button:

```
Search Icon

↓

Search Screen
```

---

# Dashboard Behaviour

Each CategoryCard shall navigate to its corresponding placeholder screen.

```
Personal

↓

Personal Screen
```

```
Corporate

↓

Corporate Screen
```

```
Share Market

↓

Share Market Screen
```

```
Joint

↓

Joint Screen
```

```
Documents

↓

Documents Screen
```

```
Information

↓

Information Screen
```

Floating Action Button remains unchanged.

```
onPressed: () {}
```

---

# Placeholder Screen Design

Every screen shall contain:

```
AppBar

↓

Large Icon

↓

Screen Title

↓

"Coming Soon"
```

No buttons.

No forms.

No cards.

No fake data.

No navigation except Back.

---

# Search Screen

Search icon shall navigate to:

```
Search Screen
```

Display:

```
Search

Coming Soon
```

No search field.

No logic.

No providers.

---

# Layout Rules

Every screen shall follow the Design System.

Required:

- Material 3
- Standard screen padding
- Consistent AppBar
- Consistent typography
- Theme colors only

No hardcoded colors.

---

# Technical Rules

Use:

- StatelessWidget wherever possible
- MaterialPageRoute
- Navigator.push()
- Theme values
- Reusable widgets

Avoid:

- Duplicate navigation code where practical
- Global variables
- Business logic
- Services
- Providers

---

# Acceptance Criteria

Phase is complete only if:

- Every category opens its screen
- Search icon opens Search screen
- Back navigation works correctly
- Dashboard remains unchanged visually
- Windows build succeeds
- Android build succeeds
- flutter analyze reports zero issues

---

# Testing Checklist

Verify:

- Dashboard launches
- Personal navigation
- Corporate navigation
- Share Market navigation
- Joint navigation
- Documents navigation
- Information navigation
- Search navigation
- Android Back button
- Windows Back button
- No navigation exceptions
- No overflow
- No analyzer warnings

---

# Risks

Potential risks:

- Duplicate navigation logic
- Inconsistent AppBars
- Hardcoded route creation
- Tight coupling between HomeScreen and destination pages

Avoid unnecessary complexity.

---

# Dependencies

Requires:

- Phase 01
- Phase 02

Blocks:

- Phase 04
- Phase 05

---

# Exit Criteria

Phase 03 is complete only when:

- Navigation works for every category
- Search navigation works
- Windows build verified
- Android build verified
- flutter analyze reports zero issues
- Git commit created
- Git push completed
- Documentation updated

---

# Architect Notes

This phase establishes the permanent navigation foundation of Family Vault.

Every future feature shall integrate into this navigation system.

No future phase should replace the Dashboard.

Instead, all functionality will be added behind the navigation structure created here.