import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeepSeekService {
  final String _apiKey;
  final String _baseUrl = 'https://openrouter.ai/api/v1';
  final String _model;

  DeepSeekService([String? apiKey, String? model])
      : _apiKey = apiKey ?? '',
        _model = model ?? 'mistralai/mixtral-8x7b-instruct' {
    _initializeApiKey();
  }

  Future<void> _initializeApiKey() async {
    try {
      String key = _apiKey;

      // Fallback 1: SharedPreferences
      if (key.isEmpty) {
        final savedKey = await getApiKey();
        if (savedKey != null && savedKey.isNotEmpty) {
          key = savedKey;
        }
      }

      // Fallback 2: .env file
      if (key.isEmpty) {
        try {
          await dotenv.load();
          key = dotenv.env['OPENROUTER_API_KEY'] ?? '';
        } catch (e) {
          print('Failed to load .env file: $e');
        }
      }

      // Validation
      if (key.isEmpty) {
        throw Exception('OpenRouter API Key is not set.');
      }
      if (!key.startsWith('sk-')) {
        throw Exception('Invalid API key format. Must start with "sk-"');
      }

      await saveApiKey(key);
    } catch (e) {
      print('Error initializing API key: $e');
      rethrow;
    }
  }

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openrouter_api_key');
  }

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openrouter_api_key', apiKey);
  }

  // ==================== KINYARWANDA TRANSLATION ====================
  Future<String> translateToKinyarwanda(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a professional Kinyarwanda translator with deep knowledge of Rwandan culture and language nuances. Your task is to:

1. Translate the given English text to Kinyarwanda with perfect accuracy
2. Ensure the translation is natural, idiomatic, and culturally appropriate
3. Maintain the original meaning, tone, and context
4. Use proper Kinyarwanda grammar, vocabulary, and orthography
5. ALWAYS respond in Kinyarwanda using proper Latin characters
6. Adapt cultural references and idioms to Rwandan equivalents when appropriate
7. Preserve formal/informal tone from the original text

Output only the Kinyarwanda translation without any explanations, notes, or English text.'''
            },
            {
              'role': 'user',
              'content':
                  'Translate this text to Kinyarwanda, maintaining the original meaning and cultural context: "$text"'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 500,
          'top_p': 0.9,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      );

      return _processTranslationResponse(response);
    } catch (e) {
      throw Exception('Translation error: ${_sanitizeError(e)}');
    }
  }

  // ==================== KINYARWANDA-ONLY CHAT ====================

  Future<String> chatInKinyarwanda(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a native Kinyarwanda tutor. ONLY RESPOND IN KINYARWANDA. NO ENGLISH ALLOWED.

IMPORTANT RULES:
1. NEVER respond in English - use ONLY Kinyarwanda for ALL responses
2. NEVER include translations or explanations
3. Keep responses natural, brief, and conversational (2-3 sentences maximum)
4. Do not explain what you're doing or how language works
5. Respond directly as a conversation partner would
6. For English messages, respond: "Ndagusaba kuvuga mu Kinyarwanda"

Avoid any meta-commentary about language learning or your role.
Simply BE a Kinyarwanda conversation partner in your responses.

Examples of GOOD responses:
User: "Muraho"
Response: "Muraho! Amakuru yawe?"

User: "Nitwa John"
Response: "Ni byiza kuguhura, John. Nitwa Afrilingo. Uva he?"

User: "I don't understand"
Response: "Ndagusaba kuvuga mu Kinyarwanda."

BAD responses (NEVER do this):
❌ "Hello! In Kinyarwanda, we say 'Muraho'..."
❌ "Let me teach you how to say this in Kinyarwanda..."
❌ "As your Kinyarwanda tutor, I'll help you with..."
❌ Any response containing English explanations'''
            },
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 200,
          'top_p': 0.9,
          'frequency_penalty': 0.2,
          'presence_penalty': 0.6,
        }),
      );

      return _processChatResponse(response);
    } catch (e) {
      throw Exception('Chat error: ${_sanitizeError(e)}');
    }
  }

  // ==================== HELPER METHODS ====================
  String _sanitizeError(dynamic e) {
    return e.toString().replaceAll(_apiKey, '***REDACTED***');
  }

  String _processTranslationResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String content = data['choices'][0]['message']['content'].trim();

      // Check for empty or invalid responses
      if (content.isEmpty ||
          content == "?" ||
          content == "??" ||
          content == " ") {
        return "Ntago byumvikana";
      }

      // Kinyarwanda uses Latin alphabet, so we don't remove Latin characters
      // Instead, we'll check if the response contains at least some Kinyarwanda-specific characters
      // or common Kinyarwanda words to validate it's actually Kinyarwanda
      if (!_containsKinyarwandaElements(content)) {
        print('Response may not be valid Kinyarwanda: $content');
        // Still return the content, but log the concern
      }

      return content;
    }
    throw Exception(
        'Translation failed: ${response.statusCode} - ${response.body}');
  }

  String _processChatResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String content = data['choices'][0]['message']['content'].trim();

      // Check for empty or invalid responses
      if (content.isEmpty ||
          content == "?" ||
          content == "??" ||
          content == " ") {
        return "Ntabwo numvise neza. Ongera uvuge mu Kinyarwanda.";
      }

      // Kinyarwanda uses Latin alphabet, so we don't remove Latin characters
      // Instead, we'll check if the response contains at least some Kinyarwanda-specific elements
      if (!_containsKinyarwandaElements(content)) {
        print('Response may not be valid Kinyarwanda: $content');
        // If the response is clearly in English, prompt for Kinyarwanda
        if (_isEnglishOnly(content)) {
          return "Ndagusaba kuvuga mu Kinyarwanda gusa.";
        }
      }

      return content;
    }
    throw Exception('Chat failed: ${response.statusCode} - ${response.body}');
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://afrilingo.com',
      'X-Title': 'Afrilingo',
    };
  }

  // Helper method to check if text contains Kinyarwanda elements
  bool _containsKinyarwandaElements(String text) {
    // Common Kinyarwanda words and phrases
    final kinyarwandaWords = [
      'muraho',
      'amakuru',
      'yego',
      'oya',
      'murakoze',
      'ndagukunda',
      'mwaramutse',
      'mwiriwe',
      'muramuke',
      'kinyarwanda',
      'rwanda',
      'umunsi',
      'mwiza',
      'neza',
      'mbega',
      'ndashaka',
      'ndabizi',
      'ntabwo',
      'vuga',
      'gusa',
      'witwa',
      'nde',
      'uva',
      'he',
      'urakora',
      'iki',
      'numva',
      'neza',
      'ndumva',
      'kubera',
      'igihe',
      'aha',
      'naho',
      'ariko',
      'kandi',
      'cyangwa',
      'niba',
      'ngo',
      'rero',
      'kubera',
      'koko',
      'none'
    ];

    // Check if text contains any Kinyarwanda words
    final lowerText = text.toLowerCase();
    for (final word in kinyarwandaWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // Helper method to check if text is English only
  bool _isEnglishOnly(String text) {
    // Simple check for common English words
    final englishWords = [
      'the',
      'and',
      'is',
      'in',
      'to',
      'have',
      'it',
      'that',
      'for',
      'you',
      'he',
      'with',
      'on',
      'do',
      'say',
      'this',
      'they',
      'at',
      'but',
      'from',
      'not',
      'by',
      'she',
      'or',
      'as',
      'what',
      'go',
      'their',
      'can',
      'who',
      'get',
      'if',
      'would',
      'her',
      'all',
      'my',
      'make',
      'about',
      'know'
    ];

    // Count English words
    int englishWordCount = 0;
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    for (final word in words) {
      if (englishWords.contains(word)) {
        englishWordCount++;
      }
    }

    // If more than 30% of words are common English words, consider it English
    return englishWordCount > (words.length * 0.3);
  }

  // ==================== CONVERSATION STARTERS ====================
  List<String> getConversationStarters() {
    return [
      'Muraho!',
      'Amakuru?',
      'Witwa nde?',
      'Uva he?',
      'Urakora iki?',
      'Ufite umunsi mwiza?',
      'Ndashaka kwiga Kinyarwanda',
      'Mbwira iby\'umuco w\'u Rwanda',
      'Ni iyihe ndyo ikunda mu Rwanda?',
      'Untekereze umugani w\'u Rwanda',
    ];
  }
}
