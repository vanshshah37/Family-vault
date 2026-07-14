# Phase 10 — Input Validation & Form Hardening

---

## Phase Status

Status: Not Started

Previous Phase:
Phase 09 — Universal Search & Category Filtering ✅

Next Phase:
To be defined after Phase 10 completion.

---

# Objective

Add robust, configuration-driven input validation to the existing dynamic entry system so invalid or incomplete data cannot be saved during either Create or Edit flows.

Validation must be implemented centrally through the existing shared dynamic form architecture.

The implementation must preserve all functionality completed in Phases 01–09, including:

- Dashboard.
- Navigation.
- Universal Entry wizard.
- Dynamic category-based forms.
- SQLite persistence.
- Full CRUD.
- Live Dashboard statistics.
- Universal Search.
- Category filtering.
- Windows support.
- Android support.
- Existing Design System.

---

# Core Architectural Principle

Both Create and Edit already reuse the existing:

`DynamicEntryScreen`

Therefore, validation must be implemented once in the shared dynamic form system.

Do NOT:

- Duplicate validation between Create and Edit.
- Create separate validators for separate screens without architectural necessity.
- Put validation logic inside `ReviewEntryScreen`.
- Put validation logic inside `EditEntryScreen`.
- Put validation logic inside the repository.
- Put validation logic inside the database layer.

Expected flow:

Create or Edit

→ DynamicEntryScreen

→ Shared field definitions

→ Shared validation rules

→ Invalid:
Stay on form and show field-level errors

→ Valid:
Continue existing submission flow

---

# Scope

## Included

- Required-field validation.
- Field-level validation errors.
- Validation for both Create and Edit flows.
- Whitespace normalization.
- Phone-number validation where applicable.
- Email validation where applicable.
- Numeric validation where applicable.
- Date validation through the existing date-field architecture.
- Minimum and maximum length validation where genuinely appropriate.
- Validation driven by field configuration rather than category-specific screen logic.
- Preservation of existing form values after validation failure.
- Responsive validation-error display on Android and Windows.
- Existing Create flow preserved.
- Existing Edit flow preserved.

---

# Explicitly Excluded

Do NOT implement:

- Authentication.
- Master password validation.
- Encryption.
- Cloud sync.
- Google Sign-In.
- OTP verification.
- Email verification.
- Phone verification.
- Server-side validation.
- Network requests.
- External validation APIs.
- Password-strength checking unless an existing dynamic entry field explicitly requires it.
- Database schema changes.
- Database migrations.
- New SQLite tables.
- New dependencies unless absolutely unavoidable and explicitly approved.
- Riverpod.
- Provider.
- Streams.
- Global validation state.
- Form state persisted across app restarts.
- Duplicate detection.
- Cross-entry uniqueness checks.
- Search changes.
- Dashboard changes.
- CRUD redesign.
- UI redesign.
- New category types.
- New form fields unless required to correct an existing specification conflict.
- Advanced locale-aware phone validation.
- Country-specific phone libraries.
- Third-party form-validation packages.

---

# Existing Architecture To Reuse

The implementation must inspect and reuse the current:

- `lib/core/models/form_field_definition.dart`
- `lib/core/constants/form_definitions.dart`
- `lib/features/universal_entry/dynamic_entry_screen.dart`
- `lib/features/entries/edit_entry_screen.dart`
- `lib/features/universal_entry/review_entry_screen.dart`

The actual current codebase is the source of truth.

Do not assume field names, field types, constructor signatures, or model properties without reading the current files.

---

# Validation Ownership

Validation rules should be driven by field configuration.

Preferred architecture:

`FormFieldDefinition`

may be extended with validation metadata such as:

- `required`
- `minLength`
- `maxLength`
- validation type or equivalent metadata

However, the exact design must be determined during the analysis phase after inspecting the existing `FormFieldDefinition` model and current `form_definitions.dart`.

Do not create a large validation framework.

Do not create unnecessary abstractions.

The simplest configuration-driven solution that supports all current categories is preferred.

---

# Required-Field Validation

Fields marked as required must reject:

- Empty strings.
- Strings containing only whitespace.

Example:

Input:

`"     "`

Must be treated as empty.

Suggested message:

`This field is required`

Do not silently save whitespace-only required values.

---

# Whitespace Normalization

Before successful submission:

- Leading whitespace should be removed.
- Trailing whitespace should be removed.

Example:

Input:

`"  HDFC Bank  "`

Stored/submitted value:

`"HDFC Bank"`

Do not unexpectedly alter meaningful internal spaces.

Example:

`"State Bank of India"`

must remain:

`"State Bank of India"`

