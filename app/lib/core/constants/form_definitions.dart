import '../models/form_field_definition.dart';

/// Shared form definitions (Phase 05) — single source of truth mapping
/// each category label (matching [kCategories] from Phase 04) to its list
/// of fields. Adding a new category in the future only requires adding a
/// new entry here plus [kCategories] — no new screen is needed, since
/// [DynamicEntryScreen] renders every category generically from this map.
///
/// Phase 10 adds per-field `required` and `validationType` — rendering
/// (`type`) is unchanged; only validation metadata is new.
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
