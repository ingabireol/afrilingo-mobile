import 'package:afrilingo/screens/listening.dart';
import 'package:afrilingo/screens/translating.dart';
import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  // Map to track which word is dropped on which image
  final Map<int, String> droppedWords = {};
  // List of available words
  final List<String> words = ['Imisozi', 'Izuba', 'Inka', 'Inzu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF8D6E63), // Brown
                Color(0xFFBCAAA4), // Light chocolate
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Words-Kinyarwanda',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Drag the name on the image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Number indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Image grid with drop targets - Optimized for visibility
            Expanded( // Changed to Expanded to use available space
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(8),
                children: [
                  _buildDropTarget(0, 'assets/hill.png'),    // Hills/Mountains
                  _buildDropTarget(1, 'assets/House.PNG'),   // House
                  _buildDropTarget(2, 'assets/Inka.PNG'),    // Cow
                  _buildDropTarget(3, 'assets/Sun.PNG'),     // Sun
                ],
              ),
            ),

            // Word buttons in a single row with pink backgrounds
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: words.map((word) => _buildDraggableWord(word)).toList(),
              ),
            ),

            // Check and Next buttons - BROWN
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        _checkAnswers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8D6E63), // Brown
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Check',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListeningScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBCAAA4), // Light chocolate
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildDropTarget(int index, String imagePath) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image - using BoxFit.contain to show full image
                Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),

                // Word label if dropped
                if (droppedWords.containsKey(index))
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: Text(
                        droppedWords[index]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14, // Slightly larger font
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      onAccept: (word) {
        setState(() {
          // Remove word from any previous location
          droppedWords.removeWhere((key, value) => value == word);
          // Add to new location
          droppedWords[index] = word;
        });
      },
    );
  }

  Widget _buildDraggableWord(String word) {
    // Check if the word is already dropped on an image
    bool isUsed = droppedWords.values.contains(word);

    return Draggable<String>(
      data: word,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.pink.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Text(
            word,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            word,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed ? Colors.grey.shade300 : Colors.pink.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          word,
          style: TextStyle(
            color: isUsed ? Colors.grey.shade600 : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _checkAnswers() {
    // Define correct answers (map image index to correct word)
    final Map<int, String> correctAnswers = {
      0: 'Imisozi',  // Hills/Mountains
      1: 'Inzu',     // House
      2: 'Inka',     // Cow
      3: 'Izuba',    // Sun
    };

    // Count correct answers
    int correctCount = 0;
    for (int i = 0; i < 4; i++) {
      if (droppedWords.containsKey(i) && droppedWords[i] == correctAnswers[i]) {
        correctCount++;
      }
    }

    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Result'),
        content: Text('You got $correctCount out of 4 correct!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset the lesson for new choices
              setState(() {
                droppedWords.clear();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}