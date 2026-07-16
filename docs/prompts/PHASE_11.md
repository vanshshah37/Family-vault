# Phase 11 — Google Authentication, Shared Vault Creation, Vault ID & Join Requests

---

## Phase Status

Status: Not Started

Previous Phase:
Phase 10 — Input Validation & Form Hardening ✅

Next Phase:
Phase 12 — Continuous SQLite ↔ Cloud Synchronization, Conflict Handling, Offline Queue & Reliability

---

# Objective

Build the cloud identity and shared-family-vault foundation for Family Vault.

Phase 11 must allow users on different devices and with different Google accounts to:

1. Sign in with Google.
2. Create a new Family Vault, or request to join an existing vault.
3. Receive a unique human-readable Vault ID when creating a vault.
4. Share that Vault ID with family members.
5. Allow another authenticated user to enter the Vault ID and send a join request.
6. Allow the vault owner to view pending join requests.
7. Allow the owner to accept or reject a join request.
8. Grant shared-vault membership only after owner approval.
9. Allow authorized members to access the same shared vault foundation.
10. Support users who may belong to more than one vault.

Phase 11 establishes:

- Cloud backend foundation.
- Google authentication.
- Persistent authenticated sessions where supported.
- Cloud user profiles.
- Shared Family Vault creation.
- Unique human-readable Vault IDs.
- Vault ownership.
- Join requests using Vault ID.
- Owner approval/rejection.
- Explicit vault membership.
- Owner/member roles.
- Member listing.
- Member removal.
- Access authorization.
- Multi-vault membership handling.

Phase 11 must NOT yet synchronize existing SQLite Entry records with the cloud.

Entry synchronization belongs exclusively to Phase 12.

All functionality completed in Phases 01–10 must remain operational.

---

# Final Product Model

The intended user flow is:

```text
App opens
    ↓
Google Sign-In
    ↓
Check user's vault memberships
    ↓
┌───────────────────────────────────────────────┐
│                                               │
│  0 vaults                                     │
│      ↓                                        │
│  Show two options:                            │
│  • Create New Vault                           │
│  • Join Existing Vault                        │
│                                               │
│  1 vault                                      │
│      ↓                                        │
│  Open that vault directly                     │
│                                               │
│  2+ vaults                                    │
│      ↓                                        │
│  Show Vault Selection                         │
│                                               │
└───────────────────────────────────────────────┘
```

---

# Core Product Requirement

Different families must be able to use separate vaults.

Example:

```text
Shah Family Vault
Vault ID: FV-7K9X-2M4P

Patel Family Vault
Vault ID: FV-R8W3-A6N2

Mehta Family Vault
Vault ID: FV-T4Q7-Z9B5
```

Each vault is logically separate.

A user may create a vault and become its owner.

Another authenticated user may enter the public Vault ID and request access.

Knowing a Vault ID must NOT directly grant access.

The flow is:

```text
User knows Vault ID
        ↓
User sends join request
        ↓
Owner sees pending request
        ↓
Owner accepts or rejects
        ↓
Accepted?
    ├── Yes → Membership created
    └── No  → No vault access
```

---

# Critical Product Requirement: Future Continuous Cloud Synchronization

The final product must eventually provide continuous cloud synchronization.

When an authorized vault member:

- Creates an entry.
- Edits an entry.
- Deletes an entry.

the change must eventually synchronize automatically to the shared cloud vault.

The user should not need to press a manual Backup button after every change.

However:

**Phase 11 does not implement Entry synchronization.**

Phase 11 only establishes:

```text
Who is the user?
        ↓
Which vaults does the user belong to?
        ↓
Which vault is currently active?
        ↓
Is the user owner or member?
```

Phase 12 will implement:

```text
Local SQLite
      ↕
Automatic cloud synchronization
      ↕
Shared Family Vault
      ↕
Authorized devices
```

Do not implement Phase 12 functionality prematurely.

---

# Current Application State

Phases 01–10 are complete.

The current application already has:

- Flutter.
- Material 3.
- Android support.
- Windows desktop support.
- Dashboard.
- Navigation.
- Universal Entry wizard.
- Six entry categories.
- Configuration-driven dynamic forms.
- SQLite persistence.
- Create functionality.
- Read functionality.
- Update functionality.
- Delete functionality.
- Entry Details screen.
- Search.
- Category filtering.
- Live SQLite-backed Dashboard statistics.
- Configuration-driven validation.
- Android testing completed.
- Windows testing completed.

