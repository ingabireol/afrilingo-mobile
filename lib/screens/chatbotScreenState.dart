import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../services/deepseek_service.dart';
import '../widgets/auth/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_provider.dart';
import '../utils/app_theme.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  ? themeProvider.primaryColor.withOpacity(0.1)
                  : themeProvider.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: isUser
              ? null
              : Border.all(
                  color: isError
                      ? Colors.red.withOpacity(0.3)
                      : themeProvider.dividerColor),
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
                    ? themeProvider.primaryColor
                    : themeProvider.textColor,
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

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  DeepSeekService? _deepSeekService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isApiInitialized = false;
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();
  final String _modelName = "Mixtral 8x7B";

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _initializeDeepSeek();

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    // Clean up controllers
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
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

  void _showApiKeyInputDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();

        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          title: Text(
            'Enter OpenRouter API Key',
            style: TextStyle(
              color: themeProvider.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter your OpenRouter API key to use the Mixtral 8x7B model for enhanced Kinyarwanda conversations.',
                style: TextStyle(
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: themeProvider.lightTextColor),
                  filled: true,
                  fillColor: themeProvider.isDarkMode
                      ? Colors.black12
                      : Colors.grey.shade50,
                ),
                style: TextStyle(color: themeProvider.textColor),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'The Mixtral 8x7B model provides more natural conversations in Kinyarwanda.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: themeProvider.lightTextColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.accentColor,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () async {
                final apiKey = controller.text.trim();
                if (apiKey.isNotEmpty) {
                  await DeepSeekService.saveApiKey(apiKey);
                  Navigator.of(context).pop();
                  _initializeDeepSeek();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Afrilingo AI Chatbot',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Powered by $_modelName',
              style: TextStyle(
                color: themeProvider.lightTextColor,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: themeProvider.textColor),
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: themeProvider.accentColor,
            ),
            onPressed: () {
              _showInfoDialog();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: themeProvider.textColor,
            ),
            onPressed: () {
              _showApiKeyInputDialog();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(themeProvider)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _messages[index];
                      },
                    ),
            ),

            // Bottom input area
            Container(
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: Row(
                  children: [
                    // Input field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: themeProvider.dividerColor,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message in any language...',
                            hintStyle:
                                TextStyle(color: themeProvider.lightTextColor),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          style: TextStyle(color: themeProvider.textColor),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _isApiInitialized && !_isSending
                              ? (text) => _handleMessage(text)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isSending
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isApiInitialized && !_isSending
                            ? () => _handleMessage(_messageController.text)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 4),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: themeProvider.lightTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation in any language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'The AI will respond in Kinyarwanda, helping you learn new words and phrases.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.lightTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'About Afrilingo AI Chatbot',
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This chatbot uses the Mixtral 8x7B model to provide natural conversations in Kinyarwanda.',
              style: TextStyle(color: themeProvider.textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Tips:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildTipItem(
              '• You can ask questions in English, French, or any other language',
              themeProvider,
            ),
            _buildTipItem(
              '• The AI will always respond in Kinyarwanda',
              themeProvider,
            ),
            _buildTipItem(
              '• Try asking for translations, explanations, or cultural information',
              themeProvider,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: themeProvider.primaryColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 14,
        ),
      ),
    );
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
            text: "Error: $error",
            isUser: false,
            isError: true,
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    // Add a slight delay to ensure the list is updated before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(const ChatMessage(
        text:
            "Muraho! Ndi Afrilingo AI, nzakufasha kwiga Ikinyarwanda. Ushobora kumbaza ikibazo mu rurimi urwo ari rwo rwose, nzagusubiza mu Kinyarwanda.\n\n(Hello! I am Afrilingo AI, I will help you learn Kinyarwanda. You can ask me questions in any language, and I will respond in Kinyarwanda.)",
        isUser: false,
      ));
    });
  }
}
