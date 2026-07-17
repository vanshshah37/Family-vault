import 'dart:io';

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Auth + the platform-specific Google Sign-In flow
/// behind one interface, mirroring [DatabaseService]'s "only this file
/// talks to the SDK" pattern.
///
/// Android uses the official `google_sign_in` plugin. Windows has no
/// official `google_sign_in` support, so it uses `desktop_webview_auth`
/// — a native-WebView OAuth flow maintained by Invertase (FlutterFire's
/// own maintainers) — to obtain a Google access token, which is then fed
/// into the same `GoogleAuthProvider.credential` /
/// `signInWithCredential` call Android uses. Both platforms therefore
/// land on the same Firebase Auth UID for the same Google account.
///
/// Updated for `google_sign_in` 7.2.0: the plugin moved from a
/// per-instance `GoogleSignIn()` + `signIn()` API to a singleton
/// (`GoogleSignIn.instance`) that must be explicitly `initialize()`d
/// once, authenticates via `authenticate()` (which throws
/// `GoogleSignInException` on cancellation rather than returning null),
/// and exposes `authentication` synchronously with only an `idToken`
/// (no more `accessToken` from that object — access tokens now come
/// from a separate `authorizationClient`, which Family Vault doesn't
/// need since it only requires identity, not additional Google API
/// scopes). None of this changes [AuthService]'s own public API —
/// [signInWithGoogle] and [signOut] still behave exactly as before from
/// every caller's point of view.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  // SETUP REQUIRED: replace with the OAuth 2.0 "Web application" client
  // created for this project in Google Cloud Console — see the Windows
  // setup section in desktop_webview_auth's README. This client is
  // distinct from the Android OAuth client Firebase Console generates
  // automatically; Windows needs its own.
  static const String _windowsGoogleClientId =
    '736359499529-4f3tdlidnp40eqrundcs7frf13o4qtmp.apps.googleusercontent.com';

  static const String _windowsGoogleRedirectUri =
    'https://family-vault-2bf9d.firebaseapp.com/__/auth/handler';

  /// `GoogleSignIn.instance` (7.x) must be `initialize()`d exactly once
  /// before `authenticate()`/`signOut()` are called. Guarded here so
  /// every call site can just call [_ensureGoogleSignInInitialized]
  /// without worrying about re-initializing.
  bool _isGoogleSignInInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with Google, branching by platform. Returns `null` if the
  /// user cancelled the flow (not an error — callers should treat a null
  /// result as "return to idle", not "show an error").
  Future<UserCredential?> signInWithGoogle() {
    if (Platform.isWindows) {
      return _signInWithGoogleOnWindows();
    }
    return _signInWithGoogleOnAndroid();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _isGoogleSignInInitialized = true;
  }

  Future<UserCredential?> _signInWithGoogleOnAndroid() async {
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount googleUser;
    try {
      // 7.x: authenticate() replaces the old signIn(); it never returns
      // null — cancellation is reported as a GoogleSignInException with
      // code `canceled` instead.
      googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User cancelled the account picker.
      }
      rethrow;
    }

    // 7.x: `authentication` is now a synchronous getter and only
    // carries an idToken — sufficient on its own for
    // signInWithCredential, since Family Vault only needs identity, not
    // additional Google API access.
    final idToken = googleUser.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential?> _signInWithGoogleOnWindows() async {
    final result = await DesktopWebviewAuth.signIn(
      GoogleSignInArgs(
        clientId: _windowsGoogleClientId,
        redirectUri: _windowsGoogleRedirectUri,
        scope: 'email',
      ),
    );
    if (result == null) return null; // User closed the WebView.

    final credential = GoogleAuthProvider.credential(
      accessToken: result.accessToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs out of Firebase Auth and, on Android, the Google Sign-In
  /// singleton too. Windows has no equivalent session to clear — the
  /// WebView flow doesn't persist a native session the way the Android
  /// plugin does.
  Future<void> signOut() async {
    if (!Platform.isWindows) {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    }
    await _firebaseAuth.signOut();
  }
}
