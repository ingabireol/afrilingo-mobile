import 'package:flutter/material.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  String? selectedWord;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Words-Kinyarwanda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildImageCard('assets/images/house.png'),
                _buildImageCard('assets/images/sun.png'),
                _buildImageCard('assets/images/cow.png'),
                _buildImageCard('assets/images/dog.png'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Word Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildWordButton('Intozo'),
                _buildWordButton('Izuba'),
                _buildWordButton('Inka'),
                _buildWordButton('Inzu'),
              ],
            ),
            
            const Spacer(),
            
            // Check Button
            ElevatedButton(
              onPressed: () {
                // Show result
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checking answer...')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Check'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWordButton(String word) {
    final isSelected = selectedWord == word;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedWord = word;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(word),
    );
  }
}