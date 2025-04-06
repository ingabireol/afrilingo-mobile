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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC78539), // Light brown (top)
              Color(0xFF532708), // Dark brown (middle)
              Color(0xFF2D1505), // Even darker brown (bottom)
            ],
          ),
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
                  image:
                      AssetImage('lib/images/Screenshot 2025-02-03 192844.png'),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(250),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Afrilingo',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFamily: 'DM Serif Display',
                    color: Color(0xFFFFD79D),
                    fontSize: 55,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 30),
            Text(
              'Connecting You to Africa, One Word at a Time',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFamily: 'DM Serif Display',
                    color: Color(0xFFE4DDDD).withOpacity(0.9),
                    fontSize: 47,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 100),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 40,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC78539), // Orange-gold button color
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
