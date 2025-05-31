import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String _translatedText = 'Uraho, Amakuru yawe?';
  bool _isTranslating = false;
  
  @override
  void dispose() {
    _sourceTextController.dispose();
    super.dispose();
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
    if (_sourceTextController.text.isEmpty) return;
    
    setState(() {
      _isTranslating = true;
    });
    
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _translatedText = _sourceLanguage == 'English' 
          ? 'Uraho, Amakuru yawe?' 
          : 'Hi, how are you doing?';
      _isTranslating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Translate',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
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
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
                                icon: const Icon(Icons.mic, color: kPrimaryColor),
                                tooltip: 'Voice Input',
                                onPressed: () {
                                  // Handle voice input
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ListeningScreen()),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.content_copy, color: kLightTextColor),
                                tooltip: 'Copy Text',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _sourceTextController.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Text copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear, color: kLightTextColor),
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
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            _translate();
                          } else {
                            setState(() {
                              _translatedText = '';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Translation Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _translate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Translation Result
                if (_translatedText.isNotEmpty)
                  Container(
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
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                                  tooltip: 'Listen to Translation',
                                  onPressed: () {
                                    // Handle text-to-speech
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.content_copy, color: kLightTextColor),
                                  tooltip: 'Copy Translation',
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: _translatedText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Translation copied to clipboard'),
                                        duration: Duration(seconds: 1),
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
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _translatedText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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