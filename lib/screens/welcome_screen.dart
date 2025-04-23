import 'package:flutter/material.dart';

import '../screens/auth/sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.06,
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
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
                    color: const Color(0xFFFFD79D),
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 30),
            Text(
              'Connecting You to Africa, One Word at a Time',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFamily: 'DM Serif Display',
                    color: const Color(0xFFE4DDDD).withOpacity(0.9),
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
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
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.11,
                    height: MediaQuery.of(context).size.width * 0.11,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC78539), // Orange-gold button color
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    ));
  }
}
