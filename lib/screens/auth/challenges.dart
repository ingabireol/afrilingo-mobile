import 'package:flutter/material.dart';

import '../../widgets/auth/navigation_bar.dart';

// **Placeholder Page for "Challenges"**
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Challenges Page - Coming Soon!'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }
}
