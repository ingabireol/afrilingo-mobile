import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../services/deepseek_service.dart';
import '../widgets/auth/navigation_bar.dart';

// Chat message widget
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
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
          color: isUser ? Colors.brown[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.black87 : Colors.black,
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
  final ScrollController _scrollController = ScrollController();
  bool _isTranslationMode = false;

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
    });

    try {
      _messages.clear();
      _messages.add(const ChatMessage(
        text: 'Initializing DeepSeek service...',
        isUser: false,
      ));

      bool envLoaded = false;
      try {
        String mainPath = 'd:/clb/Workspace/afrilingo/afrilingo/.env';
        await dotenv.load(fileName: mainPath);
        envLoaded = true;
      } catch (e) {
        try {
          String envPath = _findEnvFile();
          await dotenv.load(fileName: envPath);
          envLoaded = true;
        } catch (envError) {
          print('Environment file not found: $envError');
        }
      }

      if (!envLoaded) {
        setState(() {
          if (_messages.isNotEmpty) _messages.removeLast();
          _messages.add(const ChatMessage(
            text: 'Could not find .env file with API key.',
            isUser: false,
          ));
        });
        _showApiKeyInputDialog();
        return;
      }

      final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _showApiKeyInputDialog();
        return;
      }

      _deepSeekService = DeepSeekService.withApiKey(apiKey);
      setState(() {
        _isApiInitialized = true;
        _isLoading = false;
        if (_messages.isNotEmpty) _messages.removeLast();
        _messages.add(const ChatMessage(
          text: 'Hello! I can help you with Kinyarwanda translation and conversation. What would you like to do?',
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty) _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Error initializing DeepSeek: $e',
          isUser: false,
        ));
      });
    }
  }

  Future<void> _handleMessage(String message) async {
    if (message.isEmpty) return;

    // Add user message immediately
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _messageController.clear();
    });

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      String response;
      if (_isTranslationMode) {
        response = await _deepSeekService!.translateToKinyarwanda(message);
      } else {
        response = await _deepSeekService!.chatInKinyarwanda(message);
      }

      // Update state with the response
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Ntabwo nashoboye gusubiza. Ongera ugerageze. Error: $error',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showModeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Translation Mode'),
                subtitle: const Text('Translate English to Kinyarwanda'),
                onTap: () {
                  setState(() {
                    _isTranslationMode = true;
                    _messages.clear();
                    _messages.add(const ChatMessage(
                      text: 'Translation mode activated. Enter English text to translate to Kinyarwanda.',
                      isUser: false,
                    ));
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat Mode'),
                subtitle: const Text('Chat in Kinyarwanda'),
                onTap: () {
                  setState(() {
                    _isTranslationMode = false;
                    _messages.clear();
                    _messages.add(const ChatMessage(
                      text: 'Chat mode activated. Let\'s chat in Kinyarwanda!',
                      isUser: false,
                    ));
                    _addWelcomeMessage();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
              title: const Text('DeepSeek API Key Required'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To use the chatbot feature, you need to provide a DeepSeek API key.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to https://deepseek.com/api-keys\n'
                      '2. Sign in or create an account\n'
                      '3. Click "Create new secret key"\n'
                      '4. Copy the key and paste it below',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        border: const OutlineInputBorder(),
                        hintText: 'sk-...',
                        errorText: apiKeyController.text.isNotEmpty && !isValidFormat 
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
                      'Note: Your API key will only be stored in this app and used for the chatbot.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
                  onPressed: () {
                    final apiKey = apiKeyController.text.trim();
                    if (apiKey.isNotEmpty && apiKey.startsWith('sk-')) {
                      // Set the API key for the chatbot service
                      Navigator.of(context).pop();
                      
                      // Initialize ChatbotService with the provided API key
                      try {
                        setState(() {
                          _deepSeekService = DeepSeekService.withApiKey(apiKey);
                          _isLoading = false;
                          _isApiInitialized = true;
                        });
                        
                        // Add welcome message
                        _addWelcomeMessage();
                      } catch (e) {
                        _showInitializationErrorDialog(e.toString());
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

  // Show initialization error dialog
  void _showInitializationErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Initialization Error'),
          content: Text(
            'Ntabwo byagenze neza: $errorMessage\n\n'
            'Hakenewe gukora ibinini bikurikira:\n'
            '1. Hakikisha .env file ufite API key\n'
            '2. Koresha API key yemewe\n'
            '3. Ensure .env is in the correct directory',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ego (OK)'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Add a welcome message to the chat
  void _addWelcomeMessage() {
    setState(() {
      _messages.add(const ChatMessage(
        text: 'Muraho! Ndaje kukubaza ibibazo mu Kinyarwanda.',
        isUser: false,
      ));
      
      // Add a message explaining how to use the chatbot
      _messages.add(const ChatMessage(
        text: 'Nshobora kugufasha kwiga Kinyarwanda. Andika ubutumwa bwawe hasi hanyuma ukande buto yo kohereza.',
        isUser: false,
      ));
      
      // Add conversation starters
      if (_deepSeekService != null) {
        final starters = _deepSeekService!.getConversationStarters();
        _messages.add(ChatMessage(
          text: 'Dore ingero z\'ibibazo ushobora kubaza:\n• ${starters.join('\n• ')}',
          isUser: false,
        ));
      }
    });
    
    // Scroll to bottom to show all messages
    _scrollToBottom();
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
      appBar: AppBar(
        title: const Text('Kinyarwanda Assistant'),
        backgroundColor: Colors.brown[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isTranslationMode ? Icons.translate : Icons.chat),
            onPressed: _showModeSelectionDialog,
            tooltip: 'Change Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _isTranslationMode ? Colors.blue[50] : Colors.green[50],
            child: Center(
              child: Text(
                _isTranslationMode
                    ? 'Translation Mode: English → Kinyarwanda'
                    : 'Chat Mode: Let\'s chat in Kinyarwanda!',
                style: TextStyle(
                  color: _isTranslationMode ? Colors.blue[900] : Colors.green[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Chat messages list
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _messages[index],
                  ),
          ),
          
          // Loading indicator
          if (_isLoading && _messages.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      hintText: _isTranslationMode
                          ? 'Enter English text to translate...'
                          : 'Type your message in Kinyarwanda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onSubmitted: (_) => _handleMessage(_messageController.text.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleMessage(_messageController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
