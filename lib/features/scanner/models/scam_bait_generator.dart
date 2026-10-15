import 'package:flutter/foundation.dart';

@immutable
class BaitPersona {
  const BaitPersona({
    required this.name,
    required this.role,
    required this.description,
  });

  final String name;
  final String role;
  final String description;
}

class ScamBaitGenerator {
  static const BaitPersona defaultPersona = BaitPersona(
    name: 'Ramesh Kaka',
    role: 'Elderly Confused Citizen',
    description: 'Delays scammers with harmless questions to extract their phone & UPI IDs.',
  );

  static List<String> generateResponses({
    required String scamType,
    required String originalMessage,
  }) {
    final lower = originalMessage.toLowerCase();

    if (lower.contains('bill') || lower.contains('electricity') || lower.contains('power')) {
      return [
        'Beta, I checked my electricity meter outside. Which meter number should I read to you? My grandson is not at home.',
        'Electricity office gave me a physical receipt yesterday. Where should I come and submit the cash?',
        'Can you send me your official officer ID card and department name on WhatsApp first so I can show it to my son?',
      ];
    }

    if (lower.contains('lottery') || lower.contains('reward') || lower.contains('won') || lower.contains('prize')) {
      return [
        'Wah beta! Very happy to hear. But I do not use internet banking. Can you send this prize by post office money order to my address?',
        'Which bank account number do you need? Can you give me your direct supervisor phone number so my bank manager can call them?',
        'Beta, I tried sending 10 rupees first to test. Can you give me your exact UPI ID and registered full name again?',
      ];
    }

    if (lower.contains('job') || lower.contains('part time') || lower.contains('telegram')) {
      return [
        'I am interested in this daily task work. But my phone only supports SMS. Can you give me the company registration certificate (CIN number) first?',
        'Sir, I do not have Telegram. Can we do this work on Google or phone call? What is your office address in Delhi/Mumbai?',
        'Before paying the deposit fee, what is the official bank account name of the company? Not individual name.',
      ];
    }

    // Default universal stalling responses
    return [
      'Beta, my screen is showing an OTP warning in red color. What should I do? Can you call my son first on this number?',
      'I want to resolve this immediately, but GPay is asking for beneficiary PAN card or official company account. What is your account name?',
      'Sir, I am sitting at the bank counter right now with the manager. He is asking for your branch code and merchant ID.',
    ];
  }
}
