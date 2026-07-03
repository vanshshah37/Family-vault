# Family Vault - Folder Structure

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the official folder structure for the Family Vault project.

All future development shall follow this structure.

Folders shall not be reorganized unless this document is updated.

---

# Project Structure

family-vault/

├── docs/
│
├── app/
│
└── README.md

---

# Documentation Structure

docs/

├── architecture/
│
├── context/
│
├── design/
│
├── progress/
│
├── prompts/
│
├── research/
│
└── specifications/

---

# Flutter Application Structure

app/

├── android/
│
├── windows/
│
├── lib/
│
├── assets/
│
├── test/
│
├── pubspec.yaml
│
└── README.md

---

# Lib Structure

lib/

├── core/
│
├── features/
│
├── models/
│
├── repositories/
│
├── services/
│
├── database/
│
├── widgets/
│
├── theme/
│
├── navigation/
│
└── main.dart

---

# Core

Contains:

- Constants
- Utilities
- Shared Helpers
- Global Configurations

---

# Features

Each application feature lives inside this folder.

Example:

features/

authentication/

dashboard/

owners/

entries/

documents/

settings/

search/

sync/

---

# Models

Contains all data models.

Examples:

Owner

VaultEntry

Credential

Attachment

CustomField

Settings

SyncMetadata

---

# Repositories

Contains repository implementations.

Repositories communicate between:

Business Logic

↓

SQLite

↓

Google Drive

---

# Services

Contains application services.

Examples:

Authentication

Synchronization

Clipboard

File Management

Google Drive

Auto Lock

---

# Database

Contains:

SQLite

Migrations

Queries

Database Helpers

---

# Widgets

Reusable UI components.

Examples:

Buttons

Cards

Dialogs

Search Bar

Input Fields

---

# Theme

Contains:

Color Palette

Typography

Component Styling

Material Theme

---

# Navigation

Contains:

Routes

Navigation Helpers

Screen Transitions

---

# Assets

assets/

images/

icons/

fonts/

documents/

---

# Testing

test/

Contains:

Unit Tests

Widget Tests

Future Integration Tests

---

# Rules

Features should remain independent whenever possible.

Business logic should not exist inside UI widgets.

Reusable widgets should never contain feature-specific logic.

Database code should never appear inside UI.

Google Drive code should remain inside Services.

---

# Change History

## Version 1.0

Initial folder structure approved.