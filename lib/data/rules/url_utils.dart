import 'package:flutter/cupertino.dart';

/// URL & domain helpers used by [RuleEngine] and QR Guard (Phase 05).
class UrlUtils {
  const UrlUtils._();

  /// Government / bank domains that should NEVER trip phishing rules.
  ///
  /// Kept small on purpose — this list gates a suppression path, not a
  /// trust affirmation. Expandable via Firestore config in Phase 04+.
  static const Set<String> govAndBankAllowlist = <String>{
    'echallan.gov.in',
    'parivahan.gov.in',
    'cybercrime.gov.in',
    'incometax.gov.in',
    'gst.gov.in',
    'uidai.gov.in',
    'india.gov.in',
    'rbi.org.in',
    'npci.org.in',
    'onlinesbi.sbi',
    'onlinesbi.com',
    'hdfcbank.com',
    'icicibank.com',
    'axisbank.com',
    'kotak.com',
    'pnbindia.in',
    'bankofbaroda.in',
    'canarabank.com',
    'unionbankofindia.co.in',
    'idbibank.in',
    'yesbank.in',
    'idfcfirstbank.com',
    'aubank.in',
  };

  /// Common phishing TLDs — never blocklist strictly, but weigh them.
  static const Set<String> suspiciousTlds = <String>{
    'xyz', 'top', 'click', 'link', 'work', 'live', 'cyou',
    'buzz', 'quest', 'gq', 'tk', 'ml', 'cf', 'ga',
  };

  /// Extract URLs & bare-domain tokens.
  ///
  /// Handles: `https://x.com`, `http://x`, `www.x.com`, `x.co.in/path`,
  /// trailing punctuation, wrapping brackets, percent-encoded segments.
  static List<String> extract(String text) {
    final RegExp re = RegExp(
      r'''(?:https?:\/\/|www\.)[^\s<>"']+|[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+(?:\/[^\s<>"']*)?''',
      caseSensitive: false,
    );
    final Iterable<RegExpMatch> matches = re.allMatches(text);
    final List<String> out = <String>[];
    for (final RegExpMatch m in matches) {
      String url = m.group(0)!;
      // Trim trailing punctuation.
      while (url.isNotEmpty && _trailingPunct.contains(url.substring(url.length - 1))) {
        url = url.substring(0, url.length - 1);
      }
      if (_looksLikeDomainOrUrl(url)) out.add(url);
    }
    return out;
  }

  static bool _looksLikeDomainOrUrl(String s) {
    if (s.startsWith('http://') || s.startsWith('https://') || s.startsWith('www.')) {
      return true;
    }
    // Bare domain heuristic: must contain a dot and a TLD-like tail.
    final int dot = s.indexOf('.');
    if (dot <= 0 || dot == s.length - 1) return false;
    return true;
  }

  static const Set<String> _trailingPunct = <String>{
    '.', ',', ';', ':', ')', ']', '}', '"', "'", '!', '?', '>',
  };

  /// Extract the registrable host of a URL (best-effort, no PSL).
  static String? hostOf(String urlOrDomain) {
    try {
      final String s = urlOrDomain.contains('://')
          ? urlOrDomain
          : 'http://$urlOrDomain';
      final Uri u = Uri.parse(s);
      final String h = u.host.toLowerCase();
      return h.isEmpty ? null : h;
    } catch (_) {
      return null;
    }
  }

  static bool isAllowlisted(String urlOrDomain) {
    final String? h = hostOf(urlOrDomain);
    if (h == null) return false;
    if (govAndBankAllowlist.contains(h)) return true;
    for (final String d in govAndBankAllowlist) {
      if (h == d || h.endsWith('.$d')) return true;
    }
    return false;
  }

  static bool isSuspiciousTld(String urlOrDomain) {
    final String? h = hostOf(urlOrDomain);
    if (h == null) return false;
    final int dot = h.lastIndexOf('.');
    if (dot < 0) return false;
    return suspiciousTlds.contains(h.substring(dot + 1));
  }

  static bool isHttps(String url) => url.toLowerCase().startsWith('https://');
}