For multiline fields, analysis must determine whether simple outer trimming is sufficient. Do not introduce aggressive whitespace transformations without explicit justification.

---

# Phone Validation

Apply phone validation only to fields that semantically represent phone numbers.

Do not infer phone validation merely because a field uses a numeric keyboard.

Phone validation should:

- Reject clearly invalid input.
- Allow only the formats explicitly approved after analysis.
- Avoid pretending to provide international phone-number validation without a dedicated library.

For the current phase, a simple project-appropriate rule is preferred.

Possible baseline:

- Digits only.
- Exactly 10 digits for Indian mobile numbers.

However, this must be confirmed against the actual current field definitions during analysis.

Suggested error messages:

`Enter a valid 10-digit phone number`

Do not implement country-code handling unless existing requirements demand it.

---

# Email Validation

Apply email validation only to actual email fields.

Use a lightweight local validation rule.

Do not add a dependency solely for email validation.

The validator should reject obviously invalid values such as:

- `abc`
- `abc@`
- `@example.com`

and accept ordinary addresses such as:

- `name@example.com`

Do not attempt full RFC 5322 compliance.

Suggested message:

`Enter a valid email address`

---

# Numeric Validation

Fields configured as numeric must reject invalid non-numeric input where relevant.

Do not assume every numeric keyboard field has the same semantic rules.

Examples:

- Phone number: validate as phone, not generic number.
- Account number: may contain leading zeros and should generally remain a string.
- Monetary value: may require decimal handling if such a field currently exists.

The analysis must inspect actual current form definitions before assigning rules.

Do not convert string identifiers to integers unnecessarily.

---

# Date Validation

Existing date fields should continue using the current date-picker architecture.

A valid selected date should remain valid.

Do not introduce manual free-text date parsing unless the current implementation already permits manual date entry.

If date fields are required:

- No selected date → required-field error.

Do not add arbitrary past/future date restrictions unless explicitly required by the field's meaning and approved during analysis.

---

# Length Validation

Minimum or maximum length rules may be used only when semantically justified.

Examples that may be appropriate:

- Required identifiers with known fixed lengths.
- Phone numbers.
- Short labels where unrestricted length could break usability.

Do not add arbitrary limits to:

- Addresses.
- Notes.
- Descriptions.
- Other naturally variable text.

The analysis must identify exactly which current fields, if any, require length constraints.

---

# Optional Fields

Optional fields:

- May remain empty.
- Must not display a required error.
- If a non-empty optional field has a specific format rule, that format rule should still apply.

Example:

Optional email:

Empty:
Valid.

`abc`:
Invalid.

`name@example.com`:
Valid.

---

# Form-Level Behaviour

When the user presses the existing action button:

1. Validate every visible dynamic field.
2. If any field is invalid:
   - Do not navigate forward.
   - Do not save.
   - Keep all entered values intact.
   - Display field-level validation messages.
3. If all fields are valid:
   - Normalize values as approved.
   - Continue the existing Create or Edit submission flow.

No valid existing workflow should be broken.

---

# Create Flow

Existing flow:

Dashboard

→ FAB

→ Universal Entry

→ Category Selection

→ Owner Selection

→ Dynamic Entry

→ Review

→ Save

Required Phase 10 behavior:

If Dynamic Entry contains invalid data:

- Stay on Dynamic Entry.
- Show errors.
- Do not open Review.

If valid:

- Continue to Review exactly as before.

---

# Edit Flow

Existing flow:

Dashboard/Search

→ Entry List or Search Result

→ Entry Details

→ Edit

→ Dynamic Entry renderer reused by EditEntryScreen

→ Save

Required Phase 10 behavior:

If edited values are invalid:

- Stay on the form.
- Show errors.
- Do not update SQLite.

If valid:

- Continue the existing update flow exactly as before.

Validation behavior must be consistent between Create and Edit.

---

# Field-Level Error Presentation

Use Flutter's existing form validation architecture where appropriate:

- `Form`
- `GlobalKey<FormState>`
- `TextFormField`
- `validator`

The exact implementation must be determined after inspecting the current DynamicEntryScreen.

Errors should appear near the corresponding field.

Do not show all validation failures only through a SnackBar.

SnackBars may still be used for persistence failures, as already implemented in previous phases.

---

# Error Message Guidelines

Messages should be:

- Short.
- Specific.
- User-friendly.

Preferred examples:

- `This field is required`
- `Enter a valid email address`
- `Enter a valid 10-digit phone number`
- `Enter a valid number`
- `Minimum 3 characters required`
- `Maximum 100 characters allowed`

Avoid:

- Raw exceptions.
- Technical implementation details.
- Regex terminology.
- Database terminology.

---

# Configuration-Driven Requirement

The implementation must avoid logic like:

