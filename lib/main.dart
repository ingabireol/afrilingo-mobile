import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'screens/welcome_screen.dart';

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
      home: const  WelcomeScreen(),
    );
  }
}
