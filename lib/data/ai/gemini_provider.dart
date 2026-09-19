import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import 'ai_provider.dart';
import 'prompt_builder.dart';
import 'verdict_parser.dart';

class GeminiProvider implements AiProviderClient {
  GeminiProvider({required this.apiKey, String? modelId})
      : _preferredModel = (modelId != null && modelId.isNotEmpty)
      ? modelId
      : 'gemini-1.5-flash',
        supportsVision = true;

  @override
  final String name = 'gemini';

  @override
  final bool supportsVision;

  final String apiKey;
  final String _preferredModel;

  @override
  Future<Verdict> analyze(ScanRequest req) async {
    return runCatching(() async {
      // List of candidate models to try automatically in sequence
      final List<String> modelsToTry = <String>{
        _preferredModel,
        'gemini-1.5-flash',
        'gemini-1.5-pro',
        'gemini-2.0-flash',
        'gemini-1.0-pro',
      }.toList();

      GenerativeAIException? lastAIException;

      for (final String currentModel in modelsToTry) {
        try {
          AppLogger.i('Gemini attempting model: $currentModel');

          final GenerativeModel model = GenerativeModel(
            model: currentModel,
            apiKey: apiKey,
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              temperature: 0.2,
            ),
            systemInstruction: Content.system(PromptBuilder.build(req).system),
          );

          final String userPrompt = PromptBuilder.build(req).user;
          final List<Part> parts = <Part>[TextPart(userPrompt)];

          if (req.imageBytes != null &&
              req.imageBytes!.isNotEmpty &&
              req.imageMime != null) {
            final Uint8List bytes = req.imageBytes is Uint8List
                ? req.imageBytes as Uint8List
                : Uint8List.fromList(req.imageBytes!);
            parts.add(DataPart(req.imageMime!, bytes));
          }

          final GenerateContentResponse response = await model
              .generateContent(<Content>[Content.multi(parts)])
              .timeout(const Duration(seconds: 12));

          final String? text = response.text;
          if (text == null || text.isEmpty) {
            throw const AiParseException('Gemini returned empty text');
          }

          AppLogger.i('Gemini SUCCESS with model: $currentModel');
          return VerdictParser.parse(text, AiProvider.gemini, currentModel);
        } on GenerativeAIException catch (e) {
          lastAIException = e;
          final String errStr = e.toString().toLowerCase();

          // If key is invalid or quota exceeded, stop trying other models with same bad key
          if (errStr.contains('429')) throw const QuotaExceededException();
          if (errStr.contains('403') || errStr.contains('401')) {
            throw const AiProviderException('gemini', 'Invalid API key from AI Studio');
          }

          // If model is 404 / not found on this account, log and try next model in loop!
          if (errStr.contains('not found') || errStr.contains('v1beta') || errStr.contains('404')) {
            AppLogger.w('Model $currentModel not available on this key, trying next model...');
            continue;
          }

          rethrow;
        } on TimeoutException catch (_) {
          throw const KavachTimeoutException();
        } on SocketException catch (e) {
          throw NetworkException(e.toString());
        }
      }

      // If all candidate models were rejected by Google
      throw AiProviderException(
        'gemini',
        lastAIException?.message ?? 'No compatible Gemini model found for this key.',
      );
    });
  }
}