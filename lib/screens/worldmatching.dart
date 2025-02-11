// word_matching_screen.dart
import 'package:flutter/material.dart';

class WordMatchingScreen extends StatelessWidget {
  const WordMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC78539), // Light brown
              Color(0xFF532708), // Dark brown
              Color(0xFF2D1505), // Even darker brown
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
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
                  'Put the following words with their correct meanings in Kinyarwanda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton('Hope', true),
                          _buildWordButton('Icyo', false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton('Dear', true),
                          _buildWordButton('Ibyiza', false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton('Life', true),
                          _buildWordButton('Teka', false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton('Continue', true),
                          _buildWordButton('Karaba', false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWordButton('Discipline', true),
                          _buildWordButton('Komera', false),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC78539),
                          minimumSize: const Size(200, 48),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordButton(String text, bool isLeft) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isLeft ? const Color(0xFF532708) : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}