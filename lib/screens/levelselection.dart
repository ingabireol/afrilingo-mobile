// level_selection_screen.dart
import 'package:flutter/material.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

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
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/profile_pic.png'),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC78539).withOpacity(0.3),
                      const Color(0xFF532708).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'Level 1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: PathPainter(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 1; i <= 6; i++)
                        LevelCircle(
                          level: i,
                          isCompleted: i < 4,
                          isActive: i == 4,
                        ),
                    ],
                  ),
                ),
              ),
              const BottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelCircle extends StatelessWidget {
  final int level;
  final bool isCompleted;
  final bool isActive;

  const LevelCircle({
    super.key,
    required this.level,
    this.isCompleted = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFC78539)
            : isActive
                ? Colors.white
                : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: const Color(0xFFC78539), width: 2) : null,
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: TextStyle(
            color: isActive ? const Color(0xFF532708) : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_outlined, color: Colors.white.withOpacity(0.7)),
          Icon(Icons.grid_view_outlined, color: Colors.white.withOpacity(0.7)),
          Icon(Icons.emoji_events_outlined, color: Colors.white.withOpacity(0.7)),
          Icon(Icons.person_outline, color: Colors.white.withOpacity(0.7)),
        ],
      ),
    );
  }
}