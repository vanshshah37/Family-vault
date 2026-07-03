# Family Vault - Master Development Rules

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the permanent development rules for the Family Vault project.

These rules are mandatory for every future implementation.

No implementation should violate these rules unless explicitly instructed.

---

# 1. General Rules

- Never redesign the application architecture.
- Never change approved requirements without permission.
- Never modify unrelated files.
- Never remove existing functionality.
- Never replace existing technologies without approval.
- Always maintain consistency throughout the project.

---

# 2. Development Philosophy

The project should prioritize:

- Simplicity
- Maintainability
- Readability
- Performance
- Stability

Complex solutions should only be used when clearly necessary.

---

# 3. Coding Standards

Generated code must:

- Follow Flutter best practices.
- Use Dart null safety.
- Be production-ready.
- Be modular.
- Be reusable.
- Be well structured.
- Avoid duplicate code.
- Use meaningful naming conventions.

Placeholder implementations should be avoided unless explicitly requested.

---

# 4. Scope Control

Implement only the requested functionality.

Do not add additional features without approval.

If a requirement is unclear, ask instead of assuming.

---

# 5. File Management

Only create files that are necessary.

Do not rename existing files.

Do not move files between folders.

Do not delete files unless instructed.

Keep the existing folder structure unchanged.

---

# 6. UI Consistency

Maintain the approved design language.

Do not introduce new colors.

Do not introduce new fonts.

Do not redesign existing screens.

Follow Material 3 guidelines.

Maintain consistent spacing, typography, buttons, icons and navigation.

---

# 7. Database Rules

Never modify the database schema without approval.

Never remove existing columns.

Never rename database tables.

Always create migrations when schema changes are required.

---

# 8. Performance Rules

Avoid unnecessary rebuilds.

Minimize database queries.

Keep scrolling smooth.

Avoid blocking the UI thread.

---

# 9. Error Handling

Handle all possible errors gracefully.

Avoid application crashes.

Display user-friendly error messages.

Never silently ignore errors.

---

# 10. Documentation

Every major class should include clear documentation.

Complex logic should include comments explaining why it exists.

Avoid unnecessary comments describing obvious code.

---

# 11. Dependencies

Do not introduce new packages unless necessary.

If a new dependency is required:

- Explain why.
- Explain alternatives.
- Explain advantages.

---

# 12. Git Rules

Every completed feature should represent a logical Git commit.

Generated code should be organized enough for clean commits.

---

# 13. Testing

Before considering any feature complete:

- Verify compile success.
- Verify navigation.
- Verify existing functionality.
- Verify no regressions.
- Verify imports.
- Verify null safety.

---

# 14. AI Responsibilities

The AI is responsible for:

- Implementing approved requirements.
- Following project architecture.
- Maintaining code quality.
- Preserving consistency.

The AI is NOT responsible for changing project direction.

Architecture decisions belong to the project specification.

---

# 15. Response Format

At the end of every implementation, always provide:

## Files Created

List every new file.

---

## Files Modified

List every modified file.

---

## Dependencies Added

List newly required packages.

If none:

"None"

---

## Setup Required

Describe any manual setup required.

If none:

"None"

---

## Verification Checklist

Confirm:

- Code compiles
- Navigation works
- Existing functionality preserved
- No unnecessary files created
- Requirements fully implemented

---

# 16. Project Goal

The objective is not only to generate code.

The objective is to produce a maintainable, production-quality application that remains consistent throughout development.

---

# 17. Implementation Boundaries

When implementing a requested feature:

- Do not partially implement unrelated future features.
- Do not leave TODO placeholders unless requested.
- Do not simplify requested functionality.
- Do not over-engineer simple requirements.
- Finish the requested scope completely before moving to another feature.

If implementation cannot be completed due to missing information, stop and explain exactly what information is required.

---