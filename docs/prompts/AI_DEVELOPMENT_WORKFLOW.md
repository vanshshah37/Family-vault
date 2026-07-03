# Family Vault - Claude Development Workflow

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines how Claude shall participate in the development of Family Vault.

Claude is responsible for implementing the approved architecture.

Claude is NOT responsible for making architectural or product decisions.

All implementation must follow the project documentation.

---

# Source of Truth

Before implementing any feature, Claude shall use the following documents in order.

1. PROJECT_VISION.md

2. REQUIREMENTS.md

3. MASTER_RULES.md

4. TECH_STACK.md

5. DATABASE_SCHEMA.md

6. FOLDER_STRUCTURE.md

7. UI_GUIDELINES.md

8. SYNC_ARCHITECTURE.md

If any requirement conflicts with another document, implementation must stop and request clarification.

Claude shall never guess.

---

# Development Philosophy

Implement exactly what is requested.

Do not redesign the application.

Do not invent additional features.

Do not remove existing functionality.

Do not simplify requested functionality.

Do not over-engineer simple requirements.

---

# Before Writing Code

Claude shall first:

- Read the relevant project documents.
- Understand the requested feature.
- Identify affected files.
- Explain the implementation plan.

Only then begin implementation.

---

# During Development

Claude shall:

- Follow existing architecture.
- Reuse existing code whenever possible.
- Keep code modular.
- Keep functions small.
- Keep files organized.
- Follow Flutter best practices.

---

# File Rules

Claude shall never:

- Rename folders.
- Rename existing files.
- Delete unrelated files.
- Move files between folders.

Only modify files related to the requested feature.

---

# Dependency Rules

Before adding any package:

Claude must explain:

- Why it is required.
- Why Flutter SDK is insufficient.
- Any possible alternatives.

Avoid unnecessary dependencies.

---

# Response Format

Every implementation response shall end with:

## Objective Completed

Short summary of completed work.

---

## Files Created

List all newly created files.

---

## Files Modified

List all modified files.

---

## Packages Added

List newly added packages.

If none:

None

---

## Manual Steps

Describe any required manual setup.

If none:

None

---

## Verification Checklist

Confirm:

- Code compiles.
- Architecture respected.
- UI Guidelines followed.
- Database Schema followed.
- No unrelated files modified.

---

# Error Handling

If implementation cannot continue:

Claude shall stop.

Claude shall clearly explain:

- What information is missing.
- Why implementation cannot continue.

Claude shall never guess missing requirements.

---

# Code Quality

Generated code shall:

- Be production ready.
- Be readable.
- Be modular.
- Be maintainable.
- Avoid duplication.
- Follow null safety.
- Include meaningful naming.

---

# Commit Recommendation

At the end of each completed feature, Claude shall recommend a Git commit message.

Example:

Add dashboard statistics cards

or

Implement owner management

---

# Feature Completion

A feature is complete only when:

- UI is finished.
- Business logic is complete.
- Database integration is complete.
- Error handling is complete.
- Feature compiles successfully.

Partial implementations should be avoided unless explicitly requested.

---

# Long Conversations

If conversation context becomes limited:

Claude shall summarize:

- Completed work.
- Pending work.
- Current architecture.
- Modified files.
- Remaining implementation.

This summary shall be sufficient to continue development in a new conversation.

---

# Final Rule

Family Vault is a professional software project.

Every implementation should prioritize:

- Stability
- Simplicity
- Consistency
- Maintainability
- User Experience

over unnecessary complexity.

---

# Change History

## Version 1.0

Initial development workflow approved.