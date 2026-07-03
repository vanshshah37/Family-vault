# Family Vault - Synchronization Architecture

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines how Family Vault synchronizes data between devices.

The synchronization system is designed to be:

- Offline First
- Reliable
- Lightweight
- Automatic
- Background Driven
- Easy to Maintain

The application shall always prioritize local usability over cloud connectivity.

---

# Synchronization Philosophy

The local SQLite database is always the primary source of truth during application usage.

Google Drive is used only for:

- Backup
- Synchronization
- Recovery

The application shall never directly read or write data from Google Drive during normal operation.

---

# Synchronization Flow

Every data modification follows this sequence:

User Action

↓

Update Local SQLite Database

↓

Mark Database as Pending Sync

↓

Wait 5–10 Seconds

↓

Check Internet Availability

↓

If Internet Available

↓

Start Background Synchronization

↓

Upload Database

↓

Upload Metadata

↓

Mark Status as Synced

---

# Offline Behavior

The application shall remain fully functional without internet.

Users shall be able to:

- Create Entries
- Edit Entries
- Delete Entries
- Restore Entries
- Upload Documents
- Search Data

All changes are saved locally.

No internet connection is required for normal usage.

---

# Online Behavior

When internet is available:

The application shall automatically:

- Detect pending changes.
- Upload the latest database.
- Upload updated metadata.
- Mark synchronization as complete.

The synchronization process shall never interrupt the user.

---

# Synchronization Delay

To reduce unnecessary uploads:

The application shall wait approximately 5–10 seconds after the most recent modification before starting synchronization.

If additional changes occur during this delay:

The timer shall restart.

Multiple changes shall be grouped into one synchronization operation.

---

# Google Drive Structure

FamilyVault/

├── vault.db

└── metadata.json

---

# vault.db

Contains:

- Complete SQLite Database

The database file contains all application data.

The entire database file is uploaded during synchronization.

---

# metadata.json

Purpose

Stores synchronization information without downloading the complete database.

Example

{
  "databaseVersion": 42,
  "lastSync": "2026-07-03T10:25:00Z",
  "deviceId": "device-001",
  "appVersion": "1.0.0"
}

The metadata file allows the application to quickly determine whether synchronization is required.

---

# Synchronization Status

The application shall support the following synchronization states:

- Synced
- Pending Sync
- Syncing
- Sync Failed

The current status shall be displayed in the Settings screen.

---

# Internet Detection

The application shall automatically detect internet availability.

If internet becomes available after offline usage:

Pending synchronization shall automatically begin.

No manual action shall be required.

---

# Failed Synchronization

If synchronization fails:

- Keep all local changes.
- Mark status as "Sync Failed".
- Retry automatically when internet becomes available.

Users shall never lose locally saved information because of synchronization failures.

---

# Conflict Resolution

Version 1 uses a simple synchronization strategy.

Rule:

Latest Edit Wins.

The latest successfully synchronized database replaces the previous version stored on Google Drive.

No manual conflict resolution is provided in Version 1.

---

# Application Startup

When the application starts:

1. Open Local SQLite Database.
2. Authenticate user.
3. Check Internet Availability.
4. If internet is available:
   - Read metadata.json.
   - Compare database version.
   - Download newer database if required.
5. Continue normal operation.

Application startup shall never depend on successful synchronization.

---

# Background Synchronization

Synchronization shall occur entirely in the background.

Users may continue:

- Browsing
- Editing
- Searching
- Viewing Documents

Synchronization must never block the user interface.

---

# Backup Strategy

Every successful synchronization creates an updated backup on Google Drive.

The latest synchronized database always represents the current cloud backup.

---

# Recovery

When installing Family Vault on a new device:

1. Install the application.
2. Sign in using the same Google account.
3. Enter the Master Password.
4. Download the latest synchronized database.
5. Continue using the application.

No manual database import shall be required.

---

# Security

Only authenticated Google Drive accounts shall access synchronized files.

Synchronization shall never expose sensitive information through logs or notifications.

The local database remains the primary working copy.

---

# Performance Goals

Synchronization should:

- Start automatically.
- Complete quickly.
- Avoid unnecessary uploads.
- Never freeze the interface.
- Consume minimal battery.
- Consume minimal network bandwidth.

---

# Future Improvements

Possible future enhancements include:

- Incremental synchronization
- Delta synchronization
- Compression before upload
- Conflict detection
- Selective synchronization

These features are outside the scope of Version 1.

---

# Change History

## Version 1.0

Initial synchronization architecture approved.