The existing application currently uses local SQLite as the Entry persistence layer.

Current Entry architecture:

```text
UI
 ↓
EntryRepository
 ↓
DatabaseService
 ↓
SQLite
```

This architecture must remain intact during Phase 11.

Do not replace it.

Do not migrate existing Entry records to cloud in Phase 11.

Do not change existing Entry CRUD behavior.

---

# Phase 11 Scope

## Included

- Evaluate and select cloud backend.
- Evaluate and select Google authentication architecture.
- Google Sign-In.
- Authentication-state handling.
- Persistent authenticated session where provider/platform supports it.
- Cloud user profile.
- Create a new Family Vault.
- Generate a unique human-readable Vault ID.
- Vault ownership.
- Join an existing vault by entering Vault ID.
- Send join request.
- Prevent duplicate pending join requests.
- Prevent existing members from sending unnecessary join requests.
- Owner sees pending join requests.
- Owner accepts request.
- Owner rejects request.
- Membership created after acceptance.
- Owner/member roles.
- Member listing.
- Owner can remove a normal member.
- Removed member loses future cloud authorization.
- Sign out.
- 0-vault state.
- 1-vault state.
- 2+-vault state.
- Vault selection.
- Loading states.
- Empty states.
- Error states.
- Android support.
- Windows support strategy.
- Cloud authorization rules.
- Foundation for Phase 12 continuous synchronization.

---

# Explicitly Excluded

Do NOT implement in Phase 11:

- SQLite ↔ cloud Entry synchronization.
- Uploading existing Entry records.
- Downloading Entry records.
- Cloud Entry collection.
- Real-time Entry listeners.
- Entry conflict resolution.
- Offline Entry sync queue.
- Sync retry infrastructure.
- Tombstones for deleted Entries.
- Cloud-backed Dashboard statistics.
- Cloud-backed Search.
- Cloud-backed Entry Lists.
- Cloud-backed Entry Details.
- Cloud-backed CRUD.
- Manual JSON backup.
- Unlimited backup-history files.
- Encryption.
- End-to-end encryption.
- Shared encryption-key management.
- Recovery snapshots.
- Accidental-deletion recovery.
- Master password.
- PIN lock.
- Biometrics.
- Notifications.
- Email invitations.
- Invitation by email address.
- Email-delivery infrastructure.
- OTP authentication.
- Phone authentication.
- Apple Sign-In.
- Facebook Sign-In.
- Anonymous authentication.
- Vault rename.
- Vault deletion.
- Ownership transfer.
- New dynamic form fields.
- Existing validation changes.
- Search changes.
- Dashboard redesign.
- SQLite schema changes unless absolutely unavoidable and explicitly approved.
- Entry model changes solely for future Phase 12 synchronization.
- New global state-management framework unless absolutely necessary.
- New routing framework.

---

# Authentication Requirements

The application must support Google authentication.

Expected startup behavior:

```text
App starts
    ↓
Check authentication state
    ↓
┌───────────────────────────────────────┐
│ Loading                               │
│                                       │
│ Not authenticated                     │
│ → Show Google Sign-In                 │
│                                       │
│ Authenticated                         │
│ → Load user's vault memberships       │
└───────────────────────────────────────┘
```

Requirements:

- User signs in with Google.
- User receives stable authenticated cloud UID.
- Email is available where permitted.
- Display name may be stored.
- Profile photo URL may be stored.
- Authentication failures must not crash the app.
- Authentication cancellation must be handled gracefully.
- Raw backend exceptions must not be shown directly.
- User can explicitly sign out.
- Do not store passwords.
- Do not implement custom password handling.

---

# Platform Requirements

The application supports:

- Android.
- Windows.

The Phase 11 analysis must explicitly determine the authentication architecture for both.

Do not assume Android Google Sign-In code works unchanged on Windows.

The analysis must determine:

- Current Android Google authentication support.
- Current Windows Google authentication support.
- Exact packages required.
- Whether packages are officially maintained or community-maintained.
- Windows browser-based OAuth requirements.
- OAuth client configuration requirements.
- Whether both Android and Windows ultimately produce one consistent Firebase/backend user identity.
- Whether Firebase Authentication session persistence works across restarts on both platforms.
- Whether any platform-specific fallback is necessary.

Do not implement a custom OAuth flow unless the analysis proves it is genuinely necessary.

