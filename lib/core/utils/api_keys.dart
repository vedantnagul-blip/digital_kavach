/// Production compile-time and fallback API key configuration.
///
/// In production builds, keys can be passed securely at build time without
/// storing them in user-accessible storage:
///
/// ```bash
/// flutter build apk --release \
///   --dart-define=CHATGPT_API_KEY="sk-..." \
///   --dart-define=GROQ_API_KEY="gsk_..." \
///   --dart-define=GEMINI_API_KEY="AIza..."
/// ```
class ApiKeys {
  const ApiKeys._();

  /// Google Gemini API Key (Google AI Studio)
  static const String gemini = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Groq Cloud API Key (Free Llama 3.3 70B & 8B from console.groq.com)
  static const String groq = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  /// xAI Grok API Key (optional fallback)
  static const String grok = String.fromEnvironment(
    'GROK_API_KEY',
    defaultValue: '',
  );

  /// OpenAI / ChatGPT API Key (https://platform.openai.com)
  static const String chatgpt = String.fromEnvironment(
    'CHATGPT_API_KEY',
    defaultValue: String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
  );

  /// Gemini model identifier (Production stable: gemini-1.5-flash)
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  /// Groq model identifier
  static const String groqModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  /// Grok model identifier (alias for backwards compatibility)
  static const String grokModel = String.fromEnvironment(
    'GROK_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  /// ChatGPT model identifier
  static const String chatgptModel = String.fromEnvironment(
    'CHATGPT_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
}
