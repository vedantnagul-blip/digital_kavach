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

class GrokProvider implements AiProviderClient {
  GrokProvider({required this.apiKey, String? modelId})
      : _preferredModel = (modelId != null &&
      modelId.trim().isNotEmpty &&
      modelId != 'grok-beta')
      ? modelId.trim()
      : 'grok-2-latest',
        supportsVision = false;

  @override
  final String name = 'grok';

  @override
  final bool supportsVision;

  final String apiKey;
  final String _preferredModel;

  @override
  Future<Verdict> analyze(ScanRequest req) async {
    return runCatching(() async {
      final http.Client client = http.Client();
      try {
        final BuiltPrompt prompt = PromptBuilder.build(req);

        final List<String> modelsToTry = <String>{
          _preferredModel,
          'grok-2-latest',
          'grok-2-1212',
          'grok-vision-beta',
        }.toList();

        String? lastErrorMessage;

        for (final String currentModel in modelsToTry) {
          AppLogger.i('Grok attempting model: $currentModel');

          final Map<String, dynamic> body = <String, dynamic>{
            'model': currentModel,
            'messages': <Map<String, dynamic>>[
              <String, String>{'role': 'system', 'content': prompt.system},
              <String, String>{'role': 'user', 'content': prompt.user},
            ],
            'temperature': 0.2,
          };

          final http.Response res = await client.post(
            Uri.parse('https://api.x.ai/v1/chat/completions'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(body),
          ).timeout(const Duration(seconds: 12));

          if (res.statusCode == 429) throw const QuotaExceededException();
          if (res.statusCode == 401 || res.statusCode == 403) {
            throw const AiProviderException(
                'grok', 'Invalid Grok key or unpaid xAI account credits');
          }

          if (res.statusCode != 200) {
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
            AppLogger.w('Grok $currentModel failed: $msg');
            continue;
          }

          AppLogger.i('Grok SUCCESS with model: $currentModel');
          return _parseOrThrow(res.body, currentModel);
        }

        throw AiProviderException('grok', lastErrorMessage ?? 'HTTP 400 Bad Request');
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