Prefer maintained packages over hand-written security-sensitive OAuth code where practical.

---

# Cloud Provider Decision

The leading candidate is:

- Firebase Authentication.
- Cloud Firestore.

Reasons include:

- Google authentication.
- Stable UID identity.
- Shared cloud data.
- Authorization rules.
- Real-time capabilities needed later in Phase 12.
- Flutter ecosystem.
- Suitable for small-family use.

However, do not blindly assume Firebase automatically wins.

The analysis must compare at least:

1. Firebase Authentication + Cloud Firestore.
2. Supabase Auth + PostgreSQL.
3. Any materially better alternative only if justified.

Compare:

- Android support.
- Windows support.
- Google authentication.
- Flutter package maturity.
- Free-tier suitability.
- Whether payment method is required.
- Shared-vault authorization.
- Join-request architecture.
- Real-time Phase 12 suitability.
- Offline behavior.
- Security model.
- Development complexity.
- Maintenance burden.

Recommend one provider before implementation.

---

# Cost Requirement

The project should remain free or extremely low-cost for development and normal small-family usage.

The app may potentially be shared with multiple different families.

Example:

```text
Family A → Own vault
Family B → Own vault
Family C → Own vault
```

The analysis must explicitly examine:

- Authentication pricing.
- Database free-tier limits.
- Read limits.
- Write limits.
- Storage limits.
- Real-time listener costs.
- Whether billing must be enabled.
- Whether a payment method is required.
- Risk of unexpected charges.
- Whether small-family usage can realistically remain within the free tier.
- What happens if many families eventually use the app.

Do not claim any cloud provider is permanently or infinitely free.

---

# User Profile

After authentication, maintain the minimum necessary cloud user profile.

Conceptual model:

```text
UserProfile
- uid
- email
- displayName
- photoUrl
- createdAt
- updatedAt
```

Do not add unnecessary fields.

Do not add `lastSignedInAt` unless technically required and explicitly approved.

---

# Create New Vault Flow

For a user with no vault memberships:

```text
Google Sign-In
      ↓
No existing vault memberships
      ↓
Show two choices
      ↓
┌─────────────────────────┐
│ Create New Vault        │
│                         │
│ Join Existing Vault     │
└─────────────────────────┘
```

If the user chooses Create New Vault:

```text
Create New Vault
      ↓
Enter Vault/Family Name
      ↓
Validate name
      ↓
Generate unique human-readable Vault ID
      ↓
Create vault
      ↓
Create owner membership
      ↓
Open Dashboard
```

The authenticated creator becomes:

```text
role: owner
```

---

# Human-Readable Vault ID

Each vault must have a unique, shareable, human-readable public Vault ID.

Example format:

```text
FV-7K9X-2M4P
FV-R8W3-A6N2
FV-T4Q7-Z9B5
```

Requirements:

- Easy to read.
- Easy to type.
- Easy to share through messaging.
- Case-insensitive input where practical.
- Globally unique within the application's cloud backend.
- Generated by the application/backend architecture.
- Collision handling must exist.
- Must not expose sensitive internal information.

Do not use:

- Owner email.
- Owner UID.
- Device ID.
- Local SQLite auto-increment ID.

The analysis must decide whether:

- Public Vault ID is also the Firestore document ID, or
- The vault has a separate internal document ID and public Vault ID.

Choose the simplest correct architecture.

---

# Shared Vault Model

Conceptual model:

```text
FamilyVault
- vaultId
- publicVaultId
- name
- ownerUid
- createdAt
- updatedAt
```

The exact minimum fields must be finalized during analysis.

Do not store unnecessary data.

---

# Join Existing Vault Flow

A signed-in user with no active vault, or a user intentionally choosing to join another vault, may enter a Vault ID.

Flow:

```text
Join Existing Vault
      ↓
Enter Vault ID
      ↓
Normalize input
      ↓
Find matching vault
      ↓
If vault exists:
    Send join request
      ↓
Wait for owner decision
```

Knowing the Vault ID must NOT directly grant membership.

---

# Vault ID Normalization

Vault ID input should be normalized consistently.

At minimum:

- Trim leading whitespace.
- Trim trailing whitespace.
- Convert letters to uppercase.

Example:

```text
"  fv-7k9x-2m4p  "
```

becomes:

```text
FV-7K9X-2M4P
```

Do not implement unnecessarily complex normalization.

---

# Join Request Model

Conceptual model:

