import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

import 'listening.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translating-Kinyarwanda'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8D6E63), // Brown
                Color(0xFFBCAAA4), // Milk chocolate (reduced yellow intensity)
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFFAF9F6), // Milk white background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Language Selection - without white container
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageDropdown('English'),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    color: Color(0xFF5D4037), // Dark brown
                    onPressed: () {},
                  ),
                  _buildLanguageDropdown('Kinyarwanda'),
                ],
              ),

              const SizedBox(height: 24),

              // English Text with Audio Icon (mic)
              _buildTranslationCard(
                'Hi, how are you doing?',
                isSource: true,
                icon: Icons.mic, // Audio icon for English
              ),
              const SizedBox(height: 16),

              // Kinyarwanda Translation with Sound Icon
              _buildTranslationCard(
                'Uraho, Amakuru yawe?',
                isSource: false,
                icon: Icons.volume_up, // Sound icon for Kinyarwanda
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget _buildLanguageDropdown(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent, // No white background
        border: Border.all(color: Color(0xFFBCAAA4)), // Light chocolate border
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language,
            style: TextStyle(
              color: Color(0xFF5D4037), // Dark brown text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, color: Color(0xFF5D4037)), // Dark brown icon
        ],
      ),
    );
  }

  Widget _buildTranslationCard(String text, {required bool isSource, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D4037), // Dark brown text
                ),
              ),
            ),
            IconButton(
              icon: Icon(icon, color: Color(0xFF8D6E63)), // Brown icon
              onPressed: () {
                // Add audio/sound functionality here
              },
            ),
          ],
        ),
      ),
    );
  }
}