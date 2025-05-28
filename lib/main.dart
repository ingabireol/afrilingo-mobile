import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';

// Define app-wide colors
class AppColors {
  static const lightBrown = Color(0xFFC78539);
  static const darkBrown = Color(0xFF8B4513);
  static const milkWhite = Color(0xFFF9F5F1);
}

// Define app-wide gradients
class AppGradients {
  static const brownGradient = LinearGradient(
    colors: [
      AppColors.lightBrown,
      AppColors.darkBrown,
    ],
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Failed to load .env file: $e');
  }
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
          seedColor: AppColors.darkBrown,
          primary: AppColors.darkBrown,
          secondary: AppColors.lightBrown,
          background: AppColors.milkWhite,
        ),
        useMaterial3: true,
        fontFamily: 'DM Serif Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.darkBrown,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.darkBrown),
          titleTextStyle: TextStyle(
            color: AppColors.darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DM Serif Display',
          ),
        ),
        scaffoldBackgroundColor: AppColors.milkWhite,
      ),
      home: const WelcomeScreen(),
    );
  }
}
