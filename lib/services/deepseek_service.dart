import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  final String _baseUrl = 'https://openrouter.ai/api/v1';
  // Default API key that can be overridden
  static const String _defaultApiKey = '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';
  final String _apiKey;

  DeepSeekService() : _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? _defaultApiKey {
    if (_apiKey.isEmpty) {
      throw Exception('OpenRouter API Key is not set.');
    }
  }

  DeepSeekService.withApiKey(this._apiKey);

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
              'content': """
Ufite uruhare rwo gufasha abanyarwanda kwiga Kinyarwanda. 
Genzura ibikurikira:
1. Subiza mu Kinyarwanda gusa.
2. Subiza ibibazo by'umuntu gusa, ntugire ibindi.
3. Koresha amagambo maremare.
4. Subiza ibibazo by'umuntu gusa, ntugire ibindi.
5. Niba umaze kubaza ikibazo mu rurimi rundi, subiramo mu Kinyarwanda.
6. Subiza ibibazo by'umuntu gusa, ntugire ibindi."""
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.7,
          'max_tokens': 200,
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