`if category == Personal ...`

`if category == Corporate ...`

`if category == Documents ...`

inside the form renderer for validation purposes.

Instead:

Category

→ Existing form definitions

→ Field definition

→ Validation metadata/rule

→ Shared validator

This ensures future fields and categories can adopt validation without creating new screen-level branches.

---

# Files Expected To Be Modified

Expected candidates:

- `lib/core/models/form_field_definition.dart`
- `lib/core/constants/form_definitions.dart`
- `lib/features/universal_entry/dynamic_entry_screen.dart`

Potentially:

- `lib/features/entries/edit_entry_screen.dart`

only if analysis proves a small compatibility change is necessary.

Do not modify other files without explicit architectural justification during analysis.

---

# New Files

No new files are required by default.

Do not create:

- validation_service.dart
- validation_repository.dart
- validation_provider.dart
- validation_controller.dart
- per-category validator files

unless analysis proves a genuine architectural necessity and the new file is explicitly approved before implementation.

For the current application scale, existing model/configuration/form files should be sufficient.

---

# Widget Hierarchy

Expected conceptual hierarchy:

DynamicEntryScreen

├── Scaffold

│   ├── AppBar

│   └── SafeArea

│       └── Form

│           └── Dynamic Field List

│               ├── TextFormField

│               ├── Multiline TextFormField

│               ├── Number TextFormField

│               └── Date TextFormField

│

└── Existing submission action

Validation must remain inside the shared form architecture.

---

# Data Flow

Create:

Field definitions

↓

DynamicEntryScreen renders fields

↓

User enters values

↓

User presses Continue/Review

↓

Form validates

↓

Invalid:
Stay + show field errors

↓

Valid:
Normalize values

↓

Build existing EntryValue list

↓

Continue to ReviewEntryScreen

Edit:

Existing Entry

↓

EditEntryScreen

↓

DynamicEntryScreen with initial values

↓

User edits values

↓

User presses Save

↓

Form validates

↓

Invalid:
Stay + show field errors

↓

Valid:
Normalize values

↓

Existing onSubmit callback

↓

Existing repository update flow

---

# State Requirements

Use only local form state.

Do not introduce:

- Application-wide validation state.
- Global variables.
- Riverpod providers.
- Provider.
- Streams.
- Database listeners.

Existing `TextEditingController`s may continue to be used.

All controllers must continue to be disposed correctly.

---

# Responsive Behaviour

Validation must work on:

- Android phones.
- Tablets.
- Windows desktop.

Requirements:

- Error text must not cause RenderFlex overflow.
- Form must remain scrollable when multiple errors increase field height.
- Submission controls must not be hidden behind Android system navigation.
- Use `SafeArea` where appropriate.
- Keyboard appearance must not make the active field inaccessible.
- Existing responsive behavior must not regress.

---

# Existing Data Compatibility

Existing saved entries from Phases 06–09 must remain readable and editable.

Important:

Older saved entries may contain values that would fail new Phase 10 validation rules.

The application must not crash when reading such entries.

During Edit:

- Existing invalid legacy values may be displayed.
- Validation should apply when the user attempts to save.

Do not automatically delete or mutate old entries.

Do not introduce a migration solely to enforce form validation.

---

# Search Compatibility

Phase 09 search must continue working.

Validation must not modify:

- Search architecture.
- Search matching rules.
- Category filtering.
- Search result navigation.

No Phase 09 files should be modified unless analysis proves it unavoidable.

---

# Database Compatibility

No database schema changes.

No migrations.

No new tables.

No raw SQL changes.

Validation happens before persistence.

The existing repository and database layers should remain unchanged unless analysis identifies an unavoidable compatibility issue.

---

# Design System

Use the existing `DESIGN_SYSTEM.md`.

Validation errors should follow Flutter/Material form conventions and the existing theme.

Do not hardcode a new unrelated visual language.

Do not redesign existing forms.

---

# Acceptance Criteria

Phase 10 is complete when:

- Required fields reject empty input.
- Required fields reject whitespace-only input.
- Validation errors appear at field level.
- Invalid Create flow cannot proceed to Review.
- Invalid Edit flow cannot update SQLite.
- Valid Create flow still works.
- Valid Edit flow still works.
- Entered values remain intact after validation failure.
- Leading/trailing whitespace is normalized before successful submission.
- Phone validation works where applicable.
- Email validation works where applicable.
- Numeric validation works where applicable.
- Date required validation works where applicable.
- Optional empty fields remain valid.
- Existing saved entries remain readable.
- Existing saved entries can be edited.
- Search remains operational.
- Dashboard remains operational.
- CRUD remains operational.
- Windows works.
- Android works.
- No database schema changes.
- No new dependencies unless explicitly approved.
- `flutter analyze` reports zero issues.

