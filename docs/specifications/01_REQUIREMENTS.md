# Family Vault - Functional & Non-Functional Requirements

Version: 1.0
Status: Draft
Last Updated: YYYY-MM-DD

---

# 1. Functional Requirements

## 1.1 Authentication

The application shall:

- Use a single Master Password.
- Allow all trusted users to access the same vault.
- Require the Master Password every time the application is opened.
- Automatically lock after 7 minutes of inactivity.
- Require the Master Password again after auto-lock.

---

## 1.2 Dashboard

The Dashboard shall display:

- Total Accounts
- Documents Stored
- Last Backup Time

The Dashboard shall also provide:

- Global Search
- Owner Selection
- Quick Access to Favorites

---

## 1.3 Owners

The application shall organize all data by Owner.

Default Owners:

- Vansh
- Father
- Mother
- Brother
- Joint

Users shall be able to:

- Add Owner
- Rename Owner
- Delete Owner (only if no linked records exist)

---

## 1.4 Categories

Each Owner shall contain the following categories:

- Accounts
- Documents
- Insurance
- Investments
- Important Dates
- Other

Future categories may be added.

---

## 1.5 Account Management

Users shall be able to:

- Create Account
- View Account
- Edit Account
- Delete Account

Each Account shall contain:

- Institution Name
- Website URL
- Account Number
- User ID
- Login Password
- Transaction Password
- PIN
- OTP Required
- OTP Destination
- Registered Email
- Registered Mobile Number
- Notes
- Last Password Updated
- Last Modified

---

## 1.6 Custom Fields

Each Account shall support unlimited Custom Fields.

Each Custom Field contains:

- Field Name
- Field Value

Examples:

- CRN
- TPIN
- MPIN
- Demat ID
- Customer ID

---

## 1.7 Documents

Users shall be able to:

- Upload Documents
- View Documents
- Replace Documents
- Delete Documents

Supported Formats:

- PDF
- PNG
- JPG
- JPEG

Each Document shall contain:

- Document Type
- Document Number
- Issue Date
- Expiry Date
- Attachment
- Notes

---

## 1.8 Important Dates

Users shall be able to store important dates.

Each entry contains:

- Title
- Date
- Owner
- Notes

Examples:

- Insurance Renewal
- FD Maturity
- Passport Renewal

---

## 1.9 Search

The application shall provide Global Search.

Search shall support:

- Institution Name
- Website
- Account Number
- User ID
- Email
- Mobile Number
- Notes
- Custom Fields

Search results shall update instantly while typing.

---

## 1.10 Filters

Users shall be able to filter by:

- Owner
- Category

---

## 1.11 Copy Buttons

The application shall provide one-click copy for:

- Account Number
- User ID
- Passwords
- Email
- Mobile Number
- Custom Fields

---

## 1.12 Website Launch

Accounts containing Website URLs shall provide an "Open Website" button.

---

## 1.13 Recycle Bin

Deleted items shall:

- Move to Recycle Bin
- Remain for 30 days
- Be restored if required
- Be permanently deleted automatically after 30 days

---

## 1.14 Offline Operation

The application shall:

- Work fully without internet.
- Store all data locally.
- Never block the user because of missing internet.

---

## 1.15 Synchronization

The application shall synchronize data using Google Drive.

Synchronization Rules:

- Every change shall be saved immediately to the local SQLite database.
- The application shall mark the database as "Pending Sync" after each change.
- If an internet connection is available, synchronization shall automatically begin after a short delay (approximately 5–10 seconds).
- Multiple changes made within this time window shall be grouped into a single synchronization operation.
- Synchronization shall occur in the background.
- Users shall be able to continue using the application while synchronization is in progress.
- If synchronization fails, the application shall keep the changes locally and automatically retry when internet becomes available.
- The application shall always prioritize local data for normal operation.

Conflict Resolution:

- Latest Edit Wins.

Synchronization Status:

The application shall maintain one of the following states:

- Synced
- Pending Sync
- Syncing
- Sync Failed

The current synchronization status shall be visible in the Settings screen.

---

## 1.16 Settings

The application shall provide a Settings screen.

The Settings screen shall include:

- Change Master Password
- View Google Drive Sync Status
- Manual "Sync Now" button
- View Last Successful Backup Time
- About Application

The Settings screen shall remain simple and avoid unnecessary configuration options.

---

## 1.17 Favorites

Users shall be able to mark important records as Favorites.

Favorite records shall:

- Appear at the top of their respective category.
- Be indicated with a Star icon.
- Be removable from Favorites at any time.

Favorites shall support:

- Accounts
- Documents
- Insurance
- Investments
- Important Dates
- Other

---

# 2. Non-Functional Requirements

The application shall be:

- Fast
- Responsive
- Offline-first
- Cross-platform
- Easy to use
- Professional
- Lightweight
- Reliable

---

# 3. Supported Platforms

Version 1 shall support:

- Android
- Windows

---

# 4. Data Storage

Primary Storage:

- Local SQLite Database

Cloud Storage:

- Google Drive (Synchronization Only)

No dedicated backend server shall be used.

---

# 5. Security Requirements

The application shall:

- Use a shared Master Password.
- Lock automatically after 7 minutes.
- Never expose sensitive information without unlocking.
- Store local data securely.

---

# 6. Performance Requirements

Dashboard shall load quickly.

Search results shall appear instantly.

Opening records shall feel immediate.

Synchronization shall not freeze the interface.

---

# 7. Version 1 Limitations

Version 1 will NOT include:

- Browser Autofill
- Browser Extension
- Multi-user Accounts
- Banking API Integration
- SMS Reading
- OTP Reading
- Payment Features
- Face Authentication
- Desktop Notifications

---

# 8. Acceptance Criteria

Version 1 is complete when users can:

- Unlock the vault.
- Manage owners.
- Manage categories.
- Store accounts.
- Store documents.
- Store important dates.
- Use custom fields.
- Search instantly.
- Copy important information.
- Open websites.
- Restore deleted items.
- Work offline.
- Automatically synchronize through Google Drive.