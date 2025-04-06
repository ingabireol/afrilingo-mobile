import 'package:flutter/material.dart';

import '../../widgets/auth/navigation_bar.dart';

/// **Placeholder Page for "Translation"**
class TranslationPage extends StatelessWidget {
  const TranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Translation Page - Coming Soon!'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
