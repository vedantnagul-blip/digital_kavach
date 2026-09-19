import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/firebase/user_repo.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// Role within a family group.
enum FamilyRole { guardian, elder }

/// A member of a family group.
@immutable
class FamilyMember {
  final String uid;
  final String displayName;
  final FamilyRole role;
  final DateTime linkedAt;
  final String? phoneNumber;

  const FamilyMember({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.linkedAt,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'role': role.name,
    'linkedAt': linkedAt.toIso8601String(),
    'phoneNumber': phoneNumber,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> j) => FamilyMember(
    uid: j['uid'] as String,
    displayName: j['displayName'] as String? ?? 'Unknown',
    role: j['role'] == 'elder' ? FamilyRole.elder : FamilyRole.guardian,
    linkedAt: j['linkedAt'] != null
        ? DateTime.parse(j['linkedAt'] as String)
        : DateTime.now(),
    phoneNumber: j['phoneNumber'] as String?,
  );
}

/// A family group document in Firestore.
@immutable
class FamilyGroup {
  final String id;
  final List<String> guardianUids;
  final List<String> elderUids;
  final String? pairCodeHash;
  final String status; // pending | active
  final DateTime createdAt;

  const FamilyGroup({
    required this.id,
    this.guardianUids = const [],
    this.elderUids = const [],
    this.pairCodeHash,
    this.status = 'pending',
    required this.createdAt,
  });

  List<String> get allUids => [...guardianUids, ...elderUids];

