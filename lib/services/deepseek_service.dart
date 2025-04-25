import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _apiKey;
  final String _baseUrl = 'https://openrouter.ai/api/v1';

  // Constructor that uses environment variable for API key
  DeepSeekService([String? apiKey]) : _apiKey = apiKey ?? (dotenv.env['OPENROUTER_API_KEY'] ?? '') {
    if (_apiKey.isEmpty) {
      throw Exception('OpenRouter API Key is not set. Please check your .env file or provide a valid API key.');
    }
    // Validate API key format
    if (!_apiKey.startsWith('sk-')) {
      throw Exception('Invalid API key format. API key should start with "sk-"');
    }
  }

  // Static method to get API key from preferences
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openrouter_api_key');
  }

  // Static method to save API key to preferences
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openrouter_api_key', apiKey);
  }

  Future<String> translateToKinyarwanda(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://afrilingo.com',
          'X-Title': 'Afrilingo',
        },
        body: json.encode({
          'model': 'deepseek/deepseek-v3-base:free',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a translator. Your task is to translate English to Kinyarwanda. Only provide the translation, no explanations or additional text. Keep the translation concise and accurate.'
            },
            {
              'role': 'user',
              'content': 'Translate this to Kinyarwanda: $text'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String translation = data['choices'][0]['message']['content'].trim();
        // Remove any "Translation:" or similar prefixes
        translation = translation.replaceAll(RegExp(r'^[Tt]ranslation:?\s*'), '');
        return translation;
      } else {
        throw Exception('Translation failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication failed: Invalid or expired API key. Please check your API key and try again.');
      } else {
        throw Exception('Failed to connect to OpenRouter API: $e');
      }
    }
  }

  Future<String> chatInKinyarwanda(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://afrilingo.com',
          'X-Title': 'Afrilingo',
        },
        body: json.encode({
          'model': 'deepseek/deepseek-v3-base:free',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a Kinyarwanda language tutor.
              1. Always respond in Kinyarwanda only
              2. Be helpful and encouraging
              3. If a question is asked in another language, rephrase it in Kinyarwanda
              4. Act as a Kinyarwanda language teacher
              5. Use natural and meaningful phrases'''
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('Chat failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication failed: Invalid or expired API key. Please check your API key and try again.');
      } else {
        throw Exception('Failed to connect to OpenRouter API: $e');
      }
    }
  }

  // Get conversation starters in Kinyarwanda
  List<String> getConversationStarters() {
    return [
      'Muraho! (Hello!)',
      'Amakuru? (How are you?)',
      'Izina ryawe ni nde? (What is your name?)',
      'Uva he? (Where are you from?)',
      'Ufite imyaka ingahe? (How old are you?)',
      'Ukunda iki? (What do you like?)',
      'Urakora iki? (What do you do?)',
    ];
  }
}