import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../services/deepseek_service.dart';
import '../widgets/auth/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

// Chat message widget
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isUser ? 64 : 16,
          right: isUser ? 16 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.withOpacity(0.1)
              : isUser
                  ? kPrimaryColor.withOpacity(0.1)
                  : kCardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: isUser
              ? null
              : Border.all(
                  color: isError ? Colors.red.withOpacity(0.3) : kDividerColor),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isError
                ? Colors.red
                : isUser
                    ? kPrimaryColor
                    : kTextColor,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  DeepSeekService? _deepSeekService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isApiInitialized = false;
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();
  final String _modelName = "Mixtral 8x7B";

  @override
  void initState() {
    super.initState();
    _initializeDeepSeek();
  }

  @override
  void dispose() {
    // Clean up controllers
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeDeepSeek() async {
    setState(() {
      _isLoading = true;
      _isApiInitialized = false;
    });

    try {
      _messages.clear();
      _messages.add(const ChatMessage(
        text:
            'Initializing Mixtral 8x7B AI model for improved Kinyarwanda conversation...',
        isUser: false,
      ));

      // Try to get API key from preferences first
      String? apiKey = await DeepSeekService.getApiKey();

      // If no API key in preferences, try environment variable
      if (apiKey == null || apiKey.isEmpty) {
        try {
          await dotenv.load();
          apiKey = dotenv.env['OPENROUTER_API_KEY'];
        } catch (e) {
          print('Failed to load .env file: $e');
        }
      }

      // If we have a valid API key, initialize the service
      if (apiKey != null && apiKey.isNotEmpty && apiKey.startsWith('sk-')) {
        _deepSeekService =
            DeepSeekService(apiKey, 'mistralai/mixtral-8x7b-instruct');
        setState(() {
          _isLoading = false;
          _isApiInitialized = true;
        });
        _addWelcomeMessage();
        return;
      }

      // No valid API key found, show dialog
      _showApiKeyInputDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty) _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Error initializing service: $e',
          isUser: false,
          isError: true,
        ));
      });
      _showApiKeyInputDialog();
    }
  }

  Future<void> _handleMessage(String message) async {
    if (message.isEmpty) return;

    // Don't allow multiple simultaneous message sends
    if (_isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      // Always use chatInKinyarwanda since we removed translation mode
      String response = await _deepSeekService!.chatInKinyarwanda(message);

      // Update state with the response
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Ntabwo nashoboye gusubiza. Ongera ugerageze. Error: $error',
            isUser: false,
            isError: true,
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  // Find the .env file in the project directory
  String _findEnvFile() {
    // Potential directories to search
    List<String> searchPaths = [
      // Current directory
      Directory.current.path,
      // Project root
      'd:/clb/Workspace/afrilingo/afrilingo',
      // Lib directory
      'd:/clb/Workspace/afrilingo/afrilingo/lib',
      // Absolute path
      'd:/clb/Workspace/afrilingo/afrilingo/.env'
    ];

    for (var searchPath in searchPaths) {
      final envFile = File(path.join(searchPath, '.env'));
      if (envFile.existsSync()) {
        print('Found .env file at: ${envFile.path}');
        return envFile.path;
      }
    }

    // If no .env file found, throw an exception
    throw Exception(
        'No .env file found. Please create one with DEEPSEEK_API_KEY');
  }

  // Show API key dialog for errors or missing key
  void _showApiKeyDialog(String message) {
    _showApiKeyInputDialog();
  }

  // Show API key input dialog
  void _showApiKeyInputDialog() {
    final TextEditingController apiKeyController = TextEditingController();
    bool isValidFormat = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('OpenRouter API Key Required'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To use the Mixtral 8x7B AI for Kinyarwanda conversations, you need to provide an OpenRouter API key.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to https://openrouter.ai/keys\n'
                      '2. Sign in or create an account\n'
                      '3. Create a new API key\n'
                      '4. Copy the key and paste it below',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        border: const OutlineInputBorder(),
                        hintText: 'sk-...',
                        errorText:
                            apiKeyController.text.isNotEmpty && !isValidFormat
                                ? 'Key must start with sk-'
                                : null,
                        prefixIcon: const Icon(Icons.key),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          isValidFormat = value.trim().startsWith('sk-');
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Your API key will be securely stored for future use.',
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                TextButton(
                  child: const Text('Save & Continue'),
                  onPressed: () async {
                    final apiKey = apiKeyController.text.trim();
                    if (apiKey.isNotEmpty && apiKey.startsWith('sk-')) {
                      // Save API key to preferences
                      await DeepSeekService.saveApiKey(apiKey);

                      Navigator.of(context).pop();

                      // Initialize service with the provided API key
                      try {
                        _deepSeekService = DeepSeekService(
                            apiKey, 'mistralai/mixtral-8x7b-instruct');
                        setState(() {
                          _isLoading = false;
                          _isApiInitialized = true;
                        });
                        _addWelcomeMessage();
                      } catch (e) {
                        _showErrorDialog('Failed to initialize service: $e');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Your API key is valid and starts with sk-\n'
                '2. The API key has sufficient permissions\n'
                '3. You have an active internet connection',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _showApiKeyInputDialog();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                  _isApiInitialized = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Add a welcome message to the chat
  void _addWelcomeMessage() {
    if (_messages.isNotEmpty) _messages.removeLast();
    _messages.add(const ChatMessage(
      text: 'Muraho! Nitwa Afrilingo. Mbwira amakuru yawe.',
      isUser: false,
    ));
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kinyarwanda Chat',
              style: TextStyle(
                color: kTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Powered by $_modelName',
              style: TextStyle(
                color: kLightTextColor,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              _showApiKeyInputDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isApiInitialized
                  ? (_messages.isEmpty ? _buildEmptyState() : _buildChatList())
                  : _buildLoadingOrError(),
            ),
          ),
          _buildInputArea(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 3),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: kLightTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet. Start chatting in Kinyarwanda!',
            style: TextStyle(color: kLightTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _deepSeekService?.getConversationStarters() ??
        [
          'Muraho!',
          'Amakuru?',
          'Witwa nde?',
        ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          backgroundColor: kBackgroundColor,
          side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
          onPressed: () => _handleMessage(suggestion),
        );
      }).toList(),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isSending) {
          // Show typing indicator
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 16,
                right: 64,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(color: kDividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ndatega...',
                    style: TextStyle(
                      color: kLightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _messages[index];
      },
    );
  }

  Widget _buildLoadingOrError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                )
              : Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _messages.isNotEmpty
                  ? _messages.last.text
                  : 'Initializing Mixtral 8x7B...',
              style: TextStyle(color: kLightTextColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (!_isLoading)
            ElevatedButton(
              onPressed: _initializeDeepSeek,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: kLightTextColor),
                filled: true,
                fillColor: kBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _messageController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: kLightTextColor, size: 20),
                        onPressed: () {
                          setState(() {
                            _messageController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (text) {
                setState(() {}); // Rebuild to show/hide clear button
              },
              onSubmitted: (_) =>
                  _handleMessage(_messageController.text.trim()),
              enabled: !_isSending && _isApiInitialized,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isSending || !_isApiInitialized
                  ? kPrimaryColor.withOpacity(0.5)
                  : kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending || !_isApiInitialized
                  ? null
                  : () => _handleMessage(_messageController.text.trim()),
            ),
          ),
        ],
      ),
    );
  }
}
