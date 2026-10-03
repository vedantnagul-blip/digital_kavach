import 'package:digital_kavach/features/recovery/complaint_service.dart';
import 'package:digital_kavach/features/recovery/copilot_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComplaintService', () {
    final service = ComplaintService();

    final testAnswers = RecoveryAnswers(
      scamFamily: 'upi',
      amount: 15000,
      incidentDate: DateTime(2025, 1, 15),
      paymentApp: 'Google Pay',
      toWhom: 'fake-collector@okhdfc',
      utrNumber: '123456789012',
      description: 'Sent money after scammer promised refund on fake KYC verification.',
      complainantName: 'Ramesh Sharma',
      city: 'Pune',
    );

    test('generates valid template draft without AI', () async {
      final draft = await service.buildDraft(testAnswers);

      expect(draft.source, equals(DraftSource.template));
      expect(draft.complaintEn, contains('Google Pay'));
      expect(draft.complaintEn, contains('15000'));
      expect(draft.complaintEn, contains('123456789012'));
      expect(draft.emailSubject, contains('Fraud'));
      expect(draft.emailBody, isNotEmpty);
    });

    test('correctly parses robust AI JSON response', () async {
      const mockAiResponse = '''
```json
{
  "complaintEn": "This is a formal NCRP complaint draft against fake-collector@okhdfc.",
  "emailSubject": "Urgent: Cyber Fraud Freeze Request - UTR 123456789012",
  "emailBody": "Dear Nodal Officer, please freeze beneficiary account."
}
```
''';

      final draft = await service.buildDraft(
        testAnswers,
        aiCaller: (sys, user) async => mockAiResponse,
      );

      expect(draft.source, equals(DraftSource.ai));
      expect(draft.complaintEn, contains('formal NCRP complaint draft'));
      expect(draft.emailSubject, contains('Freeze Request'));
    });

    test('gracefully falls back to template if AI caller throws', () async {
      final draft = await service.buildDraft(
        testAnswers,
        aiCaller: (sys, user) async => throw Exception('Quota limit reached'),
      );

      expect(draft.source, equals(DraftSource.template));
      expect(draft.complaintEn, contains('Google Pay'));
    });
  });
}
