import 'dart:async';

import 'package:flutter/widgets.dart';

import '../utils/auto_lock_duration.dart';
import 'security_preferences_store.dart';

/// The three states [VaultSecurityOverlay] can render for a signed-in
/// user: never configured (must complete mandatory first-time setup),
/// configured but locked (show the lock screen), or unlocked (show
/// nothing — the app underneath is fully visible).
enum VaultLockState { needsSetup, locked, unlocked }

/// Phase 13 — a lightweight singleton, deliberately NOT a full
/// `ChangeNotifier` with broad multi-listener machinery: its only
/// reactive surface is a single `ValueNotifier<VaultLockState>`, which
/// `VaultSecurityOverlay` listens to via `ValueListenableBuilder`. This
/// keeps the project consistent with its established "plain
/// `StatefulWidget`/`setState`, no state-management framework" pattern
/// as closely as a genuinely cross-cutting piece of state allows —
/// lock state must be readable/writable from places with no
/// ancestor/descendant relationship in the widget tree (a lifecycle
/// callback, a background timer, "Lock Now" buried in Security
/// Settings, the Sign Out button in Vault Settings), which is the one
/// thing plain `setState` genuinely can't reach across.
///
/// Completely independent from Firebase Authentication: this class
/// never imports `firebase_auth` and knows nothing about sign-in
/// state. `VaultSecurityOverlay` is the one place that bridges the two
/// (checking `FirebaseAuth.instance.currentUser` alongside this
/// controller's state, and calling [lock] whenever a sign-out is
/// observed) — per the approved decision to keep vault-lock and
/// Firebase auth structurally separate.
class VaultLockController with WidgetsBindingObserver {
  VaultLockController._internal();

  static final VaultLockController instance = VaultLockController._internal();

  final ValueNotifier<VaultLockState> state =
      ValueNotifier<VaultLockState>(VaultLockState.locked);

  Timer? _timer;
  AutoLockDuration _autoLockDuration = AutoLockDuration.threeMinutes;
  DateTime? _backgroundedAt;
  bool _initialized = false;

  /// Called once from `main()`. Reads whether a PIN has ever been set
  /// (deciding [VaultLockState.needsSetup] vs [VaultLockState.locked])
  /// and the saved Auto-Lock Timer preference, then registers for
  /// lifecycle callbacks. A cold start always begins at `needsSetup` or
  /// `locked` — never `unlocked` — which is what makes "app restart"
  /// an always-on lock trigger (per the approved decision) with no
  /// dedicated exit-detection code needed: a fresh process simply has
  /// no unlocked session in memory yet.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _autoLockDuration = await SecurityPreferencesStore.loadAutoLockDuration();
    final configured = await SecurityPreferencesStore.isSecurityConfigured();
    state.value =
        configured ? VaultLockState.locked : VaultLockState.needsSetup;

    WidgetsBinding.instance.addObserver(this);
  }

  /// Called once mandatory first-time PIN setup finishes.
  void completeSetup() {
    state.value = VaultLockState.unlocked;
    _armFullTimer();
  }

  /// Called after successful PIN or biometric authentication.
  void unlock() {
    state.value = VaultLockState.unlocked;
    _armFullTimer();
  }

  /// Manual "Lock Now" (locks immediately, no confirmation — per the
  /// approved decision), the Firebase sign-out safety net in
  /// [VaultSecurityOverlay], and the auto-lock timer itself all funnel
  /// through this same method.
  ///
  /// Bug fix: previously guarded with `if (state.value ==
  /// VaultLockState.unlocked)` before writing — redundant, since
  /// `ValueNotifier` already no-ops an identical write on its own, and a
  /// guard here only added a way for "Lock Now" to silently do nothing
  /// if `state.value` were ever anything other than exactly `unlocked`
  /// at call time. Unconditional and idempotent now: always cancels the
  /// timer and always sets `locked`, regardless of the prior value.
  void lock() {
    _cancelTimer();
    _backgroundedAt = null;
    state.value = VaultLockState.locked;
  }

  /// Called on every user pointer interaction while unlocked (see
  /// `ActivityDetector`) — resets the inactivity countdown.
  void recordActivity() {
    if (state.value == VaultLockState.unlocked) {
      _armFullTimer();
    }
  }

  /// Called when the user changes the Auto-Lock Timer in Security
  /// Settings — persists it and, if currently unlocked, re-arms
  /// immediately with the new duration.
  Future<void> setAutoLockDuration(AutoLockDuration duration) async {
    _autoLockDuration = duration;
    await SecurityPreferencesStore.saveAutoLockDuration(duration);
    if (state.value == VaultLockState.unlocked) {
      _armFullTimer();
    }
  }

  void _armFullTimer() => _armTimerFor(_autoLockDuration.duration);

  /// Bug fix: a `Duration.zero` foreground timer (from the "Immediately"
  /// option) previously fired on the very next event-loop tick after
  /// being armed — which happens inside `unlock()`/`recordActivity()`
  /// themselves, so the vault re-locked almost instantly after every
  /// successful unlock ("Immediate auto-lock creates an unlock loop").
  /// "Immediately" still locks the instant the app backgrounds (handled
  /// separately and explicitly in [didChangeAppLifecycleState]) — it
  /// just no longer arms a self-defeating zero-delay foreground timer,
  /// since there's no meaningful "foreground idle" moment shorter than
  /// the unlock action itself.
  void _armTimerFor(Duration? duration) {
    _cancelTimer();
    if (duration == null || duration == Duration.zero) return;
    _timer = Timer(duration, lock);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reconciles "moves to background," "resumes after timeout," and
  /// the single configurable Auto-Lock Timer into one mechanism (see
  /// the Phase 13 analysis §3): one clock, one duration, so that
  /// "Never" disables background-lock and foreground-inactivity-lock
  /// uniformly, rather than treating them as two independent rules
  /// that could disagree with the user's own timer choice.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (state.value != VaultLockState.unlocked) return;

    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= DateTime.now();
        if (_autoLockDuration.duration == Duration.zero) {
          // "Immediately" locks the instant the app leaves the
          // foreground, rather than waiting for a resume to notice.
          lock();
        } else {
          // Stop the foreground countdown — Dart timers aren't
          // guaranteed to keep firing while the OS may fully suspend
          // the process, so the authoritative check happens via
          // wall-clock time on resume instead, below.
          _cancelTimer();
        }
        break;
      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;
        _backgroundedAt = null;
        if (backgroundedAt == null) break;

        final duration = _autoLockDuration.duration;
        if (duration == null) break; // "Never".

        final elapsed = DateTime.now().difference(backgroundedAt);
        if (elapsed >= duration) {
          lock();
        } else {
          _armTimerFor(duration - elapsed);
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}
