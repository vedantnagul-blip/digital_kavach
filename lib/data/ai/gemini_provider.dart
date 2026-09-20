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
      : _preferredModel = (modelId != null && modelId.isNotEmpty && modelId != 'gemini-3.6-flash')
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
      // List of candidate models to try automatically in sequence.
      // gemini-1.5-flash and gemini-2.0-flash have the highest free-tier quotas (1500 req/day).
      final List<String> modelsToTry = <String>{
        _preferredModel,
        'gemini-1.5-flash',
        'gemini-2.0-flash',
        'gemini-1.5-flash-8b',
        'gemini-2.5-flash',
        'gemini-1.5-pro',
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
              temperature: 0.1,
              maxOutputTokens: 600,
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

          // If key is invalid (401/403), stop trying
          if (errStr.contains('403') || errStr.contains('401') || errStr.contains('api_key_invalid')) {
            throw const AiProviderException('gemini', 'Invalid API key from AI Studio');
          }

          // If current model hit a quota limit, 503 high demand, 429 rate limit, or model not found:
          // Smoothly fall back to the next available candidate model in the list!
          if (errStr.contains('quota') ||
              errStr.contains('503') ||
              errStr.contains('high demand') ||
              errStr.contains('unavailable') ||
              errStr.contains('resource_exhausted') ||
              errStr.contains('429') ||
              errStr.contains('rate limit') ||
              errStr.contains('not found') ||
              errStr.contains('v1beta') ||
              errStr.contains('404') ||
              errStr.contains('deprecated') ||
              errStr.contains('no longer available')) {
            AppLogger.w('Model $currentModel unavailable ($errStr). Falling back to next model...');
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
        lastAIException?.message ?? 'No compatible Gemini model available for this key.',
      );
    });
  }
}