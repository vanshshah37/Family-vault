# Family Vault – Phase 13: Vault Security

## Objective

Implement a lightweight security layer for Family Vault.

The goal of this phase is to protect access to the vault while keeping the implementation as simple and maintainable as possible. Existing functionality from previous phases must remain unchanged.

This phase intentionally avoids complex encryption migrations, cloud synchronization changes, and advanced security features.

---

# Features

## 1. Vault Lock

### Objective

Require authentication before a user can access their vault.

### Supported Authentication

- 4–8 digit PIN
- Fingerprint (Biometric)

### Behavior

If biometrics are enabled:

1. Attempt fingerprint authentication.
2. If fingerprint fails or is unavailable, allow PIN entry.

If biometrics are disabled:

- Show only the PIN screen.

The vault should never open without successful authentication once protection has been enabled.

---

## 2. First-Time Security Setup

If security has never been configured:

Prompt the user to create a PIN.

Requirements:

- PIN length: 4–8 digits
- Confirm PIN before saving

After setup:

- Security becomes enabled.
- User may optionally enable biometrics.

---

## 3. Auto Lock

Automatically lock the vault when:

- App moves to background
- App resumes after timeout
- Screen is turned off (handled through lifecycle)
- User exits the app
- User has been inactive for 3 minutes

Requirements:

- Timer resets after user interaction.
- Locked vault always requires authentication again.

---

## 4. Session Management

Maintain an authenticated session only while the vault is unlocked.

Requirements:

- Unlock once.
- Use app normally.
- If auto-lock triggers, authentication is required again.
- Authentication state should not interfere with Firebase login.

Firebase Authentication and Vault Lock are independent.

---

## 5. Security Settings Screen

Create a new Settings page named:

Security

Include the following options:

### Change PIN

Allow changing the existing PIN after verifying the current PIN.

---

### Enable / Disable Biometrics

Toggle:

- ON
- OFF

If device does not support biometrics:

Disable the option gracefully.

---

### Auto Lock Timer

Selectable values:

- Immediately
- 1 Minute
- 3 Minutes (Default)
- 5 Minutes
- Never

Persist the selected value locally.

---

### Lock Now

Immediately lock the vault.

The next interaction must require authentication.

---

## 6. Secure Screens

Whenever the vault is locked:

Do not display credential information.

Show only the lock screen until authentication succeeds.

---

# Data Storage

Store only lightweight security preferences locally.

Examples:

- PIN hash
- Biometrics enabled
- Auto-lock duration
- Security enabled

Do not store plaintext PINs.

A simple secure local storage solution is sufficient.

---

# Not Included

The following features are intentionally excluded from Phase 13:

- Database encryption
- SQLCipher
- AES encryption
- Export
- Import
- Backup
- Clipboard auto-clear
- Password breach checking
- Password expiration
- Entry synchronization
- Cloud storage changes

---

# Deliverables

- PIN Lock
- Fingerprint Authentication
- First-Time PIN Setup
- Auto Lock
- Session Management
- Security Settings Screen
- Lock Now
- Auto-Lock Timer
- Biometric Toggle

---

# Acceptance Criteria

- Existing Firebase Authentication continues working.
- Existing Vault selection continues working.
- Existing password management is unaffected.
- Vault cannot be accessed without authentication once enabled.
- Auto-lock functions correctly.
- PIN verification works.
- Biometric authentication works when available.
- Lock screen is responsive.
- No analyzer warnings.
- No runtime errors.
- Production-ready implementation.