```text
VaultJoinRequest
- requestId
- vaultId
- requesterUid
- requesterEmail
- requesterDisplayName
- status
- createdAt
- resolvedAt
```

Possible statuses:

```text
pending
accepted
rejected
```

The exact minimum model should be finalized during analysis.

---

# Join Request Rules

Before creating a join request:

- User must be authenticated.
- Vault ID must exist.
- User must not already be a member of that vault.
- User must not already have a pending request for that vault.
- Request must belong to the authenticated user's UID.
- Duplicate pending requests must be prevented.
- Request creation must not grant access.

A user may know a Vault ID without being able to read the vault's private data.

---

# Duplicate Join Request Prevention

The architecture must prevent unnecessary duplicate pending requests.

Conceptually, there should be at most one active request for:

```text
vault + requesting user
```

The analysis should prefer a simple deterministic request identity such as:

```text
vaultId + requesterUid
```

or another atomic structure.

Do not add hashing or a `crypto` dependency unless genuinely necessary.

---

# Owner Pending Requests

The vault owner must be able to view pending join requests for their vault.

Example:

```text
Pending Join Requests

John Doe
john@example.com

[ Reject ]    [ Accept ]
```

Only the vault owner should be able to accept or reject requests in Phase 11.

Normal members do not manage join requests.

---

# Accept Join Request

When the owner accepts:

```text
Pending request
      ↓
Owner taps Accept
      ↓
Membership created
      ↓
Request becomes accepted
      ↓
Requester gains future cloud authorization
```

This operation should be atomic where practical.

The analysis must determine whether to use:

- Firestore transaction.
- Batch write.
- Another backend mechanism.

Do not create partial states such as:

```text
Request marked accepted
BUT
Membership not created
```

or:

```text
Membership created
BUT
Request still pending
```

---

# Reject Join Request

When the owner rejects:

```text
Pending request
      ↓
Owner taps Reject
      ↓
Request becomes rejected
      ↓
No membership created
```

The analysis must define whether the same user may request again later.

Recommended behavior:

- A rejected user may send a new request later.
- The architecture may safely reuse the same deterministic request document if appropriate.

---

# Membership Model

The authoritative membership structure should be simple.

Conceptually:

```text
VaultMember
- uid
- email
- displayName
- role
- joinedAt
```

Minimum roles:

```text
owner
member
```

The owner:

- Creates the vault.
- Can view pending join requests.
- Can accept requests.
- Can reject requests.
- Can view members.
- Can remove normal members.

A normal member:

- Can access the vault.
- Can view members if approved.
- Cannot accept/reject join requests.
- Cannot remove the owner.
- Cannot remove other members.
- Cannot promote themselves to owner.

---

# Recommended Permissions

| Action | Owner | Member | Non-member |
|---|---:|---:|---:|
| Access vault cloud data | Yes | Yes | No |
| View vault metadata | Yes | Yes | Minimal lookup only for join flow |
| View member list | Yes | Yes | No |
| View pending join requests | Yes | No | No |
| Send join request | N/A if already member | N/A if already member | Yes |
| Accept join request | Yes | No | No |
| Reject join request | Yes | No | No |
| Remove normal member | Yes | No | No |
| Remove owner | No | No | No |
| Create owner membership for self | Only during vault creation | No | No |

The analysis must review this policy.

---

# Member Removal

The owner can remove a normal member.

Flow:

```text
Owner opens Vault Settings
      ↓
Views members
      ↓
Selects normal member
      ↓
Remove
      ↓
Confirmation dialog
      ↓
Membership removed
```

Requirements:

- Owner cannot remove themselves in Phase 11.
- Normal member cannot remove owner.
- Normal member cannot remove other members.
- Backend authorization must enforce this.
- UI hiding alone is not sufficient.

After removal, that account must lose future cloud authorization to that vault.

Phase 13 will handle stronger local sensitive-data cleanup policies after access revocation.

---

# Multi-Vault Membership

The backend must support users belonging to multiple vaults.

Example:

```text
User A owns:
Shah Family Vault

User A is also a member of:
Extended Family Vault
```

Required UI states:

```text
0 memberships
→ Create/Join screen

1 membership
→ Automatically open that vault

2+ memberships
→ Show VaultSelectionScreen
```

Do not leave the 2+ state undefined.

The active vault may remain session-only during Phase 11.

No persistent active-vault preference is required yet.

---

# Vault Selection

For users with 2+ memberships:

