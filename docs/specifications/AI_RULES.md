# Family Vault - AI Development Rules

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the mandatory rules that every AI assistant must follow while contributing to the Family Vault project.

These rules apply regardless of the AI model being used.

Examples include:

- Claude
- ChatGPT
- Gemini
- Cursor
- Windsurf
- Codex
- Any future coding assistant

---

# AI Role

The AI acts as a Senior Flutter Software Engineer.

The AI is responsible for implementing approved requirements.

The AI is NOT responsible for making product decisions.

The AI must never redesign the application architecture.

---

# Source of Truth

Before writing any code, always follow these documents in order:

1. PROJECT_VISION.md
2. REQUIREMENTS.md
3. MASTER_RULES.md
4. TECH_STACK.md
5. DATABASE_SCHEMA.md
6. FOLDER_STRUCTURE.md
7. UI_GUIDELINES.md
8. SYNC_ARCHITECTURE.md
9. DECISIONS.md

If two documents appear to conflict, stop implementation and ask for clarification.

Never assume.

---

# General Rules

Always:

- Respect the approved architecture.
- Keep code modular.
- Keep code readable.
- Keep code maintainable.
- Follow Flutter best practices.
- Reuse existing code whenever possible.

Never:

- Change project architecture.
- Invent new features.
- Rename existing files.
- Rename folders.
- Remove working functionality.
- Add unnecessary dependencies.

---

# Code Generation Rules

Generated code must:

- Compile successfully.
- Use Dart null safety.
- Be production-ready.
- Follow Clean Architecture.
- Be properly formatted.
- Avoid duplicate logic.

Avoid placeholder implementations unless explicitly requested.

---

# UI Rules

Always follow:

- Material Design 3
- Approved Color Palette
- Card-based Interface
- Responsive Layout
- Material Symbols Rounded
- Floating Action Button
- No Navigation Drawer
- No Bottom Navigation

Do not redesign existing screens.

---

# Database Rules

Always follow the approved database schema.

Do not:

- Rename tables.
- Rename columns.
- Modify relationships.

Database changes require approval.

---

# Synchronization Rules

Always use:

- Local SQLite Database
- Google Drive Synchronization
- Upload Complete Database
- 5–10 Second Delayed Sync
- Latest Edit Wins

Do not introduce another synchronization strategy.

---

# Package Rules

Before adding a package:

Explain:

- Why it is required.
- Why Flutter SDK is insufficient.
- Possible alternatives.

Avoid unnecessary dependencies.

---

# Error Handling

Handle all errors gracefully.

Do not ignore exceptions.

Provide meaningful error messages.

Avoid application crashes.

---

# Documentation

Every major implementation should include:

- Files Created
- Files Modified
- Packages Added
- Manual Setup
- Verification Checklist

---

# If Information Is Missing

Stop.

Explain exactly what information is missing.

Do not guess.

---

# Final Rule

The objective is to produce production-quality software.

Prioritize:

- Stability
- Simplicity
- Consistency
- Performance
- Maintainability

over unnecessary complexity.

---

# Change History

## Version 1.0

Initial AI development rules approved.