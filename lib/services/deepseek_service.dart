import 'package:http/http.dart' as http;
import 'dart:convert';

class DeepSeekService {
  final String _baseUrl = 'https://openrouter.ai/api/v1';
  // Default API key - Replace this with your actual DeepSeek API key
  static const String defaultApiKey = 'sk-or-v1-317d8f35e4a68d3f8cbf1f1a0f5c9c4c6b7a9e8d7f6e5d4c3b2a1908070605';
  final String _apiKey;

  // Constructor that uses default API key if none provided
  DeepSeekService([String? apiKey]) : _apiKey = apiKey ?? defaultApiKey;

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
      throw Exception('Failed to connect to OpenRouter API: $e');
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
      throw Exception('Failed to connect to OpenRouter API: $e');
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