import 'dart:io';

import 'package:digital_kavach/data/firebase/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/errors/kavach_exception.dart';

import '../../core/utils/app_logger.dart';

/// Authentication repository: Google + Anonymous (guest), with guest→Google
/// upgrade that never duplicates identities.
///
/// Every public method wraps failures into [KavachException] subtypes.
/// A `null` return from [signInWithGoogle] means the user cancelled — this
/// is NOT surfaced as an error to the UI.
class AuthRepo {
  AuthRepo({
    FirebaseAuth? auth,
    GoogleSignIn? google,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn(scopes: <String>['email', 'profile']);

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(
          (User? u) => u == null ? null : AppUser.fromFirebase(u),
    );
  }

  AppUser? get currentUser {
    final User? u = _auth.currentUser;
    return u == null ? null : AppUser.fromFirebase(u);
  }

  /// Returns the signed-in [AppUser], or `null` if the user cancelled the
  /// Google account picker (which is a normal, non-error condition).
  Future<AppUser?> signInWithGoogle() async {
    return runCatching<AppUser?>(() async {
      try {
        final GoogleSignInAccount? account = await _google.signIn();
        if (account == null) return null;
        final GoogleSignInAuthentication gAuth = await account.authentication;
        final OAuthCredential cred = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken,
        );
        final UserCredential userCred =
        await _auth.signInWithCredential(cred);
        final User u = userCred.user!;
        return AppUser.fromFirebase(u);
      } on FirebaseAuthException catch (e, st) {
        AppLogger.e('signInWithGoogle firebase error', error: e, stackTrace: st);
        if (e.code == 'network-request-failed') {
          throw NetworkException(e.message);
        }
        throw AuthException(e.message ?? e.code);
      } on PlatformException catch (e, st) {
        AppLogger.e('signInWithGoogle platform error', error: e, stackTrace: st);
        if (e.code == 'network_error') throw NetworkException(e.message);
        if (e.code == 'sign_in_canceled') return null;
        throw AuthException(e.message ?? e.code);
      } on SocketException catch (e) {
        throw NetworkException(e.message);
      }
    });
  }

  Future<AppUser> signInGuest() async {
    return runCatching<AppUser>(() async {
      try {
        final UserCredential userCred = await _auth.signInAnonymously();
        return AppUser.fromFirebase(userCred.user!);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'network-request-failed') {
          throw NetworkException(e.message);
        }
        throw AuthException(e.message ?? e.code);
      }
    });
  }

  /// Upgrades a currently-signed-in anonymous user to a permanent Google
  /// identity. If the Google account already has an existing Firebase
  /// account (`credential-already-in-use`), signs into THAT account instead
  /// and returns it — the caller must reconcile any pending local data.
  Future<AppUser?> upgradeGuestToGoogle() async {
    return runCatching<AppUser?>(() async {
      final User? current = _auth.currentUser;
      if (current == null || !current.isAnonymous) {
        throw const AuthException('Not currently signed in as a guest.');
      }
      final GoogleSignInAccount? account = await _google.signIn();
      if (account == null) return null;
      final GoogleSignInAuthentication gAuth = await account.authentication;
      final OAuthCredential cred = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      try {
        final UserCredential linked =
        await current.linkWithCredential(cred);
        return AppUser.fromFirebase(linked.user!);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          // Fall through to normal sign-in with the existing account.
          final UserCredential userCred =
          await _auth.signInWithCredential(cred);
          return AppUser.fromFirebase(userCred.user!);
        }
        if (e.code == 'network-request-failed') {
          throw NetworkException(e.message);
        }
        throw AuthException(e.message ?? e.code);
      }
    });
  }

  Future<void> signOut() async {
    return runCatching(() async {
      try {
        await _google.signOut();
      } catch (_) {
        // signOut may fail if never signed in; safe to ignore.
      }
      await _auth.signOut();
    });
  }
}