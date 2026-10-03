import 'package:digital_kavach/data/rules/text_normalizer.dart';
import 'package:digital_kavach/data/rules/url_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlUtils', () {
    test('extracts valid URLs from message body', () {
      const text = 'Notice: pay pending challan at https://echallan-fake.top/pay now.';
      final urls = UrlUtils.extract(text);
      expect(urls, hasLength(1));
      expect(urls.first, contains('echallan-fake.top'));
    });

    test('correctly identifies allowlisted domains', () {
      expect(UrlUtils.isAllowlisted('https://echallan.gov.in/payment'), isTrue);
      expect(UrlUtils.isAllowlisted('https://parivahan.gov.in/rc'), isTrue);
      expect(UrlUtils.isAllowlisted('https://onlinesbi.sbi/login'), isTrue);
      expect(UrlUtils.isAllowlisted('https://echallan-fake.xyz/pay'), isFalse);
    });

    test('identifies suspicious TLDs', () {
      expect(UrlUtils.isSuspiciousTld('https://secure-login.xyz'), isTrue);
      expect(UrlUtils.isSuspiciousTld('https://update-kyc.top'), isTrue);
      expect(UrlUtils.isSuspiciousTld('https://hdfcbank.com'), isFalse);
    });
  });

  group('TextNormalizer', () {
    test('strips zero-width and control characters', () {
      const text = 'U\u200B P\u200C I\u200D P\uFEFF I N';
      final norm = TextNormalizer.normalize(text);
      expect(norm.normalized, equals('U P I P I N'));
    });

    test('collapses excessive whitespace and tabs', () {
      const text = 'Your   account    is \t\n suspended';
      final norm = TextNormalizer.normalize(text);
      expect(norm.normalized, equals('Your account is suspended'));
    });
  });
}
