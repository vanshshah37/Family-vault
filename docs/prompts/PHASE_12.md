# Family Vault – Phase 12: Credential Management & UX Improvements

## Objective

Enhance the overall user experience of the Family Vault application by improving password management, usability, search, sorting, metadata, and UI polish. The goal is to make the application feel production-ready while keeping the feature set focused and avoiding unnecessary complexity.

Do not rewrite or refactor unrelated parts of the project. Modify only the files necessary to implement Phase 12.
---

# Features

## 1. Password Strength Indicator

### Description
Display a live password strength indicator while the user types or edits a password.

### Strength Levels
- 🟥 Weak
- 🟨 Medium
- 🟩 Strong

### Strength Factors
- Password length
- Uppercase letters
- Lowercase letters
- Numbers
- Special characters
- Repeated characters

### Requirements
- Update in real-time.
- Use a colored progress indicator with a text label.
- No external packages unless absolutely necessary.

---

## 2. Copy Improvements

Provide independent copy actions for:

- Username
- Password

### User Feedback

Display a Snackbar after copying.

Examples:

✓ Username copied

✓ Password copied

---

## 3. Show / Hide Password

### Requirements

- Eye icon for password visibility.
- Smooth visibility animation.
- Whenever the Add/Edit dialog or screen is reopened, the password must always start hidden.
- Visibility state must not persist between openings.

---

## 4. Password History (Last Password Only)

Instead of maintaining a full password history, only preserve the immediately previous password.

### Firestore Fields

- currentPassword
- previousPassword

### Update Logic

Whenever the password changes:

previousPassword = currentPassword

currentPassword = newPassword

### UI

Allow users to view:

- Current Password
- Previous Password

No timestamps or multiple historical entries are required.

---

## 5. Credential Metadata

Each credential should include:

- createdAt
- updatedAt
- updatedBy

### Display

Show information such as:

Last Updated:
Yesterday 8:45 PM

Updated By:
John

This is especially useful for shared family vaults.

---

## 6. Search

Provide instant search across:

- Website
- Username
- Notes

### Requirements

- Update results while typing.
- No search button required.
- Search should be case-insensitive.

---

## 7. Sorting

Provide sorting options:

- Recently Updated
- Recently Created
- Alphabetical (A–Z)
- Alphabetical (Z–A)

### Requirements

- Remember the last selected sorting option locally.
- Sorting should immediately update the displayed list.

---

## 8. Delete Confirmation

Before deleting a credential, display a confirmation dialog.

Example:

Delete Credential?

Google Account

This action cannot be undone.

[Cancel]    [Delete]

---

## 9. UX Improvements

### Empty States

Replace plain text with a polished empty state.

Example:

🔐

No passwords yet

Tap the + button to add your first credential.

---

### Loading

Improve loading indicators.

Use better loading UI where appropriate instead of basic circular indicators.

---

### Dialog Improvements

Improve:

- Padding
- Rounded corners
- Button alignment
- Typography
- Overall spacing

---

### Card Improvements

Improve credential cards:

- Better spacing
- Better typography
- Consistent icons
- Better touch feedback

---

### Animations

Use subtle animations for:

- Dialog opening
- Dialog closing
- Page transitions
- Password visibility toggle

Animations should be smooth but not excessive.

---

### Success Feedback

Display Snackbars after:

- Add
- Edit
- Delete
- Copy

Examples:

✓ Credential Added

✓ Credential Updated

✓ Credential Deleted

✓ Password Copied

---

# Firestore Changes

Each credential should support:

- previousPassword
- createdAt
- updatedAt
- updatedBy

Migration should safely handle older documents that do not yet contain these fields.

---

# Not Included

The following features are intentionally excluded from Phase 12:

- Password Generator
- Favorites
- Full Password History

---

# Deliverables

- Password Strength Indicator
- Copy Username
- Copy Password
- Password Visibility Toggle
- Previous Password Support
- Credential Metadata
- Instant Search
- Sorting
- Delete Confirmation
- UI Polish
- UX Improvements

---

# Acceptance Criteria

- Existing functionality remains fully operational.
- Shared vault functionality is unaffected.
- Firestore schema updated safely.
- Existing credentials remain compatible.
- No analyzer warnings.
- No runtime errors.
- Responsive UI on desktop and mobile.
- Production-ready code quality.