# Family Vault - UI Guidelines

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the complete visual design language for Family Vault.

Every screen, component, animation, spacing rule, and interaction shall follow these guidelines.

The application should feel like a modern premium productivity application rather than a traditional banking application.

---

# Design Philosophy

The application should be:

- Clean
- Minimal
- Professional
- Calm
- Fast
- Organized

Avoid visual clutter.

The interface should prioritize readability over decoration.

---

# Design Style

Use:

- Material Design 3
- Rounded corners
- Soft shadows
- Large touch targets
- Clean cards
- Consistent spacing
- Smooth animations

Avoid:

- Glassmorphism
- Heavy gradients
- Neon colors
- Excessive borders
- Fancy animations
- Cluttered screens

---

# Color Palette

Primary

#007979

Secondary

#24B1B1

Background

#FFF0E4

Cards

#FFE0C5

Text Primary

#1E1E1E

Text Secondary

#666666

Error

#D32F2F

Success

#2E7D32

Warning

#ED6C02

---

# Typography

Use Material 3 typography.

Text hierarchy:

App Title

↓

Page Title

↓

Section Title

↓

Body

↓

Caption

Maintain consistent font sizes across the application.

Do not introduce multiple font families.

---

# Border Radius

Cards

16dp

Buttons

12dp

Dialogs

20dp

Text Fields

12dp

Search Bar

24dp

Maintain consistent rounded corners.

---

# Elevation

Cards

Low elevation

Dialogs

Medium elevation

Buttons

Minimal elevation

Avoid excessive shadows.

---

# Icons

Use Material Symbols Rounded wherever available.

Fallback to Material Icons when necessary.

Maintain consistent icon sizes.

Examples:

Dashboard

Search

Person

Folder

Document

Settings

Delete

Edit

Sync

Favorite

Open

Copy

---

# Buttons

Primary Button

Filled

Uses Primary Color.

Secondary Button

Outlined.

Danger Button

Red.

Buttons should have:

- Icon (when useful)
- Clear label
- Consistent height

---

# Floating Action Button (FAB)

The application shall use a Floating Action Button (FAB) for primary create actions.

The FAB shall:

- Use the Primary Color.
- Display a Plus (+) icon.
- Appear at the bottom-right corner.
- Be available only on screens where creation is possible.

Examples:

- Add Owner
- Add Entry
- Add Document
- Add Credential
- Add Custom Field

Avoid placing multiple "Add" buttons throughout the interface.

---

# Cards

Cards are the primary UI component throughout the application.

Nearly all content shall be displayed inside cards instead of plain lists.

Cards should be interactive and provide subtle visual feedback when clicked.

Each card should contain:

- Title
- Subtitle
- Optional icon
- Optional action buttons

Cards should have:

- Rounded corners
- Soft shadow
- Comfortable padding

---

# Search

The application shall provide Global Search and Context Search.

Global Search:

- Available from the Dashboard.
- Searches the entire vault.

Context Search:

Available inside list screens such as:

- Accounts
- Documents
- Insurance
- Investments
- Important Dates
- Other

Features:

- Rounded Search Bar
- Search Icon
- Instant Results
- Clear Button

Search results shall update instantly while typing.

---

# Lists

Lists should:

- Scroll smoothly
- Use consistent spacing
- Support long press
- Support swipe actions where appropriate

---

# Forms

Input fields should have:

- Label
- Placeholder
- Validation
- Clear error messages

Password fields should include:

- Show / Hide toggle
- Copy button

---

# Dialogs

Dialogs should be used for:

- Delete Confirmation
- Restore Confirmation
- Sync Information
- Error Messages

Dialogs should remain simple.

---

# Navigation

The application shall not use:

- Bottom Navigation Bar
- Navigation Drawer (Hamburger Menu)

Primary Navigation Flow:

Dashboard

↓

Owner

↓

Category

↓

Entry List

↓

Entry Details

↓

Edit

Back navigation shall always return to the previous screen.

Navigation should remain simple, predictable and consistent throughout the application.

---

# Dashboard Layout

The Dashboard shall contain the following sections in order:

1. Application Header
2. Global Search Bar
3. Statistics Cards
4. Owners Section
5. Floating Action Button

The layout shall remain clean, spacious and easy to scan.

Statistics shall be displayed using cards.

Owner cards shall be displayed in a responsive grid layout.

The Dashboard shall avoid unnecessary scrolling on larger screens.

---

# Design Language

The application shall use a card-based interface throughout the entire application.

Navigation should feel similar to modern productivity applications rather than traditional banking software.

Information should be grouped into logical sections using cards instead of long forms or dense tables.

The interface should remain spacious, organized and visually calm.

---

# Owner Screen

The Owner screen shall display:

- Owner Name
- Search Bar
- Category Cards
- Floating Action Button

Categories shall be displayed as clickable cards.

Supported Categories:

- Accounts
- Documents
- Insurance
- Investments
- Important Dates
- Other

Cards shall automatically adapt to screen size.

The layout shall use a responsive grid instead of a vertical list.

---

# Entry List

Entries shall be displayed using cards instead of traditional list rows.

Each Entry Card shall display:

- Category Icon
- Entry Title
- Last Updated Date
- Favorite Indicator (if applicable)

Entry cards shall have:

- Rounded Corners
- Comfortable Padding
- Soft Shadow
- Click Animation

Search shall always remain visible at the top of the screen.

A Floating Action Button shall be available for creating new entries.

---

# Entry Details

Entry Details shall organize information into separate sections.

Recommended order:

1. General Information
2. Credentials
3. Custom Fields
4. Attachments
5. Notes

Each section shall be displayed inside its own card.

Credentials shall include:

- Show / Hide Button
- Copy Button

Custom Fields shall support:

- Add
- Edit
- Delete

Attachments shall support:

- Preview
- Replace
- Delete

The page shall remain clean and avoid displaying all information as one long form.

---

# Animations

Use subtle Material animations.

Examples:

- Card Fade In
- Smooth Page Transition
- Search Expansion
- Floating Action Button Press Animation
- Dialog Slide Animation

Animations should remain under 300 milliseconds.

Animations should enhance the user experience without becoming distracting.

---

# Responsive Design

The application shall adapt automatically to different screen sizes.

Mobile:

- Single-column layouts.
- Comfortable touch spacing.

Tablet:

- Two-column layouts where appropriate.

Desktop:

- Responsive grids.
- Wider cards.
- Hover effects on clickable components.

The visual identity shall remain consistent across all platforms.

---

# Accessibility

Use sufficient color contrast.

Touch targets should remain large.

Readable font sizes.

Icons should include labels where appropriate.

---

# Dark Mode

Version 1

Not Supported

Future Version

Supported

---

# Empty States

Every empty page should include:

- Illustration/Icon
- Helpful message
- Action Button

Example:

"No Accounts Found"

↓

Add Account

---

# Loading States

Use:

- Circular Progress Indicator
- Skeleton Loaders where appropriate

Avoid freezing the interface.

---

# Error States

Display:

- Friendly message
- Retry Button

Avoid technical error messages.

---

# Consistency Rules

Every screen should feel like part of the same application.

Spacing, colors, typography, icons, and navigation must remain consistent throughout the project.

---

# Change History

## Version 1.0

Initial UI Guidelines approved.