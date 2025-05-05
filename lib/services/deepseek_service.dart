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
        _model = model ?? 'deepseek/deepseek-v3-base:free' {
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
              'content': 'You are a Kinyarwanda translator. Translate the following text to Kinyarwanda. Respond only with the translation, no explanations.'
            },
            {
              'role': 'user',
              'content': 'Translate this to Kinyarwanda: $text'
            }
          ],
          'temperature': 0.1,
          'max_tokens': 100,
          'top_p': 0.1,
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
              'content': '''You are a native Kinyarwanda speaker. You must respond in Kinyarwanda only.

Example responses:
- For greetings: "Muraho", "Amakuru", "Mwaramutse"
- For questions: "Witwa nde?", "Uva he?", "Urakora iki?"
- For unclear messages: "Vuga Kinyarwanda gusa"
- For English input: "Vuga Kinyarwanda gusa"

Keep responses short and natural.'''
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.5,
          'max_tokens': 50,
          'top_p': 0.5,
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
      
      // Remove any English words
      content = content.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
      
      // If content is empty after removing English, return default message
      if (content.isEmpty) {
        return "Ntago byumvikana";
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
      
      // Remove any English words
      content = content.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
      
      // If content is empty after removing English, return default message
      if (content.isEmpty) {
        return "Vuga Kinyarwanda gusa";
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
