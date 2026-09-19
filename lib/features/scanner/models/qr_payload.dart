import 'package:flutter/foundation.dart';

/// Parsed UPI QR intent payload (`upi://pay?...`).
@immutable
class UpiQrPayload {
  const UpiQrPayload({
    required this.raw,
    required this.isUpi,
    this.payeeVpa,
    this.payeeName,
    this.amount,
    this.transactionNote,
    this.merchantCode,
    this.transactionRef,
  });

  final String raw;
  final bool isUpi;
  final String? payeeVpa; // pa
  final String? payeeName; // pn
  final String? amount; // am
  final String? transactionNote; // tn
  final String? merchantCode; // mc
  final String? transactionRef; // tr

  factory UpiQrPayload.parse(String raw) {
    final String trimmed = raw.trim();
    if (!trimmed.toLowerCase().startsWith('upi://pay')) {
      return UpiQrPayload(raw: raw, isUpi: false);
    }

    try {
      final Uri uri = Uri.parse(trimmed);
      final Map<String, String> q = uri.queryParameters;

      return UpiQrPayload(
        raw: raw,
        isUpi: true,
        payeeVpa: q['pa']?.trim(),
        payeeName: q['pn']?.trim(),
        amount: q['am']?.trim(),
        transactionNote: q['tn']?.trim(),
        merchantCode: q['mc']?.trim(),
        transactionRef: q['tr']?.trim(),
      );
    } catch (_) {
      return UpiQrPayload(raw: raw, isUpi: false);
    }
  }

  Map<String, String> toRuleParams() {
    final Map<String, String> map = <String, String>{};
    if (payeeVpa != null) map['pa'] = payeeVpa!;
    if (payeeName != null) map['pn'] = payeeName!;
    if (amount != null) map['am'] = amount!;
    if (transactionNote != null) map['tn'] = transactionNote!;
    return map;
  }
}