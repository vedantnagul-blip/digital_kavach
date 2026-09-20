import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import 'ai_provider.dart';
import 'prompt_builder.dart';
import 'verdict_parser.dart';

/// Groq / xAI / OpenAI compatible LLM provider.
///
/// Automatically routes based on API key prefix:
/// - `gsk_...` -> Groq Cloud (Free Llama 3.3 70B & 8B at 500+ tokens/sec)
/// - `xai-...` -> xAI Grok (grok-2-latest)
/// - `sk-...`  -> OpenAI (gpt-4o-mini)
class GrokProvider implements AiProviderClient {
  GrokProvider({required this.apiKey, String? modelId})
      : _preferredModel = (modelId != null && modelId.trim().isNotEmpty)
            ? modelId.trim()
            : (apiKey.trim().startsWith('gsk_')
                ? 'llama-3.3-70b-versatile'
                : 'grok-2-latest'),
        supportsVision = false;

  @override
  final String name = 'grok';

  @override
  final bool supportsVision;

  final String apiKey;
  final String _preferredModel;

  bool get isGroq => apiKey.trim().startsWith('gsk_');
  bool get isOpenAi =>
      apiKey.trim().startsWith('sk-') && !apiKey.trim().startsWith('gsk_');

  Uri get _endpoint {
    if (isGroq) {
      return Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    }
    if (isOpenAi) {
      return Uri.parse('https://api.openai.com/v1/chat/completions');
    }
    return Uri.parse('https://api.x.ai/v1/chat/completions');
  }

  @override
  Future<Verdict> analyze(ScanRequest req) async {
    return runCatching(() async {
      final http.Client client = http.Client();
      try {
        final BuiltPrompt prompt = PromptBuilder.build(req);

        // Sanitize model candidates based on provider
        final List<String> modelsToTry = <String>[];
        if (isGroq) {
          // If preferred model is a valid Groq model name, try it first
          if (!_preferredModel.contains('grok') && _preferredModel.isNotEmpty) {
            modelsToTry.add(_preferredModel);
          }
          modelsToTry.addAll(<String>[
            'llama-3.3-70b-versatile',
            'llama-3.1-8b-instant',
            'llama-guard-3-8b',
          ]);
        } else if (isOpenAi) {
          modelsToTry.addAll(<String>[
            _preferredModel,
            'gpt-4o-mini',
            'gpt-4o',
          ]);
        } else {
          modelsToTry.addAll(<String>[
            _preferredModel,
            'grok-2-latest',
            'grok-2-1212',
          ]);
        }

        String? lastErrorMessage;

        for (final String currentModel in modelsToTry.toSet()) {
          AppLogger.i(
              'LLM ($name) attempting model: $currentModel on endpoint: $_endpoint');

          // Attempt with JSON mode first, then retry without if provider rejects it
          for (final bool useJsonFormat in <bool>[true, false]) {
            final Map<String, dynamic> body = <String, dynamic>{
              'model': currentModel,
              'messages': <Map<String, dynamic>>[
                <String, String>{
                  'role': 'system',
                  'content': '${prompt.system}\nYou must output a JSON object.'
                },
                <String, String>{
                  'role': 'user',
                  'content': '${prompt.user}\nRespond in valid JSON format.'
                },
              ],
              'temperature': 0.1,
              'max_tokens': 600, // Token budget: ensures fast completion <500ms and prevents cost overrun
            };

            if (useJsonFormat) {
              body['response_format'] = <String, String>{
                'type': 'json_object'
              };
            }

            final http.Response res = await client
                .post(
                  _endpoint,
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ${apiKey.trim()}',
                  },
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 15));

            if (res.statusCode == 429) throw const QuotaExceededException();
            if (res.statusCode == 401 || res.statusCode == 403) {
              throw AiProviderException(
                name,
                isGroq
                    ? 'Invalid Groq API Key from console.groq.com'
                    : 'Invalid API Key or unauthorized account',
              );
            }

            if (res.statusCode == 200) {
              AppLogger.i('$name SUCCESS with model: $currentModel');
              return _parseOrThrow(res.body, currentModel);
            }

            // Extract error message from provider
            String msg = 'HTTP ${res.statusCode}';
            try {
              final Map<String, dynamic> errJson =
                  jsonDecode(res.body) as Map<String, dynamic>;
              if (errJson.containsKey('error') && errJson['error'] is Map) {
                msg = (errJson['error'] as Map)['message']?.toString() ?? msg;
              } else if (errJson.containsKey('message')) {
                msg = errJson['message'].toString();
              }
            } catch (_) {
              if (res.body.isNotEmpty) msg = res.body;
            }

            lastErrorMessage = msg;
            AppLogger.w('$name model $currentModel (json=$useJsonFormat) failed: $msg');

            // If error is decommissioned or model not found, no need to retry with useJsonFormat=false
            if (msg.toLowerCase().contains('decommissioned') ||
                msg.toLowerCase().contains('not found') ||
                msg.toLowerCase().contains('does not exist')) {
              break;
            }
          }
        }

        throw AiProviderException(name, lastErrorMessage ?? 'HTTP Error');
      } on TimeoutException catch (_) {
        throw const KavachTimeoutException();
      } on SocketException catch (e) {
        throw NetworkException(e.toString());
      } finally {
        client.close();
      }
    });
  }

  Verdict _parseOrThrow(String body, String model) {
    final Map<String, dynamic> j = jsonDecode(body) as Map<String, dynamic>;
    final String content = j['choices'][0]['message']['content'] as String;
    return VerdictParser.parse(content, AiProvider.grok, model);
  }
}
