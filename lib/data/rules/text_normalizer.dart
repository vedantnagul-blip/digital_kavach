/// Normalized representation of raw scanned text.
class NormalizedText {
  const NormalizedText({
    required this.raw,
    required this.normalized,
    required this.lowercased,
    required this.words,
    required this.urls,
  });

  final String raw;
  final String normalized;

  /// [normalized] lowercased where safe (Latin scripts only — Indic scripts
  /// are largely caseless so this is a no-op for them).
  final String lowercased;

  final List<String> words;
  final List<String> urls;
}

/// Deterministic text normalizer — pure Dart, no I/O.
///
/// Steps:
///   1. Strip zero-width & bidi control chars
///   2. Map smart/curly quotes → ASCII quotes
///   3. Collapse whitespace
///   4. Lowercase Latin only (preserves Devanagari, Tamil, etc.)
///   5. Attach extracted URLs
class TextNormalizer {
  const TextNormalizer._();

  static const Map<String, String> _smartQuotes = <String, String>{
    '\u2018': "'",
    '\u2019': "'",
    '\u201A': "'",
    '\u201B': "'",
    '\u201C': '"',
    '\u201D': '"',
    '\u201E': '"',
    '\u201F': '"',
    '\u2013': '-',
    '\u2014': '-',
    '\u2026': '...',
  };

  static const Set<int> _stripCodePoints = <int>{
    0x200B,
    0x200C,
    0x200D,
    0x200E,
    0x200F,
    0xFEFF,
    0x202A,
    0x202B,
    0x202C,
    0x202D,
    0x202E,
  };

  static NormalizedText normalize(String input, {List<String>? urls}) {
    final StringBuffer sb = StringBuffer();
    for (final int rune in input.runes) {
      if (_stripCodePoints.contains(rune)) continue;
      final String ch = String.fromCharCode(rune);
      sb.write(_smartQuotes[ch] ?? ch);
    }
    String out = sb.toString();
    out = out.replaceAll(RegExp(r'[ \t\r\f\v]+'), ' ');
    out = out.replaceAll(RegExp(r' *\n *'), '\n');
    out = out.trim();

    final String lower = _lowercaseLatinOnly(out);
    final List<String> words = out
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    final List<String> foundUrls = urls ?? const <String>[];

    return NormalizedText(
      raw: input,
      normalized: out,
      lowercased: lower,
      words: words,
      urls: foundUrls,
    );
  }

  static String _lowercaseLatinOnly(String s) {
    final StringBuffer sb = StringBuffer();
    for (final int r in s.runes) {
      if (r >= 0x41 && r <= 0x5A) {
        sb.writeCharCode(r + 32);
      } else {
        sb.writeCharCode(r);
      }
    }
    return sb.toString();
  }
}