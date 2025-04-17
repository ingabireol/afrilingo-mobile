import 'package:afrilingo/screens/wordmatching.dart';
import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F5F1), // Milk white background
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Text(
                              'Ishimwe Shakilla',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            RwandaFlagCircle(),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Color(0xFF8B4513),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC78539), // Light brown
                      const Color(0xFF8B4513), // Dark brown
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'Level 1 : Word translation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: CurvedLevelPath(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }
}

class RwandaFlagCircle extends StatelessWidget {
  const RwandaFlagCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipOval(
        child: CustomPaint(
          size: const Size(18, 18),
          painter: RwandaFlagPainter(),
        ),
      ),
    );
  }
}

class RwandaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Rwanda flag colors
    const blue = Color(0xFF00A1DE);
    const yellow = Color(0xFFE5BE01);
    const green = Color(0xFF1EB53A);

    // Create a circular flag
    final Paint paint = Paint();

    // Draw blue background for entire circle
    paint.color = blue;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Yellow stripe in the middle
    paint.color = yellow;
    final yellowRect = Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3);
    canvas.drawRect(yellowRect, paint);

    // Green stripe at the bottom
    paint.color = green;
    final greenRect = Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35);
    canvas.drawRect(greenRect, paint);

    // Draw boundary circle to clip the edges
    paint.color = Colors.transparent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedLevelPath extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(double.infinity, 500),
          painter: CurvedPathPainter(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: LevelCircle(
                  level: 1,
                  isActive: true,
                  icon: Icons.cases_rounded,
                  ),
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordMatchingScreen()),
                );
              },
            ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 80),
                LevelCircle(
                  level: 2,
                  isLocked: true,
                  icon: Icons.lock,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LevelCircle(
                  level: 3,
                  isLocked: true,
                  icon: Icons.description_outlined,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 80),
                LevelCircle(
                  level: 4,
                  isLocked: true,
                  icon: Icons.lock,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LevelCircle(
                  level: 5,
                  isLocked: true,
                  icon: Icons.lock,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 80),
                LevelCircle(
                  level: 6,
                  isLocked: true,
                  icon: Icons.lock,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class LevelCircle extends StatelessWidget {
  final int level;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final IconData icon;

  const LevelCircle({
    super.key,
    required this.level,
    this.isCompleted = false,
    this.isActive = false,
    this.isLocked = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.grey.shade400,
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: const Color(0xFFC78539), width: 4)
            : null,
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF8B4513) : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class CurvedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Starting point - center of the screen
    final centerX = size.width / 2;
    final spacing = size.height / 7;
    final curveOffset = 30.0;

    // Coordinates for the first level circle
    final level1X = centerX;
    final level1Y = spacing * 1.5;

    // Coordinates for the second level circle
    final level2X = centerX + 80;
    final level2Y = spacing * 2.5;

    // Coordinates for the third level circle
    final level3X = centerX;
    final level3Y = spacing * 3.5;

    // Coordinates for the fourth level circle
    final level4X = centerX + 80;
    final level4Y = spacing * 4.5;

    // Coordinates for the fifth level circle
    final level5X = centerX;
    final level5Y = spacing * 5.5;

    // Coordinates for the sixth level circle
    final level6X = centerX + 80;
    final level6Y = spacing * 6.5;

    // Draw a curved path connecting all level points
    path.moveTo(level1X, spacing);

    // Curve to level 1
    path.quadraticBezierTo(level1X, level1Y - curveOffset, level1X, level1Y);

    // Curve to level 2
    path.quadraticBezierTo(
        centerX + curveOffset, level1Y + (level2Y - level1Y) / 2,
        level2X, level2Y
    );

    // Curve to level 3
    path.quadraticBezierTo(
        level2X - curveOffset, level2Y + (level3Y - level2Y) / 2,
        level3X, level3Y
    );

    // Curve to level 4
    path.quadraticBezierTo(
        centerX + curveOffset, level3Y + (level4Y - level3Y) / 2,
        level4X, level4Y
    );

    // Curve to level 5
    path.quadraticBezierTo(
        level4X - curveOffset, level4Y + (level5Y - level4Y) / 2,
        level5X, level5Y
    );

    // Curve to level 6
    path.quadraticBezierTo(
        centerX + curveOffset, level5Y + (level6Y - level5Y) / 2,
        level6X, level6Y
    );

    canvas.drawPath(path, paint);

    // Draw dots along the curved path at more irregular intervals
    List<double> dotPositions = [0.15, 0.3, 0.45, 0.55, 0.7, 0.85];

    // Curve 1 - from top to level 1
    for (var position in dotPositions) {
      final t = position;
      final x = level1X;
      final y = spacing + (level1Y - spacing) * t;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 2 - from level 1 to level 2
    for (var position in dotPositions) {
      final t = position;
      final controlX = centerX + curveOffset;
      final controlY = level1Y + (level2Y - level1Y) / 2;

      final x = (1 - t) * (1 - t) * level1X + 2 * (1 - t) * t * controlX + t * t * level2X;
      final y = (1 - t) * (1 - t) * level1Y + 2 * (1 - t) * t * controlY + t * t * level2Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 3 - from level 2 to level 3
    for (var position in dotPositions) {
      final t = position;
      final controlX = level2X - curveOffset;
      final controlY = level2Y + (level3Y - level2Y) / 2;

      final x = (1 - t) * (1 - t) * level2X + 2 * (1 - t) * t * controlX + t * t * level3X;
      final y = (1 - t) * (1 - t) * level2Y + 2 * (1 - t) * t * controlY + t * t * level3Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 4 - from level 3 to level 4
    for (var position in dotPositions) {
      final t = position;
      final controlX = centerX + curveOffset;
      final controlY = level3Y + (level4Y - level3Y) / 2;

      final x = (1 - t) * (1 - t) * level3X + 2 * (1 - t) * t * controlX + t * t * level4X;
      final y = (1 - t) * (1 - t) * level3Y + 2 * (1 - t) * t * controlY + t * t * level4Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 5 - from level 4 to level 5
    for (var position in dotPositions) {
      final t = position;
      final controlX = level4X - curveOffset;
      final controlY = level4Y + (level5Y - level4Y) / 2;

      final x = (1 - t) * (1 - t) * level4X + 2 * (1 - t) * t * controlX + t * t * level5X;
      final y = (1 - t) * (1 - t) * level4Y + 2 * (1 - t) * t * controlY + t * t * level5Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}