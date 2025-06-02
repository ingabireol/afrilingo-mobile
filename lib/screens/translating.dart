import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/deepseek_service.dart';

import 'listening.dart';

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

class _TranslationScreenState extends State<TranslationScreen> {
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Kinyarwanda';
  final TextEditingController _sourceTextController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  bool _isInitialized = false;
  DeepSeekService? _deepSeekService;
  String? _initError;
  final String _modelName = "Mixtral 8x7B";

  @override
  void initState() {
    super.initState();
    _initializeDeepSeek();
  }

  @override
  void dispose() {
    _sourceTextController.dispose();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();

        return AlertDialog(
          title: const Text('Enter OpenRouter API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your OpenRouter API key to use the Mixtral 8x7B translation service. '
                'You can get a key from openrouter.ai',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'sk-...',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'The Mixtral 8x7B model provides more accurate translations for Kinyarwanda.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translate',
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
        iconTheme: IconThemeData(color: kTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Translation History',
            onPressed: () {
              // Show translation history
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Translation Settings',
            onPressed: () {
              // Show translation settings
              _showApiKeyInputDialog();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _initError != null
            ? _buildErrorView()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Language Selection Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLanguageSelector(_sourceLanguage),
                            GestureDetector(
                              onTap: _swapLanguages,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.swap_horiz,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            _buildLanguageSelector(_targetLanguage),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Source Text Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _sourceLanguage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.mic,
                                          color: kPrimaryColor),
                                      tooltip: 'Voice Input',
                                      onPressed: () {
                                        // Handle voice input
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ListeningScreen()),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.content_copy,
                                          color: kLightTextColor),
                                      tooltip: 'Copy Text',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                              text: _sourceTextController.text),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Text copied to clipboard'),
                                            duration: Duration(seconds: 1),
                                            backgroundColor: kPrimaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: kLightTextColor),
                                      tooltip: 'Clear Text',
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
                            const SizedBox(height: 16),
                            TextField(
                              controller: _sourceTextController,
                              decoration: InputDecoration(
                                hintText: 'Enter text to translate',
                                hintStyle: TextStyle(color: kLightTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: kDividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: kPrimaryColor),
                                ),
                              ),
                              maxLines: 5,
                              minLines: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Translation Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isInitialized && !_isTranslating
                              ? _translate
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            disabledBackgroundColor:
                                kPrimaryColor.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isTranslating
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Translating...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Translate with Mixtral AI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Translation Result
                      if (_isTranslating)
                        _buildTranslationLoadingIndicator()
                      else if (_translatedText.isNotEmpty)
                        _buildTranslationResult(),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget _buildTranslationLoadingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _targetLanguage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Generating high-quality $_targetLanguage translation...',
            style: TextStyle(
              color: kLightTextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationResult() {
    final isError = _translatedText.startsWith("Translation error:");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _targetLanguage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              Row(
                children: [
                  if (!isError)
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                      tooltip: 'Listen to Translation',
                      onPressed: () {
                        // Handle text-to-speech
                      },
                    ),
                  IconButton(
                    icon:
                        const Icon(Icons.content_copy, color: kLightTextColor),
                    tooltip: 'Copy Translation',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: _translatedText),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Translation copied to clipboard'),
                          duration: Duration(seconds: 1),
                          backgroundColor: kPrimaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isError ? Colors.red.withOpacity(0.1) : kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: isError
                  ? Border.all(color: Colors.red.withOpacity(0.3))
                  : null,
            ),
            child: Text(
              _translatedText,
              style: TextStyle(
                fontSize: 16,
                color: isError ? Colors.red : kTextColor,
              ),
            ),
          ),
          if (!isError)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: kLightTextColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Translation by Mixtral 8x7B AI model',
                      style: TextStyle(
                        fontSize: 12,
                        color: kLightTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Translation Service Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _initError ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kLightTextColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showApiKeyInputDialog();
              },
              child: const Text('Configure API Key'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _initializeDeepSeek,
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: kAccentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            language,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, color: kLightTextColor),
        ],
      ),
    );
  }
}