---

# Testing Checklist

## Required Fields

1. Leave a required field empty.
   - Error appears.
   - Cannot continue/save.

2. Enter spaces only.
   - Treated as empty.
   - Error appears.

3. Correct the value.
   - Error clears appropriately.
   - Form can proceed.

---

## Create Flow

4. Start creating an entry.
5. Submit invalid form.
   - Stay on Dynamic Entry.
   - No Review screen.
6. Correct errors.
7. Continue to Review.
8. Finish save.
9. Verify entry appears in category list and Search.

---

## Edit Flow

10. Open existing entry.
11. Edit a required field to empty.
12. Press Save.
    - Stay on form.
    - SQLite not updated.
13. Correct field.
14. Save.
15. Verify Details updates.
16. Restart app.
17. Verify valid edit persists.

---

## Whitespace

18. Enter:

`  HDFC Bank  `

19. Save.

20. Verify stored/displayed value is:

`HDFC Bank`

---

## Phone

21. Test empty required phone.
22. Test too-short phone.
23. Test letters in phone.
24. Test valid approved phone format.

---

## Email

25. Test:

`abc`

26. Test:

`abc@`

27. Test:

`@example.com`

28. Test:

`name@example.com`

---

## Date

29. Leave required date empty.
30. Verify error.
31. Select valid date.
32. Verify error resolves.

---

## Legacy Data

33. Open an entry saved before Phase 10.
34. Verify it still displays.
35. Edit it.
36. If existing values violate new rules, verify app remains stable and validation appears only when Save is attempted.

---

## Regression

37. Test Dashboard statistics.
38. Test category lists.
39. Test Details.
40. Test Edit.
41. Test Delete.
42. Test Universal Search.
43. Test category filtering.
44. Test Windows.
45. Test Android.
46. Run:

`flutter analyze`

Expected:

`No issues found!`

---

# Risks

## 1. Over-validation

Applying arbitrary validation rules may reject legitimate financial, document, or informational data.

Mitigation:

Only apply rules justified by actual field semantics.

---

## 2. Legacy data

Existing values may not satisfy newly introduced rules.

Mitigation:

Never crash or migrate automatically. Validate only when attempting a new Create or Edit submission.

---

## 3. Create/Edit inconsistency

Separate validation paths could behave differently.

Mitigation:

Keep validation in the shared DynamicEntryScreen architecture.

---

## 4. Controller lifecycle

Dynamic controllers must remain correctly initialized and disposed.

Mitigation:

Preserve existing controller-management behavior.

---

## 5. Date-field errors

Read-only date fields may require careful Form integration so required validation appears correctly.

Mitigation:

Use the same shared validation path and trigger form revalidation appropriately after date selection if needed.

---

## 6. Mobile layout expansion

Field-level errors increase vertical space and may expose keyboard or system-navigation issues.

Mitigation:

Keep form scrollable and mobile-safe.

---

## 7. Incorrect assumptions about current fields

The phase specification must not invent phone/email/numeric/date rules for fields that do not actually exist.

Mitigation:

The analysis phase must inspect current `form_definitions.dart` before finalizing exact rules.

---

# Dependencies

Requires:

- Phase 01 — Project Initialization.
- Phase 02 — Dashboard UI.
- Phase 03 — Navigation & Layout.
- Phase 04 — Universal Entry Wizard.
- Phase 05 — Dynamic Forms.
- Phase 06 — SQLite Persistence.
- Phase 07 — CRUD Engine.
- Phase 08 — Live Dashboard Data.
- Phase 09 — Universal Search & Category Filtering.

---

# Exit Criteria

Phase 10 is complete when:

- Shared validation works for Create and Edit.
- Required fields are enforced.
- Field-level errors work.
- Invalid forms cannot proceed or save.
- Valid forms continue existing workflows.
- Values are normalized safely.
- Existing persisted data remains compatible.
- Search remains functional.
- Dashboard remains functional.
- CRUD remains functional.
- Android is verified.
- Windows is verified.
- No schema changes were made.
- No unnecessary dependencies were added.
- `flutter analyze` reports zero issues.
- Git commit created.
- Git push completed.

---

# Architect Notes

Keep Phase 10 focused on validation and form hardening.

The most important architectural requirement is that Create and Edit share the same validation path through the existing DynamicEntryScreen.

Do not build a validation framework larger than the current application requires.

Do not blindly mark every field required or assign arbitrary regex rules.

Inspect the actual current form definitions first, identify which fields exist, then propose exact validation metadata and rules during analysis.

No implementation should begin until those field-level decisions are reviewed and approved.