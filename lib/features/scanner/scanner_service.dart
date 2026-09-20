import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/ai/ai_keys_store.dart';
import '../../data/ai/ai_router.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/user_prefs.dart';
import '../../data/rules/rule_engine.dart';
import '../../data/rules/score_aggregator.dart';
import '../sentinel/feed/feed_controller.dart';
import 'dev_harness_screen.dart';
import 'models/qr_payload.dart';
import 'models/scan_request.dart';

final Provider<ScannerService> scannerServiceProvider =
    Provider<ScannerService>((Ref ref) {
  return ScannerService(
    ref.watch(aiRouterProvider),
    ref.watch(userPrefsProvider),
    ref,
  );
});

class ScannerService {
  ScannerService(this._aiRouter, this._prefs, this._ref);

  final AiRouter _aiRouter;
  final UserPrefs _prefs;
  final Ref _ref;

  /// Perform OCR on image file using ML Kit (Devanagari + English support).
  /// Falls back to Latin recognizer if Devanagari fails, and returns empty string
  /// rather than crashing so AI Vision can still inspect the image bytes directly.
  Future<String> extractTextFromImage(String imagePath) async {
    final File file = File(imagePath);
    if (!await file.exists()) {
      AppLogger.e('OCR: File does not exist at $imagePath');
      return '';
    }

    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    String extracted = '';

    // Attempt 1: Devanagari recognizer (supports Hindi, Marathi, etc. + numbers/English)
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
      final RecognizedText recognized =
          await recognizer.processImage(inputImage);
      extracted = recognized.text.trim();
    } catch (e) {
      AppLogger.w('Devanagari OCR attempt failed: $e');
    } finally {
      await recognizer?.close();
    }

    // Attempt 2: If Devanagari threw or found nothing, fall back to standard Latin
    if (extracted.isEmpty) {
      try {
        recognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognized =
            await recognizer.processImage(inputImage);
        extracted = recognized.text.trim();
      } catch (e) {
        AppLogger.w('Latin OCR fallback failed: $e');
      } finally {
        await recognizer?.close();
      }
    }

    // Attempt 3: If on-device ML Kit OCR found nothing, use Gemini Vision transcription fallback
    if (extracted.isEmpty) {
      try {
        final config = await _ref.read(aiKeysStoreProvider).getConfig();
        if (config.geminiKey != null && config.geminiKey!.isNotEmpty) {
          final Uint8List bytes = await file.readAsBytes();
          String mime = 'image/jpeg';
          final lower = imagePath.toLowerCase();
          if (lower.endsWith('.png')) {
            mime = 'image/png';
          } else if (lower.endsWith('.webp')) {
            mime = 'image/webp';
          }

          final model = GenerativeModel(
            model: config.geminiModel ?? 'gemini-3.6-flash',
            apiKey: config.geminiKey!,
          );
          final res = await model.generateContent([
            Content.multi([
              TextPart(
                'Transcribe all text from this image verbatim. '
                'If written in Marathi, Hindi, or any Indian script, output the exact Devanagari text. '
                'Return ONLY the raw extracted text, with no explanations.',
              ),
              DataPart(mime, bytes),
            ]),
          ]).timeout(const Duration(seconds: 15));

          if (res.text != null && res.text!.trim().isNotEmpty) {
            extracted = res.text!.trim();
            AppLogger.i('Gemini Vision successfully transcribed ${extracted.length} chars from image');
          }
        }
      } catch (e) {
        AppLogger.w('Gemini vision OCR transcription fallback failed: $e');
      }
    }

    return extracted;
  }

  /// Run scan on raw text or OCR output through RuleEngine + AiRouter.
  Future<HybridScanResult> scanText(
    String text, {
    ScanSource source = ScanSource.paste,
    String? senderTitle,
    Map<String, String>? upiParams,
    List<int>? imageBytes,
    String? imageMime,
    bool forceAi = false,
  }) async {
    final RuleEngine engine = await _ref.read(ruleEngineProvider.future);
    final String lang = _prefs.langCode ?? 'en';

    final ScanRequest req = ScanRequest(
      text: text,
      source: source,
      senderTitle: senderTitle,
      upiParams: upiParams,
      imageBytes: imageBytes,
      imageMime: imageMime,
      langCode: lang,
    );

    final HybridScanResult res =
        await _aiRouter.hybridAnalyze(req, engine, forceAi: forceAi);

    // Save scan to Activity Feed
    try {
      if (Hive.isBoxOpen(HiveBoxes.feed)) {
        final Box<dynamic> feedBox = Hive.box<dynamic>(HiveBoxes.feed);
        final String entryId = DateTime.now().millisecondsSinceEpoch.toString();
        final FeedEntry entry = FeedEntry(
          id: entryId,
          ts: DateTime.now(),
          source: source.name,
          level: res.finalVerdict.verdict.wire,
          score: res.finalVerdict.riskScore,
          pattern: res.finalVerdict.patternMatched,
          provider: res.finalVerdict.provider.provider.name,
          titleMeta: senderTitle ??
              (source == ScanSource.qr
                  ? 'QR Scan'
                  : (source == ScanSource.shareImage
                      ? 'Image Scan'
                      : 'Text Scan')),
        );
        await feedBox.put(entryId, jsonEncode(entry.toJson()));
      }
    } catch (e) {
      AppLogger.w('ScannerService: feed record failed: $e');
    }

    return res;
  }

  /// Scan image: perform OCR then run hybrid scan with image bytes for vision.
  Future<({String extractedText, HybridScanResult result})> scanImage(
    String imagePath, {
    bool forceAi = false,
  }) async {
    final String text = await extractTextFromImage(imagePath);
    final File file = File(imagePath);
    final Uint8List bytes = await file.readAsBytes();

    String mime = 'image/jpeg';
    final String lower = imagePath.toLowerCase();
    if (lower.endsWith('.png')) {
      mime = 'image/png';
    } else if (lower.endsWith('.webp')) {
      mime = 'image/webp';
    }

    final HybridScanResult res = await scanText(
      text.isEmpty ? 'Image scan - no OCR text detected' : text,
      source: ScanSource.shareImage,
      imageBytes: bytes,
      imageMime: mime,
      forceAi: forceAi || text.isEmpty,
    );

    return (extractedText: text, result: res);
  }

  /// Scan raw QR barcode payload.
  Future<({UpiQrPayload payload, HybridScanResult result})> scanQrCode(
    String rawQr,
  ) async {
    final UpiQrPayload payload = UpiQrPayload.parse(rawQr);

    final String textToScan = payload.isUpi
        ? 'UPI QR Payee: ${payload.payeeName ?? ''} VPA: ${payload.payeeVpa ?? ''} Note: ${payload.transactionNote ?? ''}'
        : rawQr;

    final HybridScanResult res = await scanText(
      textToScan,
      source: ScanSource.qr,
      upiParams: payload.toRuleParams(),
    );

    return (payload: payload, result: res);
  }
}
