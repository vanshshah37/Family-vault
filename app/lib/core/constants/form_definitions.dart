import '../models/form_field_definition.dart';

/// Shared form definitions (Phase 05) — single source of truth mapping
/// each category label (matching [kCategories] from Phase 04) to its list
/// of fields. Adding a new category in the future only requires adding a
/// new entry here plus [kCategories] — no new screen is needed, since
/// [DynamicEntryScreen] renders every category generically from this map.
///
/// Phase 10 adds per-field `required` and `validationType` — rendering
/// (`type`) is unchanged; only validation metadata is new.
///
/// Phase 12 adds `Website`/`Username`/`Password`/`Notes` fields to
/// 'Share Market' — the one existing category that already implies an
/// online account (a broker/trading-account login), and so far the only
/// category with any field marked `isPassword`/`isUsername`/
/// `isSearchable`. This is a deliberate, flagged assumption rather than
/// an instruction from Phase 12's spec (which never named a category) —
/// every other category is untouched, and these four new fields are all
/// optional (`required: false`), so existing 'Share Market' entries
/// remain fully valid without needing to be re-saved.
const Map<String, List<FormFieldDefinition>> kFormDefinitions = {
  'Personal': [
    FormFieldDefinition(
      label: 'Name',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(
      label: 'Email',
      type: FormFieldType.text,
      validationType: ValidationType.email,
    ),
    FormFieldDefinition(
      label: 'Phone',
      type: FormFieldType.number,
      validationType: ValidationType.digitsOnly,
    ),
    FormFieldDefinition(label: 'Address', type: FormFieldType.multiline),
  ],
  'Corporate': [
    FormFieldDefinition(
      label: 'Company Name',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(label: 'GST Number', type: FormFieldType.text),
    FormFieldDefinition(
      label: 'Registration Number',
      type: FormFieldType.text,
    ),
  ],
  'Share Market': [
    FormFieldDefinition(
      label: 'Broker',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(label: 'Demat Number', type: FormFieldType.text),
    FormFieldDefinition(label: 'Trading Account', type: FormFieldType.text),
    // --- Phase 12: login fields for the broker's online portal ---
    FormFieldDefinition(
      label: 'Website',
      type: FormFieldType.text,
      isSearchable: true,
    ),
    FormFieldDefinition(
      label: 'Username',
      type: FormFieldType.text,
      isUsername: true,
      isSearchable: true,
    ),
    FormFieldDefinition(
      label: 'Password',
      type: FormFieldType.text,
      isPassword: true,
    ),
    FormFieldDefinition(
      label: 'Notes',
      type: FormFieldType.multiline,
      isSearchable: true,
    ),
  ],
  'Joint': [
    FormFieldDefinition(
      label: 'Primary Holder',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(
      label: 'Secondary Holder',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(label: 'Relationship', type: FormFieldType.text),
  ],
  'Documents': [
    FormFieldDefinition(
      label: 'Document Name',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(label: 'Document Type', type: FormFieldType.text),
    FormFieldDefinition(label: 'Issue Date', type: FormFieldType.date),
  ],
  'Information': [
    FormFieldDefinition(
      label: 'Title',
      type: FormFieldType.text,
      required: true,
    ),
    FormFieldDefinition(label: 'Description', type: FormFieldType.multiline),
  ],
};
