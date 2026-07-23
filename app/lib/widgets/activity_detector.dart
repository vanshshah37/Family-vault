import 'package:flutter/widgets.dart';

import '../services/vault_lock_controller.dart';

/// Phase 13 — wraps the always-mounted app content (see
/// `VaultSecurityOverlay`) so any user interaction resets the
/// auto-lock inactivity countdown. Purely observes — `translucent` hit
/// testing means it never consumes or alters the underlying content's
/// own taps/scrolling.
class ActivityDetector extends StatelessWidget {
  const ActivityDetector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => VaultLockController.instance.recordActivity(),
      child: child,
    );
  }
}
