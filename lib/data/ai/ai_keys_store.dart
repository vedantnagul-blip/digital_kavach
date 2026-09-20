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
  const AiConfig({
    this.geminiKey,
    this.grokKey,
    this.chatgptKey,
    this.geminiModel,
    this.grokModel,
    this.chatgptModel,
  });

  final String? geminiKey;
  final String? grokKey;
  final String? chatgptKey;
  final String? geminiModel;
  final String? grokModel;
  final String? chatgptModel;
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
    final String? localChatGpt = _prefs.get('dev_key_chatgpt') as String?;
    String? localGModel = _prefs.get('dev_mod_gemini') as String?;
    final String? localGrModel = _prefs.get('dev_mod_grok') as String?;
    final String? localChatGptModel = _prefs.get('dev_mod_chatgpt') as String?;

    if (localGModel == null ||
        localGModel.isEmpty ||
        localGModel == 'gemini-3.6-flash' ||
        localGModel == 'gemini-1.5-pro' ||
        localGModel == 'gemini-2.5-flash-lite') {
      localGModel = 'gemini-1.5-flash';
    }

    final bool hasLocalGemini = localGemini != null && localGemini.trim().isNotEmpty;
    final bool hasLocalGrok = localGrok != null && localGrok.trim().isNotEmpty;
    final bool hasLocalChatGpt = localChatGpt != null && localChatGpt.trim().isNotEmpty;

    if (hasLocalGemini || hasLocalGrok || hasLocalChatGpt) {
      return AiConfig(
        geminiKey: hasLocalGemini ? localGemini!.trim() : (ApiKeys.gemini.trim().isNotEmpty ? ApiKeys.gemini.trim() : null),
        grokKey: hasLocalGrok ? localGrok!.trim() : (ApiKeys.grok.trim().isNotEmpty ? ApiKeys.grok.trim() : null),
        chatgptKey: hasLocalChatGpt ? localChatGpt!.trim() : (ApiKeys.chatgpt.trim().isNotEmpty ? ApiKeys.chatgpt.trim() : null),
        geminiModel: localGModel,
        grokModel: (localGrModel != null && localGrModel.isNotEmpty && localGrModel != 'grok-beta') ? localGrModel : 'llama-3.3-70b-versatile',
        chatgptModel: (localChatGptModel != null && localChatGptModel.isNotEmpty) ? localChatGptModel : 'gpt-4o-mini',
      );
    }

    // 2. ApiKeys constants file (lib/core/utils/api_keys.dart)
    final String groqOrGrok = ApiKeys.groq.trim().isNotEmpty
        ? ApiKeys.groq.trim()
        : ApiKeys.grok.trim();

    if (ApiKeys.gemini.trim().isNotEmpty || groqOrGrok.isNotEmpty || ApiKeys.chatgpt.trim().isNotEmpty) {
      return AiConfig(
        geminiKey: ApiKeys.gemini.trim().isNotEmpty ? ApiKeys.gemini.trim() : null,
        grokKey: groqOrGrok.isNotEmpty ? groqOrGrok : null,
        chatgptKey: ApiKeys.chatgpt.trim().isNotEmpty ? ApiKeys.chatgpt.trim() : null,
        geminiModel: ApiKeys.geminiModel.isNotEmpty ? ApiKeys.geminiModel : 'gemini-1.5-flash',
        grokModel: ApiKeys.grokModel.isNotEmpty ? ApiKeys.grokModel : 'llama-3.3-70b-versatile',
        chatgptModel: ApiKeys.chatgptModel.isNotEmpty ? ApiKeys.chatgptModel : 'gpt-4o-mini',
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
        chatgptKey: data['chatgpt'] as String? ?? data['openai'] as String?,
        geminiModel: data['gemini_model'] as String? ?? 'gemini-1.5-flash',
        grokModel: data['grok_model'] as String? ?? 'llama-3.3-70b-versatile',
        chatgptModel: data['chatgpt_model'] as String? ?? 'gpt-4o-mini',
      );
    });
  }

  Future<void> saveLocalOverrides(AiConfig config) async {
    await _prefs.put('dev_key_gemini', config.geminiKey);
    await _prefs.put('dev_key_grok', config.grokKey);
    await _prefs.put('dev_key_chatgpt', config.chatgptKey);
    await _prefs.put('dev_mod_gemini', config.geminiModel);
    await _prefs.put('dev_mod_grok', config.grokModel);
    await _prefs.put('dev_mod_chatgpt', config.chatgptModel);
    AppLogger.i('AiKeysStore: local overrides saved');
  }
}
