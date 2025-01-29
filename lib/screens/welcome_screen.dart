import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          top: 51,
          left: 17,
          right: 17,
          bottom: 52,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.24, -0.97),
            end: Alignment(0.24, 0.97),
            colors: [Color(0xFFC78539), Color(0xFF532708), Color(0xB2532708)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 297,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/280x297"),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Afrilingo',
              style: TextStyle(
                color: Color(0xFFFFD79D),
                fontSize: 55,
                fontFamily: 'DM Serif Display',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Connecting You to Africa, One Word at a Time',
              style: TextStyle(
                color: Color(0xFFE4DDDD),
                fontSize: 47,
                fontFamily: 'DM Serif Display',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: Container(
                width: 396,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.50,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Color(0xFFF3F1EE),
                          fontSize: 30,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    const Icon(
                      Icons.arrow_forward,
                      size: 35,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
