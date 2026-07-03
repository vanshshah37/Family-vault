# Family Vault - Technology Stack

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the official technology stack for the Family Vault project.

All future implementations must strictly follow this document.

Changing any technology requires updating this document first.

---

# 1. Application Framework

Framework:
- Flutter

Programming Language:
- Dart

Reason:
- Single codebase for Android and Windows.
- Excellent UI performance.
- Strong community support.
- Long-term maintainability.

---

# 2. Supported Platforms

Version 1 supports:

- Android
- Windows

Future versions may support:

- Linux
- macOS
- Web (Not Planned)

---

# 3. UI Framework

- Material Design 3

Requirements:

- Responsive Layout
- Modern UI
- Professional Appearance
- Smooth Animations
- Consistent Components

---

# 4. State Management

Official State Management:

- Riverpod

Reason:

- Simple
- Scalable
- Testable
- Modern Flutter standard

No other state management solution should be used.

---

# 5. Local Database

Database:

- SQLite

Reason:

- Reliable
- Offline-first
- Lightweight
- Well supported

---

# 6. Cloud Synchronization

Cloud Provider:

- Google Drive

Purpose:

- Backup
- Synchronization

Synchronization Strategy:

- Every modification is saved immediately to the local SQLite database.
- Changes are marked as Pending Sync.
- The application waits approximately 5–10 seconds before attempting synchronization.
- Multiple changes are combined into a single synchronization operation.
- Synchronization always occurs in the background.
- If synchronization fails, changes remain safely stored locally and are retried automatically when internet connectivity is restored.

Each device shall authenticate using the owner's own Google account.

Synchronization shall only occur between devices signed in with the same Google account.

Google Drive shall never be used as a database.

The application shall always operate using the local SQLite database.

---

# 7. Local Storage

Use flutter_secure_storage for:

- Master Password
- Security-related settings

Use SQLite for:

- Accounts
- Documents
- Categories
- Owners
- Notes
- Custom Fields
- Settings
- Sync Metadata

---

# 8. File Storage

Supported Files:

- PDF
- PNG
- JPG
- JPEG

Documents will be stored locally.

Google Drive will synchronize them automatically.

---

# 9. Networking

Networking will only be used for:

- Google Drive Authentication
- Google Drive Synchronization

The application shall never depend on a dedicated backend server.

---

# 10. Architecture Pattern

Architecture:

Clean Architecture

Layers:

Presentation

↓

Business Logic

↓

Repository

↓

Data Source

↓

SQLite / Google Drive

Responsibilities:

Presentation Layer

- UI
- Navigation
- User Interaction

Business Layer

- Validation
- Business Rules

Repository Layer

- Communication between UI and Data

Data Layer

- SQLite
- Google Drive

---

# 11. Dependency Management

Packages should only be added when necessary.

Every package must satisfy:

- Well maintained
- Stable
- Popular
- Production ready

Avoid unnecessary dependencies.

---

# 12. Logging

Version 1:

- Basic logging for development only.

Production:

- Minimal logging.

Sensitive information must never be logged.

---

# 13. Security

Application Security:

- Master Password
- Auto Lock (7 minutes)

Sensitive information should never be exposed unintentionally.

---

# 14. Performance Goals

Application startup should be fast.

Scrolling should remain smooth.

Search should feel instant.

Synchronization should occur in the background.

The application should remain responsive while syncing.

---

# 15. Future Technology Considerations

Possible future additions:

- Fingerprint Authentication
- Secure Document Encryption
- Improved Sync Optimization

These are outside Version 1.

---

# 16. Technology Decisions

The following technologies are approved.

Framework:

Flutter

Language:

Dart

State Management:

Riverpod

Database:

SQLite

Cloud:

Google Drive

UI:

Material 3

Architecture:

Clean Architecture

These technologies should remain unchanged throughout Version 1.

---

# 17. Approved Packages

The following packages are officially approved for Version 1.

Only these packages should be used unless explicitly approved.

| Purpose | Package |
|---------|---------|
| State Management | flutter_riverpod |
| Local Database | sqflite |
| Secure Storage | flutter_secure_storage |
| File Picker | file_picker |
| Image Picker | image_picker |
| URL Launcher | url_launcher |
| Google Drive Authentication | google_sign_in |
| Google Drive API | googleapis |
| Local File Access | path_provider |
| Date Formatting | intl |
| Unique ID Generation | uuid |

Flutter SDK features should be preferred whenever possible to minimize external dependencies.

---

# 18. Cost Policy

Version 1 must be completely free to develop and use.

The project shall not require:

- Paid Flutter packages
- Paid APIs
- Paid cloud databases
- Paid authentication services
- Paid synchronization services
- Paid storage services

Google Drive synchronization shall use the user's own Google account.

No monthly subscription or server hosting costs should be required.

---

# Change History

## Version 1.1

- Approved official package list.
- Defined project cost policy.

---
