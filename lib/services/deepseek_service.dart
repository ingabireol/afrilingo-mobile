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

  void _initializeApiKey() {
    String key = _apiKey.isNotEmpty ? _apiKey : (dotenv.env['OPENROUTER_API_KEY'] ?? '');
    if (key.isEmpty) {
      getApiKey().then((savedKey) {
        if (savedKey != null && savedKey.isNotEmpty) {
          key = savedKey;
        }
      });
    }
    if (key.isEmpty) {
      throw Exception('OpenRouter API Key is not set. Please check your .env file or provide a valid API key.');
    }
    if (!key.startsWith('sk-')) {
      throw Exception('Invalid API key format. API key should start with "sk-"');
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
              'content': 'You are a professional Kinyarwanda translator. Translate ONLY into pure, natural Kinyarwanda. No prefixes, no explanations.'
            },
            {
              'role': 'user',
              'content': '[Translate to Kinyarwanda] $text'
            }
          ],
          'temperature': 0.2,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String translation = data['choices'][0]['message']['content'].trim();
        if (translation.isEmpty) {
          throw Exception('Received empty translation.');
        }
        return translation;
      } else {
        throw Exception('Translation failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication failed: Invalid or expired API key.');
      } else {
        throw Exception('Failed to connect to OpenRouter API: $e');
      }
    }
  }

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
              'content': '''You are a native Kinyarwanda language tutor.
Keep answers short (1-3 sentences), friendly, and in natural Kinyarwanda. 
Do not explain unless requested. Encourage conversation.'''
            },
            {
              'role': 'user',
              'content': '[Respond in Kinyarwanda] $message'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String reply = data['choices'][0]['message']['content'].trim();
        if (reply.isEmpty) {
          throw Exception('Received empty chat response.');
        }
        return reply;
      } else {
        throw Exception('Chat failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication failed: Invalid or expired API key.');
      } else {
        throw Exception('Failed to connect to OpenRouter API: $e');
      }
    }
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://afrilingo.com',
      'X-Title': 'Afrilingo',
    };
  }

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
