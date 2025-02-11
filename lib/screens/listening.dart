// File: lib/screens/listening_screen.dart

import 'package:flutter/material.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  bool isPlaying = false;
  double progress = 0.0;
  String selectedOption = '';
  
  final List<String> options = [
    'Ndagukunda',
    'Mwaramutse',
    'Murakoze',
    'Amakuru'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening-Kinyarwanda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.language),
                      SizedBox(width: 8),
                      Text('English → Kinyarwanda'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Audio player card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Play button
                    IconButton(
                      iconSize: 48,
                      icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () {
                        setState(() {
                          isPlaying = !isPlaying;
                          // Here you would actually play/pause audio
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress bar
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                    ),
                    
                    const SizedBox(height: 8),
                    const Text('Listen and choose the correct meaning'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Options
            Column(
              children: options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedOption = option;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedOption == option ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedOption == option ? Colors.blue.shade50 : null,
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedOption == option ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),

            const Spacer(),

            // Check button
            ElevatedButton(
              onPressed: selectedOption.isNotEmpty ? () {
                // Show result
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedOption == 'Mwaramutse' 
                          ? 'Correct! "Mwaramutse" means "Good morning"' 
                          : 'Try again!'
                    ),
                    backgroundColor: selectedOption == 'Mwaramutse' 
                        ? Colors.green 
                        : Colors.red,
                  ),
                );
              } : null,
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
}