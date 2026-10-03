import 'dart:io';

import 'package:digital_kavach/data/rules/rule_engine.dart';
import 'package:digital_kavach/data/rules/score_aggregator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RuleEngine engine;

  setUpAll(() {
    final String rawRules = File('assets/rules.json').readAsStringSync();
    engine = RuleEngine.fromJsonString(rawRules);
  });

  group('RuleEngine scam detection', () {
    test('detects Digital Arrest scam in English', () {
      const input = ScanInput(
        text: 'CBI officer here. A customs parcel in your name was seized. Arrest warrant issued. Digital arrest initiated.',
        source: ScanSource.paste,
      );

      final result = engine.run(input);
      expect(result.level, equals(VerdictLevel.red));
      expect(result.score, greaterThanOrEqualTo(60));
      expect(result.hits.any((h) => h.family == ScamFamily.digital_arrest), isTrue);
    });

    test('detects Digital Arrest scam in Hindi', () {
      const input = ScanInput(
        text: 'सीबीआई अधिकारी बोल रहे हैं। आपके नाम पर गिरफ़्तारी वारंट निकला है। तुरंत संपर्क करें। डिजिटल अरेस्ट।',
        source: ScanSource.paste,
        langCode: 'hi',
      );

      final result = engine.run(input);
      expect(result.level, equals(VerdictLevel.red));
      expect(result.hits.any((h) => h.family == ScamFamily.digital_arrest), isTrue);
    });

    test('detects Fake KYC suspension trap', () {
      const input = ScanInput(
        text: 'Dear customer, your SBI account KYC suspended. Click http://sbi-verify.xyz to update immediately.',
        source: ScanSource.paste,
      );

      final result = engine.run(input);
      expect(result.level, anyOf(equals(VerdictLevel.red), equals(VerdictLevel.amber)));
      expect(result.hits.any((h) => h.family == ScamFamily.fake_kyc || h.family == ScamFamily.phishing_link), isTrue);
    });

    test('detects UPI receive trap (asking PIN to receive money)', () {
      const input = ScanInput(
        text: 'Scan this QR and enter your UPI PIN to receive money Rs 5000 in your bank.',
        source: ScanSource.qr,
      );

      final result = engine.run(input);
      expect(result.level, equals(VerdictLevel.red));
      expect(result.hits.any((h) => h.family == ScamFamily.upi_collect_trap), isTrue);
    });

    test('does not flag normal conversational messages (low false-positive)', () {
      const input = ScanInput(
        text: 'Hey mom, I am heading home from the office. Please keep dinner ready. Love you!',
        source: ScanSource.notification,
      );

      final result = engine.run(input);
      expect(result.level, equals(VerdictLevel.green));
      expect(result.score, lessThan(15));
      expect(result.hits, isEmpty);
    });
  });
}
