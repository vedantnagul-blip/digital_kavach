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

/// Official OpenAI / ChatGPT provider client.
///
/// Supports GPT-4o-mini, GPT-4o, and GPT-3.5-turbo models with JSON formatting.
class ChatGptProvider implements AiProviderClient {
  ChatGptProvider({required this.apiKey, String? modelId})
      : _preferredModel = (modelId != null && modelId.trim().isNotEmpty)
            ? modelId.trim()
            : 'gpt-4o-mini',
        supportsVision = true;

  @override
  final String name = 'chatgpt';

  @override
  final bool supportsVision;

  final String apiKey;
  final String _preferredModel;

  static final Uri _endpoint =
      Uri.parse('https://api.openai.com/v1/chat/completions');

  @override
  Future<Verdict> analyze(ScanRequest req) async {
    return runCatching(() async {
      final http.Client client = http.Client();
      try {
        final BuiltPrompt prompt = PromptBuilder.build(req);

        final List<String> modelsToTry = <String>{
          _preferredModel,
          'gpt-4o-mini',
          'gpt-4o',
          'gpt-3.5-turbo',
        }.toList();

        String? lastErrorMessage;

        for (final String currentModel in modelsToTry) {
          AppLogger.i('ChatGPT attempting model: $currentModel');

          final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
            <String, String>{
              'role': 'system',
              'content': '${prompt.system}\nYou must output a strictly valid JSON object.',
            },
          ];

          // Handle multimodal vision if image attached
          if (req.imageBytes != null &&
              req.imageBytes!.isNotEmpty &&
              req.imageMime != null) {
            final String base64Image = base64Encode(req.imageBytes!);
            messages.add(<String, dynamic>{
              'role': 'user',
              'content': <dynamic>[
                <String, String>{
                  'type': 'text',
                  'text': '${prompt.user}\nRespond in valid JSON format.',
                },
                <String, dynamic>{
                  'type': 'image_url',
                  'image_url': <String, String>{
                    'url': 'data:${req.imageMime};base64,$base64Image',
                  },
                },
              ],
            });
          } else {
            messages.add(<String, String>{
              'role': 'user',
              'content': '${prompt.user}\nRespond in valid JSON format.',
            });
          }

          final Map<String, dynamic> body = <String, dynamic>{
            'model': currentModel,
            'messages': messages,
            'temperature': 0.1,
            'max_tokens': 600,
            'response_format': <String, String>{'type': 'json_object'},
          };

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

          if (res.statusCode == 429) {
            AppLogger.w('ChatGPT 429 quota/rate limit on $currentModel, trying next...');
            continue;
          }
          if (res.statusCode == 401 || res.statusCode == 403) {
            throw const AiProviderException(
              'chatgpt',
              'Invalid OpenAI/ChatGPT API Key from platform.openai.com',
            );
          }

          if (res.statusCode == 200) {
            AppLogger.i('ChatGPT SUCCESS with model: $currentModel');
            final Map<String, dynamic> j =
                jsonDecode(res.body) as Map<String, dynamic>;
            final String content =
                j['choices'][0]['message']['content'] as String;
            return VerdictParser.parse(content, AiProvider.chatgpt, currentModel);
          }

          // Error handling
          String msg = 'HTTP ${res.statusCode}';
          try {
            final Map<String, dynamic> errJson =
                jsonDecode(res.body) as Map<String, dynamic>;
            if (errJson.containsKey('error') && errJson['error'] is Map) {
              msg = (errJson['error'] as Map)['message']?.toString() ?? msg;
            }
          } catch (_) {
            if (res.body.isNotEmpty) msg = res.body;
          }

          lastErrorMessage = msg;
          AppLogger.w('ChatGPT model $currentModel failed: $msg');
        }

        throw AiProviderException('chatgpt', lastErrorMessage ?? 'ChatGPT service unavailable');
      } on TimeoutException catch (_) {
        throw const KavachTimeoutException();
      } on SocketException catch (e) {
        throw NetworkException(e.toString());
      } finally {
        client.close();
      }
    });
  }
}
