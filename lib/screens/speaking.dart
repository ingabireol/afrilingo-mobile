// File: lib/screens/speaking_screen.dart

import 'package:flutter/material.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  bool isRecording = false;
  bool hasRecorded = false;
  String currentPhrase = 'How are you?';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking-Kinyarwanda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Phrase card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Say this phrase in Kinyarwanda',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentPhrase,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Listen to correct pronunciation
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Listen to correct pronunciation'),
                      onPressed: () {
                        // Here you would play the audio
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Recording section
            Column(
              children: [
                // Recording status
                Text(
                  isRecording ? 'Recording...' : 'Press and hold to record',
                  style: TextStyle(
                    color: isRecording ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Record button
                GestureDetector(
                  onTapDown: (_) => setState(() => isRecording = true),
                  onTapUp: (_) => setState(() {
                    isRecording = false;
                    hasRecorded = true;
                  }),
                  onTapCancel: () => setState(() => isRecording = false),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.red : Colors.blue,
                    ),
                    child: Icon(
                      isRecording ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Playback and submit
                if (hasRecorded) ...[
                  // Play recorded audio
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play your recording'),
                    onPressed: () {
                      // Here you would play the recorded audio
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Submit button
                  ElevatedButton(
                    onPressed: () {
                      // Here you would submit the recording for review
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recording submitted for review!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}