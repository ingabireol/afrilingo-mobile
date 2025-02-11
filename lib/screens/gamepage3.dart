import 'package:flutter/material.dart';

class TranslationExerciseScreen extends StatelessWidget {
  const TranslationExerciseScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: Colors.white),
                  title: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/rwanda_flag.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kinyarwanda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Translate in Kinyarwanda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tomato',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Icon(
                        Icons.mic_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.close, 
                              color: Colors.red.withOpacity(0.8), 
                              size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'cancel',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF532708),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF532708),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward, 
                            size: 20, 
                            color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.home_outlined, 
                        color: Colors.white.withOpacity(0.7)),
                    Icon(Icons.grid_view_outlined, 
                        color: Colors.white.withOpacity(0.7)),
                    Icon(Icons.emoji_events_outlined, 
                        color: Colors.white.withOpacity(0.7)),
                    Icon(Icons.person_outline, 
                        color: Colors.white.withOpacity(0.7)),
                    Icon(Icons.settings_outlined, 
                        color: Colors.white.withOpacity(0.7)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}