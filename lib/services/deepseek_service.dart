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
        _model = model ?? 'mistralai/mistral-7b-instruct' {
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

  // ==================== STRICT KINYARWANDA TRANSLATION ====================
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
              'content': '''You are a professional Kinyarwanda translator and language tutor. Your task is to:
1. Translate the given English text to Kinyarwanda
2. Ensure the translation is natural and culturally appropriate
3. Maintain the original meaning and context
4. Use proper Kinyarwanda grammar and vocabulary
5. ALWAYS respond in Kinyarwanda using proper Latin characters

Respond only with the translation, no explanations or English text.'''
            },
            {
              'role': 'user',
              'content': 'Translate this to Kinyarwanda: $text'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 250,
          'top_p': 0.7,
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
              'content': '''You are a native Kinyarwanda tutor and conversation partner. Your role is to:
1. Respond ONLY in Kinyarwanda using proper Latin characters
2. Help users learn and practice Kinyarwanda
3. Provide natural, conversational responses
4. Use proper grammar and vocabulary
5. Be encouraging and supportive

Example responses:
- For greetings: "Muraho", "Amakuru", "Mwaramutse"
- For questions: "Witwa nde?", "Uva he?", "Urakora iki?"
- For unclear messages: "Vuga Kinyarwanda gusa"
- For English input: "Vuga Kinyarwanda gusa"

NEVER respond with question marks only. Always provide meaningful Kinyarwanda text.
Keep responses natural, educational, and engaging.'''
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.6,
          'max_tokens': 200,
          'top_p': 0.8,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
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
      if (content.isEmpty || content == "?" || content == "??" || content == " ") {
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
    throw Exception('Translation failed: ${response.statusCode}');
  }

  String _processChatResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String content = data['choices'][0]['message']['content'].trim();
      
      // Check for empty or invalid responses
      if (content.isEmpty || content == "?" || content == "??" || content == " ") {
        return "Vuga Kinyarwanda gusa";
      }
      
      // Kinyarwanda uses Latin alphabet, so we don't remove Latin characters
      // Instead, we'll check if the response contains at least some Kinyarwanda-specific elements
      if (!_containsKinyarwandaElements(content)) {
        print('Response may not be valid Kinyarwanda: $content');
        // If the response is clearly in English, prompt for Kinyarwanda
        if (_isEnglishOnly(content)) {
          return "Vuga Kinyarwanda gusa";
        }
      }
      
      return content;
    }
    throw Exception('Chat failed: ${response.statusCode}');
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
      'muraho', 'amakuru', 'yego', 'oya', 'murakoze', 'ndagukunda',
      'mwaramutse', 'mwiriwe', 'muramuke', 'kinyarwanda', 'rwanda',
      'umunsi', 'mwiza', 'neza', 'mbega', 'ndashaka', 'ndabizi',
      'ntabwo', 'vuga', 'gusa', 'witwa', 'nde', 'uva', 'he', 'urakora', 'iki'
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
      'the', 'and', 'is', 'in', 'to', 'have', 'it', 'that', 'for',
      'you', 'he', 'with', 'on', 'do', 'say', 'this', 'they', 'at', 'but'
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
    ];
  }
}


