import 'package:cloud_functions/cloud_functions.dart';

class FamilyInvite {
  const FamilyInvite({
    required this.familyId,
    required this.pairCode,
    required this.expiresAt,
  });

  final String familyId;
  final String pairCode;
  final DateTime expiresAt;
}

class FamilyPairingService {
  FamilyPairingService({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<FamilyInvite> createInvite() async {
    final callable = _functions.httpsCallable('createFamilyInvite');
    final response = await callable.call();

    final data = Map<String, dynamic>.from(response.data as Map);

    return FamilyInvite(
      familyId: data['familyId'] as String,
      pairCode: data['pairCode'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (data['expiresAt'] as num).toInt(),
      ),
    );
  }

  Future<void> joinFamily({
    required String familyId,
    required String pairCode,
  }) async {
    final callable = _functions.httpsCallable('joinFamilyWithInvite');

    await callable.call({
      'familyId': familyId.trim(),
      'pairCode': pairCode.trim().toUpperCase(),
    });
  }
}