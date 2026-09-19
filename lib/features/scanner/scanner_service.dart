import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/ai/ai_router.dart';
import '../../data/local/user_prefs.dart';
import '../../data/rules/rule_engine.dart';
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
  Future<String> extractTextFromImage(String imagePath) async {
    final TextRecognizer recognizer = TextRecognizer(
      script: TextRecognitionScript.devanagiri,
    );
    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognized =
      await recognizer.processImage(inputImage);
      return recognized.text;
    } catch (e, st) {
      AppLogger.e('OCR extraction failed', error: e, stackTrace: st);
      throw StorageException('OCR failed: $e');
    } finally {
      recognizer.close();
    }
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

    return _aiRouter.hybridAnalyze(req, engine, forceAi: forceAi);
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
    if (imagePath.endsWith('.png')) mime = 'image/png';

    final HybridScanResult res = await scanText(
      text.isEmpty ? 'Image scan - no OCR text detected' : text,
      source: ScanSource.shareImage,
      imageBytes: bytes,
      imageMime: mime,
      forceAi: forceAi,
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