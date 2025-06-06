import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/chat/services/deepseek_service.dart';

import 'package:afrilingo/features/exercise/screens/listening.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Kinyarwanda';
  final TextEditingController _sourceTextController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  bool _isInitialized = false;
  DeepSeekService? _deepSeekService;
  String? _initError;
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
    _sourceTextController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeDeepSeek() async {
    try {
      setState(() {
        _isInitialized = false;
        _initError = null;
      });

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
          _isInitialized = true;
        });
        return;
      }

      // No valid API key found, show dialog
      setState(() {
        _initError = "API key not found or invalid";
      });
      _showApiKeyInputDialog();
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _initError = e.toString();
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
                'Please enter your OpenRouter API key to use the Mixtral 8x7B translation service. '
                'You can get a key from openrouter.ai',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                ),
                style: TextStyle(color: themeProvider.textColor),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'The Mixtral 8x7B model provides more accurate translations for Kinyarwanda.',
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

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Clear translations when swapping
      _translatedText = '';
    });
  }

  Future<void> _translate() async {
    if (_sourceTextController.text.isEmpty || !_isInitialized) return;

    setState(() {
      _isTranslating = true;
      // Clear previous translation while waiting for new one
      _translatedText = '';
    });

    try {
      String result;

      if (_sourceLanguage == 'English' && _targetLanguage == 'Kinyarwanda') {
        // English to Kinyarwanda
        result = await _deepSeekService!
            .translateToKinyarwanda(_sourceTextController.text);
      } else {
        // For now, just handle translation in one direction
        // In a real app, you would implement reverse translation
        result =
            "Reverse translation (Kinyarwanda to English) is not yet implemented.";
      }

      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = "Translation error: ${e.toString()}";
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translate',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: themeProvider.textColor,
            ),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.history, color: themeProvider.textColor),
            tooltip: 'Translation History',
            onPressed: () {
              // Show translation history
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: themeProvider.textColor),
            tooltip: 'Translation Settings',
            onPressed: () {
              // Show translation settings
              _showApiKeyInputDialog();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: _initError != null
              ? _buildErrorState(themeProvider)
              : _buildTranslationInterface(themeProvider),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 3),
    );
  }

  Widget _buildErrorState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: themeProvider.isDarkMode ? Colors.redAccent : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Translation Service Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _initError ?? 'Failed to initialize translation service',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _showApiKeyInputDialog();
              },
              child: const Text('Configure API Key'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationInterface(ThemeProvider themeProvider) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        // Language selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Text(
                      _sourceLanguage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.swap_horiz,
                      color: themeProvider.primaryColor,
                    ),
                    onPressed: _swapLanguages,
                  ),
                  Expanded(
                    child: Text(
                      _targetLanguage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content area (scrollable)
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Input field
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter text to translate",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: keyboardVisible
                                ? 100
                                : 150, // Adjust height based on keyboard visibility
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.black12
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _sourceTextController,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Type here...',
                                hintStyle: TextStyle(
                                    color: themeProvider.lightTextColor),
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: themeProvider.dividerColor,
                                    width: 0.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: themeProvider.dividerColor,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: themeProvider.primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                              ),
                              onChanged: (_) {
                                // Clear translation when input changes
                                if (_translatedText.isNotEmpty) {
                                  setState(() {
                                    _translatedText = '';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.content_copy,
                                  color: themeProvider.accentColor,
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _sourceTextController.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Text copied to clipboard'),
                                      backgroundColor:
                                          themeProvider.primaryColor,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: themeProvider.lightTextColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sourceTextController.clear();
                                    _translatedText = '';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Translate button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed:
                          _isInitialized && !_isTranslating ? _translate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isTranslating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Translate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // Output field
                  Container(
                    margin: EdgeInsets.only(bottom: keyboardVisible ? 8 : 16),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Translation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: keyboardVisible
                                ? 80
                                : 150, // Adjust height based on keyboard visibility
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.black12
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: themeProvider.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _translatedText.isEmpty
                                    ? 'Translation will appear here'
                                    : _translatedText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _translatedText.isEmpty
                                      ? themeProvider.lightTextColor
                                      : themeProvider.textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_translatedText.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.content_copy,
                                    color: themeProvider.accentColor,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _translatedText));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Translation copied to clipboard'),
                                        backgroundColor:
                                            themeProvider.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: themeProvider.accentColor,
                                  ),
                                  onPressed: () {
                                    // Text-to-speech functionality for the translation
                                    // This would be implemented in a real app
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
