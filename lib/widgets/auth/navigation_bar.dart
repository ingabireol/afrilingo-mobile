import 'package:flutter/material.dart';

import '../../screens/auth/challenges.dart';
import '../../screens/auth/files_page.dart';
import '../../screens/auth/profile.dart';
import '../../screens/auth/translate.dart';
import '../../screens/auth/user_dashboard.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavigationBar({super.key, required this.selectedIndex});

  void _onBottomNavTap(BuildContext context, int index) {
    Widget nextPage = getPageForIndex(index);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  Widget getPageForIndex(int index) {
    switch (index) {
      case 0:
        return const UserDashboard();
      case 1:
        return const FilesPage();
      case 2:
        return const TranslationPage();
      case 3:
        return const ChallengesPage();
      case 4:
        return const ProfilePage();
      default:
        return const UserDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onBottomNavTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          label: 'File',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.translate_outlined),
          label: 'Translate',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stars_outlined),
          label: 'Challenges',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      selectedItemColor: const Color(0xFF8B4513),
      unselectedItemColor: const Color(0xFFDEB887),
    );
  }
}
