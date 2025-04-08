import 'package:afrilingo/screens/quizpage3.dart';
import 'package:afrilingo/screens/Quiz.dart';
import 'package:afrilingo/screens/completion.dart';
import 'package:afrilingo/screens/congratspage.dart';
import 'package:afrilingo/screens/levelselection.dart';
import 'package:afrilingo/screens/listening.dart';
import 'package:afrilingo/screens/quizpage1.dart';
import 'package:afrilingo/screens/profile.dart';
import 'package:afrilingo/screens/speaking.dart';
import 'package:afrilingo/screens/quizpage2.dart';
import 'package:afrilingo/screens/translating.dart';
import 'package:afrilingo/screens/words.dart';
import 'package:afrilingo/screens/wordmatching.dart';
import 'package:afrilingo/screens/writing.dart';
import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

import 'screens/goal.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinyarwanda Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // Brown color as primary
          primary: const Color(0xFF8B4513),
          secondary: const Color(0xFFDEB887),
        ),
        useMaterial3: true,
        fontFamily: 'DM Serif Display', // Set as default font family
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8B4513),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'DM Serif Display', // Apply to body text as well
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
      home: const SpeakingScreen(),
    );
  }
}