  factory FamilyGroup.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return FamilyGroup(
      id: doc.id,
      guardianUids: List<String>.from(d['guardianUids'] ?? []),
      elderUids: List<String>.from(d['elderUids'] ?? []),
      pairCodeHash: d['pairCodeHash'] as String?,
      status: d['status'] as String? ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// A red/amber alert event — NO content fields, enforced by security rules.
@immutable
class FamilyEvent {
  final String id;
  final String familyId;
  final String aboutUid;
  final String severity; // RED | AMBER
  final String pattern;
  final DateTime ts;

  const FamilyEvent({
    required this.id,
    required this.familyId,
    required this.aboutUid,
    required this.severity,
    required this.pattern,
    required this.ts,
  });

  /// Schema-exact map for Firestore write.
  /// Security rules reject any doc with extra keys.
  Map<String, dynamic> toEventDoc() => {
    'familyId': familyId,
    'aboutUid': aboutUid,
    'severity': severity,
    'pattern': pattern,
    'ts': Timestamp.fromDate(ts),
  };

  factory FamilyEvent.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return FamilyEvent(
      id: doc.id,
      familyId: d['familyId'] as String? ?? '',
      aboutUid: d['aboutUid'] as String? ?? '',
      severity: d['severity'] as String? ?? 'RED',
      pattern: d['pattern'] as String? ?? 'unknown',
      ts: (d['ts'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Alert level preference for a guardian.
enum AlertLevel { redOnly, redAndAmber }

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final familyRepoProvider = Provider<FamilyRepo>((ref) {
  return FamilyRepo(FirebaseFirestore.instance);
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Firestore operations for Family Shield.
///
/// **Privacy invariant:** event documents contain ONLY
/// `{familyId, aboutUid, severity, pattern, ts}` — never message content.
/// This is enforced by Firestore security rules (see firestore.rules).
class FamilyRepo {
  FamilyRepo(this._firestore);
  final FirebaseFirestore _firestore;

  // -- Pairing --------------------------------------------------------------

  /// Generate a 6-character crypto-random pair code.
  String generatePairCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      6,
          (i) => chars[(random + i * 7919) % chars.length],
    ).join();
  }

  /// Hash a pair code for storage (SHA-256).
  String hashPairCode(String code) {
    return sha256.convert(utf8.encode(code.toUpperCase())).toString();
  }

  /// Create a family draft with a pair code.
  Future<String> createFamilyDraft({
    required String guardianUid,
    required String pairCode,
  }) async {
    try {
      final docRef = _firestore.collection('families').doc();
      await docRef.set({
        'guardianUids': [guardianUid],
        'elderUids': [],
        'pairCodeHash': hashPairCode(pairCode),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw StorageException('family.create_failed: $e');
    }
  }

  /// Verify a pair code and join the elder to the family.
  Future<void> joinFamily({
    required String familyId,
    required String pairCode,
    required String elderUid,
  }) async {
    try {
      final doc = await _firestore.collection('families').doc(familyId).get();
      if (!doc.exists) {
        throw const ValidationException('family.not_found');
      }

      final family = FamilyGroup.fromFirestore(doc);
      final expectedHash = hashPairCode(pairCode);

      if (family.pairCodeHash != expectedHash) {
        throw const ValidationException('family.wrong_code');
      }

      if (family.guardianUids.contains(elderUid)) {
        throw const ValidationException('family.self_pair');
      }

      if (family.elderUids.contains(elderUid)) {
        throw const ValidationException('family.already_paired');
      }

      // Transactionally add elder
      await _firestore.runTransaction((txn) async {
        final freshDoc = await txn.get(doc.reference);
        if (!freshDoc.exists) return;

        final currentElders = List<String>.from(
          (freshDoc.data() as Map<String, dynamic>?)?['elderUids'] ?? [],
        );
        currentElders.add(elderUid);

        txn.update(doc.reference, {
          'elderUids': currentElders,
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Update elder's user doc with familyId
      await _firestore.collection('users').doc(elderUid).set(
        {'familyId': familyId},
        SetOptions(merge: true),
      );
    } on KavachException {
      rethrow;
    } catch (e) {
      throw StorageException('family.join_failed: $e');
    }
  }

  /// Unpair a member from the family.
  Future<void> unpair({
    required String familyId,
    required String memberUid,
    required String callerUid,
  }) async {
    try {
      final doc = _firestore.collection('families').doc(familyId);
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(doc);
        if (!snap.exists) return;

        final data = snap.data() as Map<String, dynamic>? ?? {};
        final guardians = List<String>.from(data['guardianUids'] ?? []);
        final elders = List<String>.from(data['elderUids'] ?? []);

        guardians.remove(memberUid);
        elders.remove(memberUid);

        if (guardians.isEmpty && elders.isEmpty) {
          txn.delete(doc);
        } else {
          txn.update(doc, {
            'guardianUids': guardians,
            'elderUids': elders,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Clear familyId from unpaired user
      await _firestore.collection('users').doc(memberUid).set(
        {'familyId': FieldValue.delete()},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw StorageException('family.unpair_failed: $e');
    }
  }

  // -- Family reads ---------------------------------------------------------

  /// Get the family group for a user.
  Future<FamilyGroup?> getFamilyForUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final familyId = userDoc.data()?['familyId'] as String?;
      if (familyId == null || familyId.isEmpty) return null;

      final famDoc = await _firestore.collection('families').doc(familyId).get();
      if (!famDoc.exists) return null;

      return FamilyGroup.fromFirestore(famDoc);
    } catch (e) {
      AppLogger.e('getFamilyForUser failed: $e', tag: 'family');
      return null;
    }
  }

  /// Resolve member details from UIDs.
  Future<List<FamilyMember>> resolveMembers(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      final futures = uids.map((uid) async {
        final doc = await _firestore.collection('users').doc(uid).get();
        final d = doc.data() ?? {};
        return FamilyMember(
          uid: uid,
          displayName: d['name'] as String? ?? 'Unknown',
          role: FamilyRole.guardian, // determined by caller context
          linkedAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          phoneNumber: d['phone'] as String?,
        );
      });
      return Future.wait(futures);
    } catch (e) {
      AppLogger.e('resolveMembers failed: $e', tag: 'family');
      return [];
    }
  }

  // -- Events (red-alert propagation) ---------------------------------------

  /// Write a red/amber alert event. Schema-exact — no content fields.
  Future<void> writeEvent(FamilyEvent event) async {
    try {
      await _firestore.collection('events').add(event.toEventDoc());
    } catch (e) {
      AppLogger.e('writeEvent failed: $e', tag: 'family');
    }
  }

  /// Listen for RED events for a family.
  Stream<List<FamilyEvent>> watchRedEvents(String familyId) {
    return _firestore
        .collection('events')
        .where('familyId', isEqualTo: familyId)
        .where('severity', isEqualTo: 'RED')
        .orderBy('ts', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(FamilyEvent.fromFirestore).toList());
  }

  /// Listen for RED + AMBER events for a family.
  Stream<List<FamilyEvent>> watchAllEvents(String familyId) {
    return _firestore
        .collection('events')
        .where('familyId', isEqualTo: familyId)
        .orderBy('ts', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(FamilyEvent.fromFirestore).toList());
  }

  /// Count events in the last 7 days for digest.
  Future<({int red, int amber})> countEventsLast7Days(
      String familyId,
      DateTime now,
      ) async {
    try {
      final weekAgo = Timestamp.fromDate(now.subtract(const Duration(days: 7)));
      final snap = await _firestore
          .collection('events')
          .where('familyId', isEqualTo: familyId)
          .where('ts', isGreaterThanOrEqualTo: weekAgo)
          .get();

      int red = 0, amber = 0;
      for (final doc in snap.docs) {
        final sev = doc.data()['severity'] as String?;
        if (sev == 'RED') red++;
        if (sev == 'AMBER') amber++;
      }
      return (red: red, amber: amber);
    } catch (e) {
      AppLogger.e('countEventsLast7Days failed: $e', tag: 'family');
      return (red: 0, amber: 0);
    }
  }
}