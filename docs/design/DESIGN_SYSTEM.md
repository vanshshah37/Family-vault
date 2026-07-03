# Family Vault — Design System

Version: 1.0

Status: Active

Last Updated: Phase 02

---

# Purpose

This document defines the permanent visual language of Family Vault.

Every UI component, screen, and widget must follow this document.

No visual decisions should be made independently unless this document is updated first.

---

# Design Philosophy

Family Vault is designed to feel like:

- Premium
- Clean
- Modern
- Trustworthy
- Calm
- Professional

The application should resemble a modern banking or finance application rather than a traditional CRUD application.

Avoid visual clutter.

Whitespace is considered a design element.

---

# Design Principles

1. Simplicity over decoration.
2. Readability over density.
3. Consistency over creativity.
4. Reusable components first.
5. Responsive by default.
6. Material 3 foundation.
7. Accessibility friendly.

---

# Color Palette

## Primary

```
#007979
```

Used for:

- Floating Action Button
- Active controls
- Primary icons
- Important highlights

---

## Secondary

```
#24B1B1
```

Used for:

- Selected states
- Secondary emphasis

---

## Background

```
#FFF0E4
```

Application background.

---

## Card Background

```
#FFE0C5
```

All dashboard cards.

---

## Text

Primary:

```
#222222
```

Secondary:

```
#555555
```

Disabled:

```
#999999
```

---

# Border Radius

Small

```
8 px
```

Medium

```
12 px
```

Large

```
16 px
```

Dashboard cards use:

```
16 px
```

Floating Action Button uses Flutter default circular shape.

---

# Elevation

Cards

```
2
```

Dialogs

```
4
```

FAB

Flutter Material default.

Avoid heavy shadows.

---

# Shadows

Soft shadows only.

Never use hard or dark shadows.

Opacity should remain below:

```
5%
```

---

# Typography

Application Font

Default Flutter font.

No custom fonts.

---

## Headings

Large

```
32
```

Medium

```
24
```

Small

```
20
```

Weight

```
Bold
```

---

## Body

Large

```
16
```

Normal

```
14
```

Small

```
12
```

---

# Icon Sizes

Small

```
20
```

Medium

```
24
```

Dashboard

```
32
```

Floating Action Button

Flutter default.

---

# Spacing System

Tiny

```
4 px
```

Small

```
8 px
```

Medium

```
12 px
```

Large

```
16 px
```

Extra Large

```
24 px
```

Section Gap

```
32 px
```

Never use arbitrary spacing values.

---

# Padding

Screen

```
16 px
```

Card

```
20 px
```

Button

```
16 px horizontal
12 px vertical
```

---

# Dashboard Layout

Order:

```
AppBar

↓

Welcome Card

↓

Statistics

↓

Categories

↓

Floating Action Button
```

Future additions:

```
Quick Actions

↓

Recent Entries

↓

Pinned Items
```

---

# Statistics Cards

Always exactly:

Icon

↓

Value

↓

Label

Centered vertically.

---

# Category Cards

Layout:

Icon

↓

Label

No subtitle.

Centered.

---

# Buttons

Primary

Filled.

Secondary

Outlined.

Danger

Red.

Never use text buttons for primary actions.

---

# Floating Action Button

Position

Bottom Right.

Icon

+

Purpose

Universal Entry.

Only one Floating Action Button exists in the application.

---

# App Bar

Left

Application Title.

Right

Search.

No hamburger menu.

No profile.

No settings.

---

# Responsive Rules

Phone

Single-column layout where appropriate.

Tablet

Two-column layouts when space allows.

Desktop

Adaptive layout.

Maximum content width:

```
1400 px
```

Content should remain centered on very wide displays.

---

# Animations

Fast.

Subtle.

Material motion.

No decorative animations.

No bouncing effects.

---

# Component Rules

Every repeated UI element must become a reusable widget.

No duplicate UI code.

Widgets must remain stateless unless state is required.

---

# Accessibility

Touch targets:

Minimum

```
48 x 48
```

Text contrast must remain readable.

Icons must always have meaning.

---

# Future Components

Reserved widgets:

- Search Bar
- Owner Card
- Member Card
- Document Tile
- Account Tile
- Settings Tile
- Recent Activity Card
- Backup Status Card

These should follow this design system.

---

# Modification Policy

This document is the single source of truth for UI.

Any future change to spacing, colors, typography, sizing, or layout must be updated here before implementation.

Claude (implementation) must follow this document exactly.

Any deviation requires explicit approval.