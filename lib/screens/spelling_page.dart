import 'package:flutter/material.dart';

// Create a custom painter for the Rwanda flag
class RwandaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Colors from the Rwanda flag
    final blue = Color(0xFF00A1DE);    // Light blue
    final yellow = Color(0xFFFFD200);  // Yellow
    final green = Color(0xFF1EB53A);   // Green

    // Create paint objects
    final bluePaint = Paint()..color = blue;
    final yellowPaint = Paint()..color = yellow;
    final greenPaint = Paint()..color = green;

    // Calculate dimensions for three horizontal stripes
    final stripeHeight = size.height / 3;

    // Draw blue stripe (top)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, stripeHeight),
      bluePaint,
    );

    // Draw yellow stripe (middle)
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight),
      yellowPaint,
    );

    // Draw green stripe (bottom)
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight),
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpellingPage extends StatelessWidget {
  const SpellingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      // Replace the CircleAvatar with the Rwanda flag
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CustomPaint(
                              painter: RwandaFlagPainter(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kinyarwanda',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Find the right letters for this image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // Fix the strawberry image issue with error handling
                      child: Image.asset(
                        'assets/strawberry.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  "Unable to load strawberry.png",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Input field
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'I',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const Text(
                            '_',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const Text(
                            '_',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const Text(
                            '_',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const Text(
                            '_',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Keyboard
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: 'ABCDEFGHIJKLMNROPQZ'.split('').map((letter) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC49A6C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.home_outlined, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bar_chart_outlined, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.star_outline, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, color: Colors.grey),
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