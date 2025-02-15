import 'package:afrilingo/screens/auth/notifications.dart';
import 'package:afrilingo/screens/auth/progress.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../widgets/auth/navigation_bar.dart';
import 'activity.dart';
import 'courses.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildMenuGrid(context), // Pass context to the method
                const SizedBox(height: 16),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildStatsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Shaks!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'What would you like to look into today',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildMenuGrid(BuildContext context) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.1,
    children: [
      _buildMenuCard(context, Icons.menu_book, 'courses'),
      _buildMenuCard(context, Icons.play_circle_fill, 'progress'),
      _buildMenuCard(context, Icons.edit, 'Test'),
      _buildMenuCard(context, Icons.timer, 'Activity'),
    ],
  );
}

Widget _buildMenuCard(BuildContext context, IconData icon, String title) {
  return GestureDetector(
    onTap: () =>
        // Navigate to a different screen when the menu card is tapped
        Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _getDestinationScreen(title)),
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

// Method to return different screens based on the title
Widget _getDestinationScreen(String title) {
  switch (title) {
    case 'courses':
      return const CoursesScreen();
    case 'progress':
      return const ProgressScreen();
    case 'Test':
      return const TestScreen();
    case 'Activity':
      return const ActivityScreen();
    default:
      return const Center(child: Text('Unknown Screen'));
  }
}

Widget _buildProgressBar() {
  double progress = 0.3;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF5A77FF), Color(0xFFBE5AC8)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Wow, you're improving!",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        CircularPercentIndicator(
          radius: 25,
          lineWidth: 6,
          percent: progress,
          center: Text(
            "${(progress * 100).round()}%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white12,
          progressColor: Colors.white,
        )
      ],
    ),
  );
}

Widget _buildStatsSection() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 5,
        ),
      ],
    ),
    child: Column(
      children: [
        _buildStatItem('Lessons learned', '12'),
        _buildStatItem("Today's learning time", '1.5h'),
        _buildStatItem('Lessons left to learn', '36'),
      ],
    ),
  );
}

Widget _buildStatItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// Dummy screens for navigation
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Courses();
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProgressPage();
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: const Center(child: Text('Test Screen')),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActivityPage();
  }
}
