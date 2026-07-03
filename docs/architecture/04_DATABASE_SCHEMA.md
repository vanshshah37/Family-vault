# Family Vault - Database Schema

Version: 1.0
Status: Approved
Last Updated: YYYY-MM-DD

---

# Purpose

This document defines the complete database structure for the Family Vault application.

The database is designed to be:

- Offline First
- Simple
- Fast
- Easy to maintain
- Easy to synchronize
- Future scalable

The database is the single source of truth for all application data.

---

# Database Engine

Database Engine

- SQLite

Synchronization

- Google Drive

Architecture

- Local Database First

---

# Database Principles

1. Every Vault Entry must belong to exactly one Owner.

2. Every record inside the application is treated as a Vault Entry.

3. Categories are stored as text values instead of separate tables.

4. Credentials are unlimited.

5. Attachments are unlimited.

6. Custom Fields are unlimited.

7. Every modification is first saved locally.

8. Synchronization uploads the complete database file.

---

# Table Overview

The database contains the following tables.

1. owners

2. vault_entries

3. credentials

4. attachments

5. custom_fields

6. settings

7. sync_metadata

---

# Relationships

owners
│
└──────────────┐
               │
               ▼
        vault_entries
               │
      ┌────────┼──────────┐
      │        │          │
      ▼        ▼          ▼
credentials attachments custom_fields

settings

sync_metadata

---

# Table : owners

Purpose

Stores all available owners.

Example

Owner names are user-defined.

Examples:

- Self
- Father
- Mother
- Joint
- Business

The application never ships with predefined owner names.

Columns

id
INTEGER
PRIMARY KEY

name
TEXT
NOT NULL

created_at
TEXT

updated_at
TEXT

Rules

Owner names should be unique.

An owner cannot be deleted while linked entries exist.

---

# Table : vault_entries

Purpose

Stores every item inside the vault.

Examples

- HDFC Bank
- Passport
- LIC
- Zerodha
- Passport Renewal

Columns

id
INTEGER
PRIMARY KEY

owner_id
INTEGER

category
TEXT

title
TEXT

institution_name
TEXT

website_url
TEXT

account_number
TEXT

registered_email
TEXT

registered_mobile
TEXT

otp_required
INTEGER

otp_destination
TEXT

notes
TEXT

favorite
INTEGER

last_password_updated
TEXT

created_at
TEXT

updated_at
TEXT

deleted_at
TEXT

Foreign Key

owner_id

→ owners(id)

Rules

deleted_at

NULL

means Active.

Otherwise

Recycle Bin.

---

# Supported Categories

Accounts

Documents

Insurance

Investments

Important Dates

Other

---

# Table : credentials

Purpose

Stores unlimited credentials for every vault entry.

Examples

Login Password

Transaction Password

PIN

TPIN

MPIN

Customer ID

CRN

Security Question

Security Answer

Columns

id
INTEGER
PRIMARY KEY

entry_id
INTEGER

credential_name
TEXT

credential_value
TEXT

display_order
INTEGER

created_at
TEXT

updated_at
TEXT

Foreign Key

entry_id

→ vault_entries(id)

Rules

Unlimited credentials allowed.

Display order controls UI order.

---

# Table : attachments

Purpose

Stores files linked to an entry.

Supported

PDF

PNG

JPG

JPEG

Columns

id
INTEGER
PRIMARY KEY

entry_id
INTEGER

file_name
TEXT

file_path
TEXT

file_type
TEXT

file_size
INTEGER

created_at
TEXT

updated_at
TEXT

Foreign Key

entry_id

→ vault_entries(id)

Rules

Unlimited attachments.

Files stored locally.

Google Drive sync uploads automatically.

---

# Table : custom_fields

Purpose

Stores additional information not covered by standard fields.

Examples

Relationship Manager

Broker ID

Nominee

Locker Number

Emergency Contact

Columns

id
INTEGER
PRIMARY KEY

entry_id
INTEGER

field_name
TEXT

field_value
TEXT

display_order
INTEGER

created_at
TEXT

updated_at
TEXT

Foreign Key

entry_id

→ vault_entries(id)

Rules

Unlimited custom fields.

---

# Table : settings

Purpose

Stores application settings.

The Settings table shall contain exactly one record for each local database.

Columns

id
INTEGER
PRIMARY KEY

master_password_hash
TEXT

auto_lock_minutes
INTEGER

google_account_email
TEXT

last_backup
TEXT

created_at
TEXT

updated_at
TEXT

Rules

Exactly one settings record.

---

# Table : sync_metadata

Purpose

Stores synchronization information.

Columns

id
INTEGER
PRIMARY KEY

sync_status
TEXT

last_sync
TEXT

pending_changes
INTEGER

database_version
INTEGER

created_at
TEXT

updated_at
TEXT

---

# Synchronization Strategy

Every modification

↓

SQLite

↓

Pending Sync

↓

Wait 5–10 seconds

↓

Upload complete database

↓

Google Drive

If upload fails

↓

Keep local copy

↓

Retry automatically

---

# Recycle Bin

Deleted records are never immediately removed.

Instead

deleted_at

stores deletion time.

Records remain available for

30 Days

After that

Permanent deletion.

---

# Search Strategy

Global Search searches

vault_entries

credentials

custom_fields

Search Fields

Title

Institution Name

Website

Account Number

Email

Mobile

Notes

Credential Names

Credential Values

Custom Field Names

Custom Field Values

---

# Constraints

Every Vault Entry must belong to one Owner.

Every Credential belongs to one Vault Entry.

Every Attachment belongs to one Vault Entry.

Every Custom Field belongs to one Vault Entry.

Settings table contains only one record.

Categories must match approved values.

---

# Future Compatibility

Database is designed to support future features without structural redesign.

Possible future additions

- Fingerprint Authentication

- Secure Document Encryption

- Better Synchronization

- More Categories

- More Credential Types

---

# Change History

## Version 1.0

Initial database schema approved.