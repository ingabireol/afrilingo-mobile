import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  // API key for OpenAI
  final String _apiKey;

  // Store conversation history
  final List<Map<String, String>> _conversationHistory = [];

  // Constructor using .env file
  ChatbotService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '' {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw Exception(
          'OpenAI API Key is not set. Please check your .env file or enter a valid API key.');
    }

    // Check if API key has the correct format - allowing both standard and service account keys
    if (!_apiKey.startsWith('sk-')) {
      throw Exception(
          'Invalid OpenAI API Key format. The key should start with "sk-".');
    }

    // Initialize OpenAI with your API key
    OpenAI.apiKey = _apiKey;

    // Add system message to conversation history
    _conversationHistory.add({
      'role': 'system',
      'content': """
Ufite uruhare rwo gufasha abanyarwanda kwiga Kinyarwanda. 
Genzura ibikurikira:
1. Subiza mu Kinyarwanda gusa. Ntugire na kimwe mu ndimi zindi.
2. Kora neza, uhumurize kandi urangize.
3. Niba umaze kubaza ikibazo mu rurimi rundi, subiramo mu Kinyarwanda.
4. Kora nk'umwarimu w'ururimi rwa Kinyarwanda.
5. Koresha amagambo n'interuro zifite ireme.

Ababaza bakwifuza kubona ibisubizo mu Kinyarwanda gusa."""
    });
  }

  // Constructor that accepts an API key directly
  ChatbotService.withApiKey(this._apiKey) {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API Key is empty or invalid.');
    }

    // Check if API key has the correct format - allowing both standard and service account keys
    if (!_apiKey.startsWith('sk-')) {
      throw Exception(
          'Invalid OpenAI API Key format. The key should start with "sk-".');
    }

    // Initialize OpenAI with the provided API key
    OpenAI.apiKey = _apiKey;

    // Add system message to conversation history
    _conversationHistory.add({
      'role': 'system',
      'content': """
Ufite uruhare rwo gufasha abanyarwanda kwiga Kinyarwanda. 
Genzura ibikurikira:
1. Subiza mu Kinyarwanda gusa. Ntugire na kimwe mu ndimi zindi.
2. Kora neza, uhumurize kandi urangize.
3. Niba umaze kubaza ikibazo mu rurimi rundi, subiramo mu Kinyarwanda.
4. Kora nk'umwarimu w'ururimi rwa Kinyarwanda.
5. Koresha amagambo n'interuro zifite ireme.

Ababaza bakwifuza kubona ibisubizo mu Kinyarwanda gusa."""
    });
  }

  Future<String> generateKinyarwandaResponse(String userMessage) async {
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // First try direct API call (skipping dart_openai package which might have issues)
      try {
        print('Attempting direct API call first');
        return await _directApiCall(userMessage);
      } catch (directApiError) {
        // If direct API call fails, fall back to dart_openai
        print('Direct API call failed: $directApiError, trying dart_openai');
        
        try {
          final chatCompletion = await OpenAI.instance.chat.create(
            model: "gpt-3.5-turbo",
            messages: _conversationHistory
                .map((message) => OpenAIChatCompletionChoiceMessageModel(
                      role: message['role'] == 'user'
                          ? OpenAIChatMessageRole.user
                          : message['role'] == 'system'
                              ? OpenAIChatMessageRole.system
                              : OpenAIChatMessageRole.assistant,
                      content: message['content'] ?? '',
                    ))
                .toList(),
            temperature: 0.7,
            maxTokens: 200,
          );

          // Get the response
          String response = chatCompletion.choices.first.message.content.trim();

          // Add assistant response to conversation history
          _conversationHistory.add({
            'role': 'assistant',
            'content': response,
          });

          // Keep conversation history manageable (last 10 messages)
          if (_conversationHistory.length > 11) {
            // 1 system message + 10 conversation messages
            _conversationHistory.removeRange(1, _conversationHistory.length - 10);
          }

          return response;
        } catch (dartOpenAIError) {
          print('Both API methods failed. Last error: $dartOpenAIError');
          throw Exception('Failed to generate response: $dartOpenAIError');
        }
      }
    } catch (e) {
      print('Error generating response: $e');
      return 'Ntabwo nashoboye gusubiza. Ongera ugerageze. Error: $e';
    }
  }

  // Direct API call as fallback
  Future<String> _directApiCall(String userMessage) async {
    try {
      print('Attempting direct API call with message: $userMessage');
      print('API Key length: ${_apiKey.length} characters, starts with: ${_apiKey.substring(0, 10)}...');
      
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Successful API response received');
        final data = jsonDecode(response.body);
        String assistantResponse =
            data['choices'][0]['message']['content'].trim();

        // Add assistant response to conversation history
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantResponse,
        });

        // Keep conversation history manageable
        if (_conversationHistory.length > 11) {
          _conversationHistory.removeRange(1, _conversationHistory.length - 10);
        }

        return assistantResponse;
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        // Try to extract detailed error message
        String errorDetails = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData.containsKey('error')) {
            errorDetails = errorData['error']['message'] ?? errorDetails;
          }
        } catch (e) {
          errorDetails = 'Failed to parse error response: $e';
        }
        print('Error details: $errorDetails');
        
        return 'Ntabwo nashoboye gusubiza. Ongera ugerageze. Error: $errorDetails';
      }
    } catch (e) {
      print('Direct API call error: $e');
      return 'Ntabwo nashoboye gusubiza. Ongera ugerageze. Connectivity error: $e';
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