```text
Your Vaults

Shah Family Vault
FV-7K9X-2M4P

Extended Family Vault
FV-A3B8-N6Q1
```

User selects one vault.

That vault becomes the active vault for the current session.

Do not build a large vault-management system.

Keep this screen minimal.

---

# Authentication Gate

The application should determine the correct root state.

Conceptual flow:

```text
App starts
    ↓
Auth state loading
    ↓
Not signed in?
    → SignInScreen

Signed in?
    ↓
Ensure minimal cloud user profile exists
    ↓
Load user's vault memberships
    ↓
┌────────────────────────────────────┐
│ 0 → VaultOnboardingScreen          │
│ 1 → HomeScreen(active vault)       │
│ 2+ → VaultSelectionScreen          │
└────────────────────────────────────┘
```

The exact widget architecture must be determined during analysis.

Prefer root-level state switching over fragile manual navigation-stack manipulation.

---

# Suggested UI Scope

Potential minimum screens:

```text
AuthGate
SignInScreen
VaultOnboardingScreen
VaultSelectionScreen
VaultSettingsScreen
```

`VaultOnboardingScreen` may contain:

- Create New Vault.
- Join Existing Vault.
- Pending request status if useful.

`VaultSettingsScreen` may contain:

- Vault name.
- Public Vault ID.
- Copy/share-friendly display.
- Current members.
- Pending join requests for owner.
- Accept/reject actions.
- Remove-member action for owner.
- Sign out.

The exact minimum screen set must be proposed during analysis.

Avoid unnecessary screens.

Dialogs or bottom sheets may be used where simpler.

---

# Dashboard Integration

Once authenticated and associated with an active vault, the user reaches the existing Dashboard.

Do not redesign the Dashboard.

One additional AppBar action is explicitly approved for Phase 11:

```text
Vault Settings / Members / Sign Out
```

This is an approved exception to any earlier design-system restriction against adding a settings action.

Do not add other unrelated Dashboard actions.

---

# Sign Out

Requirements:

- End cloud authentication session.
- Return to authentication gate.
- Do not crash.
- Do not delete existing SQLite Entry records in Phase 11.
- Do not automatically clear local Entry data.
- Do not invent irreversible local deletion behavior.

Phase 13 will define stronger secure local-data behavior after:

- Sign out.
- Member removal.
- Access revocation.
- Device loss.

---

# Cloud Data Model

The analysis must propose an exact cloud schema.

A possible Firestore structure is:

```text
users/{uid}

vaults/{vaultId}

vaults/{vaultId}/members/{uid}

vaults/{vaultId}/joinRequests/{requesterUid}
```

This structure is not automatically approved.

The analysis must determine:

- How users discover all their vault memberships.
- Whether collection-group membership queries are appropriate.
- How Vault ID lookup works.
- How non-members can look up only enough information to send a join request.
- How owner-only pending-request queries work.
- How member listing works.
- How join acceptance remains atomic.
- How member removal works.
- How Phase 12 can later add:

vaults/{vaultId}/entries/{entryId}
```

Do not create duplicate membership sources unless technically justified.

Prefer one authoritative membership source of truth.

---

# Membership Discovery

The analysis must determine the simplest safe method for finding every vault membership belonging to the authenticated user.

Possible architecture:

```text
vaults/{vaultId}/members/{uid}
```

with a Firestore collection-group query filtered by authenticated UID.

The analysis must verify:

- Query feasibility.
- Security Rules compatibility.
- Required Firestore Rules version.
- Index requirements.
- Multi-vault behavior.
- Full member-list behavior for existing members.

Do not blindly duplicate membership state into user profiles.

---

# Public Vault ID Lookup

The join flow requires a user to enter a public Vault ID.

The analysis must determine how to look up a vault without granting access to private vault data.

Possible approaches include:

- Use public Vault ID as Firestore vault document ID.
- Separate public lookup collection.
- Another minimal structure.

The chosen approach must support:

```text
Enter Vault ID
      ↓
Does vault exist?
      ↓
