import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/errors/kavach_exception.dart';

/// App-level user identity — decoupled from Firebase SDK types so the rest
/// of the app doesn't import `firebase_auth`.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.isGuest,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  final String uid;
  final bool isGuest;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  factory AppUser.fromFirebase(fb.User u) => AppUser(
    uid: u.uid,
    isGuest: u.isAnonymous,
    displayName: u.displayName,
    email: u.email,
    photoUrl: u.photoURL,
  );

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
  }) =>
      AppUser(
        uid: uid,
        isGuest: isGuest ?? this.isGuest,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.uid == uid && other.isGuest == isGuest;

  @override
  int get hashCode => Object.hash(uid, isGuest);
}

/// Firestore repository for the `users/{uid}` collection.
///
/// Schema (blueprint §7) — field names are contract-locked:
///   name, lang, mode ('elder'|'standard'), city?, familyId?,
///   consentAi (bool), createdAt (Timestamp)
///
/// Additional Phase 02 fields for DPDP posture & diagnostics:
///   consentTs (Timestamp), consentVersion (int), isGuest (bool), appVersion
class UserRepo {
  UserRepo(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Idempotent write of the user doc. Safe to call on every onboarding
  /// completion / re-run. `createdAt` is only stamped once (first write).
  Future<void> ensureUserDoc({
    required AppUser user,
    required String lang,
    required String mode, // 'standard' | 'elder'
    required bool consentAi,
    required DateTime consentTs,
    required int consentVersion,
    required String appVersion,
    String? city,
    String? familyId,
  }) async {
    return runCatching(() async {
      final DocumentReference<Map<String, dynamic>> docRef = _users.doc(user.uid);
      final DocumentSnapshot<Map<String, dynamic>> snap = await docRef.get();

      final Map<String, dynamic> data = <String, dynamic>{
        'name': user.displayName ?? '',
        'lang': lang,
        'mode': mode,
        if (city != null) 'city': city,
        if (familyId != null) 'familyId': familyId,
        'consentAi': consentAi,
        'consentTs': Timestamp.fromDate(consentTs),
        'consentVersion': consentVersion,
        'isGuest': user.isGuest,
        'appVersion': appVersion,
      };

      if (!snap.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
    });
  }

  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    return runCatching(() async {
      final DocumentSnapshot<Map<String, dynamic>> snap =
      await _users.doc(uid).get();
      return snap.data();
    });
  }

  Stream<Map<String, dynamic>?> watchUserDoc(String uid) {
    return _users.doc(uid).snapshots().map(
          (DocumentSnapshot<Map<String, dynamic>> s) => s.data(),
    );
  }
}