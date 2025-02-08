
import 'package:flutter/material.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translating-Kinyarwanda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageDropdown('English'),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {},
                ),
                _buildLanguageDropdown('Kinyarwanda'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Translation Cards
            _buildTranslationCard(
              'Hi, how are you doing?',
              isSource: true,
            ),
            const SizedBox(height: 16),
            _buildTranslationCard(
              'Uraho, Amakuru yawe?',
              isSource: false,
            ),
            
            const Spacer(),
            
            // Done Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(language),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(String text, {required bool isSource}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}