Yes → Allow join request
No  → Show "Vault not found"
```

Knowing the ID must not expose:

- Members.
- Entries.
- Join requests.
- Sensitive vault data.

---

# Join Request Identity

Recommended simple deterministic identity:

```text
vault + requester UID
```

For example:

```text
vaults/{vaultId}/joinRequests/{requesterUid}
```

Benefits:

- One request document per user per vault.
- No duplicate request documents.
- No SHA-256 required.
- No `crypto` dependency required.
- Easy owner query.
- Easy authenticated-user ownership check.

The analysis must verify whether this structure works cleanly with Firestore authorization.

---

# Security Requirements

This is not intended to be an enterprise security project.

Keep the architecture simple.

However, minimum authorization is required:

1. User must authenticate with Google.
2. Knowing Vault ID does not grant vault access.
3. Vault ID only permits requesting access.
4. Owner accepts or rejects.
5. Only after acceptance is membership created.
6. Only members can access private vault cloud data.
7. Only owner can manage join requests.
8. Only owner can remove normal members.
9. A normal member cannot make themselves owner.

Do not over-engineer security.

Do not rely only on hidden UI buttons.

Cloud authorization rules must enforce the basic boundaries above.

---

# Security Rules

If Firebase/Firestore is selected, Phase 11 must include Security Rules appropriate to the implemented schema.

Rules must enforce at minimum:

- Unauthenticated users cannot access private vault cloud data.
- Non-members cannot read members.
- Non-members cannot read entries in future Phase 12.
- Knowing Vault ID does not grant private access.
- Authenticated user can create only their own join request.
- Existing member cannot create unnecessary join request.
- Only owner can read/manage pending join requests.
- Only owner can accept/reject.
- Only owner can remove normal members.
- Owner cannot be removed through normal member-removal flow.
- Normal member cannot promote themselves.
- Membership creation during vault creation and join-request acceptance must be authorized correctly.

Do not rely exclusively on client-side checks.

Do not overcomplicate the rules beyond actual product requirements.

---

# Atomic Operations

The analysis must identify operations that should be atomic.

At minimum analyze:

## Vault creation

```text
Create vault
+
Create owner membership
```

## Join acceptance

```text
Create member membership
+
Mark request accepted
```

Avoid partial states.

Use transaction or batch write where appropriate.

---

# Error Handling

Cloud operations may fail because of:

- No internet.
- Authentication cancelled.
- Authentication failure.
- Vault not found.
- Duplicate pending request.
- Already a member.
- Permission denied.
- Request already resolved.
- Backend unavailable.
- Session expired.
- Unknown error.

Requirements:

- App remains stable.
- Show user-friendly messages.
- Do not show raw stack traces.
- Do not show raw provider exceptions.
- Do not silently grant access after failure.

---

# Loading States

Required cloud operations need stable loading behavior.

Examples:

- Checking authentication.
- Signing in.
- Loading memberships.
- Creating vault.
- Looking up Vault ID.
- Sending join request.
- Loading pending requests.
- Accepting request.
- Rejecting request.
- Removing member.
- Signing out.

Prevent accidental duplicate submissions where appropriate.

Do not create a global loading framework.

Use local state where practical.

---

# Offline Behavior in Phase 11

Phase 11 is not the offline Entry synchronization phase.

Existing local SQLite CRUD should remain intact.

Cloud-only actions may require internet:

- Google Sign-In.
- Create vault.
- Join request.
- Accept/reject request.
- Member removal.

Handle unavailable cloud operations gracefully.

Do not build the Phase 12 offline Entry queue.

---

# Existing SQLite Preservation

Phase 11 must not break:

- Create.
- Read.
- Update.
- Delete.
- Search.
- Category filtering.
- Dashboard statistics.
- Validation.

Do not delete the SQLite database.

Do not migrate Entries to cloud.

Do not modify the Entry model solely for Phase 12.

Do not change SQLite schema unless absolutely unavoidable and explicitly approved.

---

# Phase 12 Compatibility

Phase 12 will implement:

```text
Local SQLite
      ↕
Continuous cloud synchronization
      ↕
