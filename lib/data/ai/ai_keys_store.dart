import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_kavach/features/onboarding/screens/consent_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/api_keys.dart';
import '../../core/utils/app_logger.dart';
import '../../data/firebase/user_repo.dart';
import '../../data/local/hive_boxes.dart';

class AiConfig {
  const AiConfig({this.geminiKey, this.grokKey, this.geminiModel, this.grokModel});
  final String? geminiKey;
  final String? grokKey;
  final String? geminiModel;
  final String? grokModel;
}

final Provider<AiKeysStore> aiKeysStoreProvider = Provider<AiKeysStore>((Ref ref) {
  return AiKeysStore(
    Hive.box<dynamic>(HiveBoxes.prefs),
    FirebaseFirestore.instance,
    ref.watch(userRepoProvider),
  );
});

class AiKeysStore {
  AiKeysStore(this._prefs, this._firestore, this._userRepo);

  final Box<dynamic> _prefs;
  final FirebaseFirestore _firestore;
  final UserRepo _userRepo;

  Future<AiConfig> getConfig() async {
    // 1. Hive override (Dev Panel)
    final String? localGemini = _prefs.get('dev_key_gemini') as String?;
    final String? localGrok = _prefs.get('dev_key_grok') as String?;
    String? localGModel = _prefs.get('dev_mod_gemini') as String?;
    final String? localGrModel = _prefs.get('dev_mod_grok') as String?;

    if (localGModel == 'gemini-2.5-flash-lite' || localGModel == null || localGModel.isEmpty) {
      localGModel = 'gemini-1.5-flash';
    }

    if (localGemini != null && localGemini.trim().isNotEmpty) {
      return AiConfig(
        geminiKey: localGemini.trim(),
        grokKey: (localGrok != null && localGrok.trim().isNotEmpty) ? localGrok.trim() : null,
        geminiModel: localGModel,
        grokModel: localGrModel ?? 'grok-beta',
      );
    }

    // 2. ApiKeys constants file (lib/core/utils/api_keys.dart)
    if (ApiKeys.gemini.trim().isNotEmpty) {
      return AiConfig(
        geminiKey: ApiKeys.gemini.trim(),
        grokKey: ApiKeys.grok.trim().isNotEmpty ? ApiKeys.grok.trim() : null,
        geminiModel: ApiKeys.geminiModel.isNotEmpty ? ApiKeys.geminiModel : 'gemini-1.5-flash',
        grokModel: ApiKeys.grokModel.isNotEmpty ? ApiKeys.grokModel : 'grok-beta',
      );
    }

    // 3. Firestore `config/ai_keys` (auth-gated)
    return runCatching(() async {
      final DocumentSnapshot<Map<String, dynamic>> snap =
      await _firestore.collection('config').doc('ai_keys').get();
      if (!snap.exists) return const AiConfig();
      final Map<String, dynamic> data = snap.data()!;
      return AiConfig(
        geminiKey: data['gemini'] as String?,
        grokKey: data['grok'] as String?,
        geminiModel: data['gemini_model'] as String? ?? 'gemini-1.5-flash',
        grokModel: data['grok_model'] as String? ?? 'grok-beta',
      );
    });
  }

  Future<void> saveLocalOverrides(AiConfig config) async {
    await _prefs.put('dev_key_gemini', config.geminiKey);
    await _prefs.put('dev_key_grok', config.grokKey);
    await _prefs.put('dev_mod_gemini', config.geminiModel);
    await _prefs.put('dev_mod_grok', config.grokModel);
    AppLogger.i('AiKeysStore: local overrides saved');
  }
}