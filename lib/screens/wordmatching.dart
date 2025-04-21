import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

import 'completion.dart';

class WordMatchingScreen extends StatefulWidget {
  const WordMatchingScreen({super.key});

  @override
  State<WordMatchingScreen> createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen> {
  final List<String> englishWords = ['Name', 'Door', 'Bulb', 'Curtains', 'Decorations'];
  final List<String> kinyarwandaWords = ['Izina', 'Urugi', 'Itara', 'Imitako', 'Amarido'];

  String? selectedEnglish;
  String? selectedKinyarwanda;

  final Map<String, String> correctMatches = {
    'Name': 'Izina',
    'Door': 'Urugi',
    'Bulb': 'Itara',
    'Curtains': 'Amarido',
    'Decorations': 'Imitako',
  };

  final Map<String, String> matchedPairs = {};
  final Map<String, bool> matchResults = {};

  void _checkMatch() {
    if (selectedEnglish != null && selectedKinyarwanda != null) {
      bool isMatch = correctMatches[selectedEnglish!] == selectedKinyarwanda;
      setState(() {
        matchedPairs[selectedEnglish!] = selectedKinyarwanda!;
        matchResults[selectedEnglish!] = isMatch;
        selectedEnglish = null;
        selectedKinyarwanda = null;
      });
    }
  }

  void _resetGame() {
    setState(() {
      matchedPairs.clear();
      matchResults.clear();
      selectedEnglish = null;
      selectedKinyarwanda = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC78539),
                    Color(0xFF532708),
                    Color(0xFF2D1505),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red[400], size: 20),
                      Icon(Icons.favorite, color: Colors.red[400], size: 20),
                      Icon(Icons.favorite, color: Colors.red[400], size: 20),
                      Icon(Icons.favorite_border, color: Colors.white, size: 20),
                      Icon(Icons.favorite_border, color: Colors.white, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pair the following words with their correct meanings in Kinyarwanda',
                style: TextStyle(
                  color: Color(0xFF532708),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: englishWords.length,
                  itemBuilder: (context, index) {
                    String english = englishWords[index];
                    String kinyarwanda = kinyarwandaWords[index];

                    bool isMatched = matchedPairs.containsKey(english);
                    bool isCorrect = matchResults[english] == true;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton(english, true,
                              selected: selectedEnglish == english,
                              matched: isMatched,
                              correct: isCorrect),
                          _buildWordButton(kinyarwanda, false,
                              selected: selectedKinyarwanda == kinyarwanda,
                              matched: isMatched && matchedPairs[english] == kinyarwanda,
                              correct: isCorrect),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CompletionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF532708),
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }

  Widget _buildWordButton(String text, bool isLeft,
      {bool selected = false, bool matched = false, bool correct = false}) {
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;

    if (matched) {
      bgColor = correct ? const Color(0xFFEAD2B3) : Colors.redAccent;
      textColor = correct ? const Color(0xFF532708) : Colors.white;
    } else if (selected) {
      bgColor = const Color(0xFFEAD2B3);
      textColor = const Color(0xFF532708);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isLeft) {
            selectedEnglish = text;
          } else {
            selectedKinyarwanda = text;
          }

          if (selectedEnglish != null && selectedKinyarwanda != null) {
            _checkMatch();
          }
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
            BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(2, 2))
          ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}