vaults/{vaultId}/entries/{entryId}
```

Potential future needs include:

- Globally unique Entry IDs.
- Sync status.
- Updated-by UID.
- Server timestamps.
- Conflict resolution.
- Offline queue.
- Delete tombstones.

Do not implement these in Phase 11.

But Phase 11 must not choose a vault architecture that makes Phase 12 unnecessarily difficult.

---

# Zero/Low-Cost Architecture

The cloud design should minimize unnecessary reads and writes.

The analysis must consider:

- Avoiding constant listeners where one-time reads are enough.
- Using real-time listeners only where product value justifies them.
- Cost impact of many families.
- Cost impact of Phase 12 continuous synchronization.
- Efficient membership discovery.
- Efficient join-request queries.
- Avoiding unnecessary duplicated cloud data.

The intended initial scale is small-family usage, but the app may be shared with multiple families.

---

# Dependency Policy

No dependency is automatically approved.

The analysis must propose the minimum exact dependency set.

Possible candidates depending on final architecture:

```text
firebase_core
firebase_auth
cloud_firestore
google_sign_in
```

Windows authentication may require additional packages.

For every proposed dependency explain:

- Exact package name.
- Why required.
- Platforms used.
- Maintenance status.
- Whether official or community-maintained.
- Why it cannot be omitted.

Do not add:

- `crypto` unless genuinely necessary.
- `flutter_secure_storage` unless genuinely necessary.
- Phase 12 dependencies.
- Phase 13 dependencies.
- Convenience packages without justification.

---

# State Management

Do not automatically introduce:

- Riverpod.
- Provider.
- Bloc.
- Redux.

The project may already contain a dependency that is unused; do not begin using it automatically.

Prefer:

- `StatefulWidget`.
- `FutureBuilder`.
- `StreamBuilder`.
- Provider-native auth streams where appropriate.
- Local state.

Only introduce a state-management architecture if analysis proves it necessary.

---

# Navigation

Continue using the current lightweight Flutter navigation architecture unless analysis proves otherwise.

Do not automatically introduce:

- go_router.
- auto_route.
- Named-route overhaul.
- Global navigation key.

Authentication gating should preferably happen through root-level state switching.

---

# Existing Functionality Preservation

Phase 11 must preserve all functionality from Phases 01–10:

- Dashboard.
- Live Dashboard statistics.
- Universal Entry wizard.
- Dynamic forms.
- SQLite persistence.
- Full CRUD.
- Search.
- Category filtering.
- Validation.
- Android support.
- Windows support.

No existing local Entry data should be lost because authentication was added.

---

# Acceptance Criteria

Phase 11 is complete when:

- Cloud provider is selected and configured.
- Google authentication works on approved platforms.
- Authentication state is handled correctly.
- Authenticated user profile is created/loaded.
- First-time user sees exactly:
  - Create New Vault.
  - Join Existing Vault.
- User can create a new vault.
- Human-readable unique Vault ID is generated.
- Creator becomes owner.
- User can enter another vault's ID.
- Valid vault is found without exposing private data.
- User can send join request.
- Duplicate pending requests are prevented.
- Existing members cannot send unnecessary join requests.
- Owner can view pending requests.
- Owner can accept request.
- Owner can reject request.
- Accepted requester becomes member.
- Rejected requester does not gain access.
- Owner can view member list.
- Approved member can view member list if policy allows.
- Owner can remove normal member.
- Normal member cannot remove owner.
- Unauthorized user cannot access private vault data.
- Knowing Vault ID alone does not grant access.
- 0-vault state works.
- 1-vault state works.
- 2+-vault state works.
- Sign out works.
- Existing SQLite CRUD remains operational.
- Existing Search remains operational.
- Existing Dashboard remains operational.
- Existing validation remains operational.
- No Entry cloud synchronization is implemented prematurely.
- Android is verified.
- Windows strategy is verified and implemented where approved.
- `flutter analyze` reports zero issues.

---

# Manual Testing Checklist

## Authentication

1. Launch app signed out.
2. Verify Google Sign-In screen appears.
3. Sign in with Google account A.
4. Restart app.
5. Verify session restoration behavior.
6. Sign out.
7. Verify app returns to authentication state.

---

## First-Time User

8. Sign in with account A with zero memberships.
9. Verify exactly two primary options appear:
   - Create New Vault.
   - Join Existing Vault.

---

## Create Vault

10. Choose Create New Vault.
11. Enter family/vault name.
12. Create vault.
13. Verify unique human-readable Vault ID appears.
14. Verify account A is owner.
15. Verify Dashboard opens.
16. Restart app.
17. Verify the vault is discovered again.

---

## Join Request

18. Sign out account A.
19. Sign in with account B.
20. Choose Join Existing Vault.
21. Enter invalid Vault ID.
22. Verify "Vault not found" behavior.
23. Enter account A's valid Vault ID.
24. Send join request.
25. Verify request remains pending.
26. Attempt duplicate pending request.
27. Verify duplicate is prevented.

---

## Owner Approval

28. Sign in as owner A.
29. Open Vault Settings.
30. Verify pending request from B appears.
31. Accept B.
32. Verify B becomes member.
33. Verify request is no longer pending.

---

## Member Access

34. Sign in as B.
35. Verify B now discovers the vault.
36. Verify B reaches Dashboard.
37. Verify B cannot accept/reject requests.
38. Verify B cannot remove owner.

---

## Rejection

39. Use another account C.
40. Send join request.
41. As owner A, reject C.
42. Verify C does not become member.
43. Verify architecture-defined re-request behavior works.

---

## Member Removal

44. As owner A, remove B.
45. Confirm removal.
46. Verify B loses future cloud authorization.
47. Verify owner cannot be removed through normal flow.

---

## Multiple Vaults

48. Create or join enough vaults so one user has 2+ memberships.
49. Verify VaultSelectionScreen appears.
50. Select a vault.
51. Verify selected vault becomes active for session.

---

## Regression

52. Create local SQLite entry.
53. Read entry.
54. Edit entry.
55. Delete entry.
56. Test Search.
57. Test category filters.
58. Test validation.
59. Verify Dashboard statistics.
60. Restart app.
61. Verify local data remains intact.

---

## Platforms

62. Test Android Google authentication.
63. Test Android vault creation/join flows.
64. Test Windows Google authentication according to approved architecture.
65. Test Windows vault creation/join flows.

---

## Static Analysis

66. Run:

`flutter analyze`

Expected:

`No issues found!`

---

# Risks

## 1. Windows Google authentication

Android and Windows authentication support may differ.

Mitigation:

Verify current packages and provider support before implementation.

---

## 2. Vault ID collisions

Human-readable IDs have finite combinations.

Mitigation:

Use sufficient entropy and verify uniqueness before creation.

---

## 3. Vault ID guessing

A public Vault ID could potentially be guessed.

Mitigation:

Knowing the ID permits only a join request, not private data access.

---

## 4. Join request spam

Someone knowing a Vault ID could repeatedly request access.

Mitigation:

Use one deterministic request per user per vault and prevent duplicate pending requests.

---

## 5. Partial join acceptance

Membership could be created without resolving request, or vice versa.

Mitigation:

Use atomic transaction/batch write.

---

## 6. Member removal

Removed user may still have local SQLite data.

Mitigation:

Do not pretend Phase 11 solves local secure cleanup. Address stronger revocation/local-data policy in Phase 13.

---

## 7. Cloud cost

Many families or inefficient listeners could increase usage.

Mitigation:

Use efficient one-time reads where possible and reserve real-time listeners for justified Phase 12 functionality.

---

## 8. Phase 12 identity

Local integer Entry IDs are insufficient as the sole multi-device identifier.

Mitigation:

Analyze and implement globally unique Entry IDs during Phase 12, not Phase 11.

---

# Exit Criteria

Phase 11 is complete when:

- Google authentication works.
- First-time user sees Create New Vault and Join Existing Vault.
- Vault creation works.
- Unique human-readable Vault ID works.
- Join request works.
- Owner approval/rejection works.
- Membership creation works.
- Member listing works.
- Member removal works.
- 0/1/2+ vault states work.
- Basic backend authorization works.
- Existing local SQLite functionality remains intact.
- Android is verified.
- Windows strategy is implemented according to approved analysis.
- No Phase 12 synchronization work is mixed into Phase 11.
- `flutter analyze` reports zero issues.
- Git commit created.
- Git push completed.

---

# Architect Notes

Phase 11 should remain practical.

Do not turn it into an enterprise identity platform.

The essential model is:

```text
Authentication answers:
Who is this user?

Vault creation answers:
Which shared family space exists?

Vault ID answers:
How can another family member find the vault?

Join request answers:
Who wants access?

Owner approval answers:
Should this account become a member?

Membership answers:
Who currently has access?

Phase 12 answers:
How do Entries continuously synchronize across authorized devices?
```

Keep these responsibilities separate.

The core product flow must remain:

```text
Google Sign-In
      ↓
0 vaults?
      ↓
Create New Vault OR Join Existing Vault
      ↓
Create:
Generate Vault ID → Become Owner

Join:
Enter Vault ID → Request Access → Owner Approves
      ↓
Shared membership established
```

Do not use email invitations.

Do not add unnecessary cryptographic invitation IDs.

Do not implement Entry synchronization prematurely.

Do not redesign unrelated existing screens.

Do not add unnecessary dependencies.

No implementation should begin until the Phase 11 architectural analysis is reviewed and approved.