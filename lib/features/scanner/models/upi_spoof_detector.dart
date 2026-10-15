import 'package:flutter/foundation.dart';
import 'qr_payload.dart';

enum UpiRiskLevel { safe, warning, critical }

@immutable
class UpiRiskAnalysis {
  const UpiRiskAnalysis({
    required this.level,
    required this.isSpoofed,
    required this.headline,
    required this.reasons,
    required this.claimedIdentity,
    required this.actualVpa,
    required this.suggestedAction,
  });

  final UpiRiskLevel level;
  final bool isSpoofed;
  final String headline;
  final List<String> reasons;
  final String claimedIdentity;
  final String actualVpa;
  final String suggestedAction;
}

class UpiSpoofDetector {
  static const List<String> _officialKeywords = [
    'pmcares', 'pm cares', 'electricity', 'mseb', 'bescom', 'bses',
    'traffic', 'echallan', 'challan', 'rbi', 'sbi', 'hdfc', 'icici',
    'tax', 'income tax', 'ayushman', 'post office', 'speedpost'
  ];

  static const List<String> _personalHandles = [
    '@ybl', '@axl', '@ibl', '@okhdfcbank', '@okicici', '@oksbi',
    '@okaxis', '@paytm', '@apl', '@pingpay'
  ];

  static UpiRiskAnalysis analyze(UpiQrPayload payload) {
    if (!payload.isUpi) {
      return const UpiRiskAnalysis(
        level: UpiRiskLevel.safe,
        isSpoofed: false,
        headline: 'Standard QR Code',
        reasons: ['Not a direct UPI payment request.'],
        claimedIdentity: 'None',
        actualVpa: 'N/A',
        suggestedAction: 'Verify URL safety before opening.',
      );
    }

    final vpa = (payload.payeeVpa ?? '').toLowerCase();
    final name = (payload.payeeName ?? '').toLowerCase();
    final reasons = <String>[];
    bool isSpoofed = false;

    // 1. Check Merchant Spoofing
    final bool claimsOfficial = _officialKeywords.any((kw) => name.contains(kw));
    final bool usesPersonalHandle = _personalHandles.any((h) => vpa.endsWith(h));

    if (claimsOfficial && usesPersonalHandle) {
      isSpoofed = true;
      reasons.add(
        'Identity mismatch: Display name claims "$name" (Official/Gov/Utility), but VPA "$vpa" belongs to a private individual account.',
      );
    }

    // 2. Hidden Auto-Debit / Collect Request Trigger
    if (payload.amount != null && double.tryParse(payload.amount!) != null) {
      final double amt = double.parse(payload.amount!);
      if (amt >= 2000) {
        reasons.add('Fixed high-value payment lock (₹$amt) embedded directly inside QR.');
      }
    }

    // 3. Fake Bill/Challan Pattern
    if (name.contains('challan') || name.contains('fine')) {
      if (!vpa.contains('gov') && !vpa.contains('nic')) {
        isSpoofed = true;
        reasons.add('Fake traffic e-challan alert: Official traffic fines never direct to private bank handles.');
      }
    }

    if (isSpoofed) {
      return UpiRiskAnalysis(
        level: UpiRiskLevel.critical,
        isSpoofed: true,
        headline: '🚨 HIGH RISK: Ghost UPI Merchant Spoofing Detected!',
        reasons: reasons,
        claimedIdentity: payload.payeeName ?? 'Unknown Merchant',
        actualVpa: payload.payeeVpa ?? 'Unknown VPA',
        suggestedAction: 'DO NOT ENTER UPI PIN. Beneficiary name is forged.',
      );
    }

    if (reasons.isNotEmpty) {
      return UpiRiskAnalysis(
        level: UpiRiskLevel.warning,
        isSpoofed: false,
        headline: '⚠️ Caution: Unverified Payment QR',
        reasons: reasons,
        claimedIdentity: payload.payeeName ?? 'Merchant',
        actualVpa: payload.payeeVpa ?? 'Personal VPA',
        suggestedAction: 'Double-check payee details before paying.',
      );
    }

    return UpiRiskAnalysis(
      level: UpiRiskLevel.safe,
      isSpoofed: false,
      headline: '✅ Verified UPI Structure',
      reasons: ['No known merchant impersonation or deceptive handles detected.'],
      claimedIdentity: payload.payeeName ?? 'Direct Payee',
      actualVpa: payload.payeeVpa ?? 'N/A',
      suggestedAction: 'Safe to proceed with normal caution.',
    );
  }
}
