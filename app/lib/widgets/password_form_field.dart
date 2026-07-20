import 'package:flutter/material.dart';

import 'password_strength_indicator.dart';

/// Phase 12 — reusable obscured password field with a show/hide eye
/// icon (smooth fade animation) and an optional live strength meter.
///
/// Visibility ([_obscured]) is always local, freshly-initialized
/// [State] — never accepted as a constructor parameter, never read from
/// anywhere persisted. Since [DynamicEntryScreen] rebuilds a brand new
/// [PasswordFormField] every time the Add/Edit screen itself is (re)
/// created, this naturally satisfies the Phase 12 requirement that
/// password visibility must always start hidden and never carry over
/// between openings — there is no state to carry over.
class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.showStrengthIndicator = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  /// Shown for the Add/Edit form's live password field. Not used when
  /// this widget is reused read-only-style elsewhere (it isn't, today —
  /// [EntryDetailsScreen] has its own simpler masked-value display).
  final bool showStrengthIndicator;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: IconButton(
              tooltip: _obscured ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscured = !_obscured),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Icon(
                  _obscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  key: ValueKey(_obscured),
                ),
              ),
            ),
          ),
          validator: widget.validator,
        ),
        if (widget.showStrengthIndicator)
          PasswordStrengthIndicator(password: widget.controller.text),
      ],
    );
  }
}
