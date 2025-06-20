import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';

import 'package:afrilingo/features/exercise/screens/levelselection.dart';
import 'package:afrilingo/features/files/screens/files_page.dart';
import 'package:afrilingo/features/profile/screens/profile.dart';
import 'package:afrilingo/features/chat/screens/translating.dart';
import 'package:afrilingo/features/dashboard/screens/user_dashboard.dart';

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
        return const TranslationScreen();
      case 3:
        return const LevelSelectionScreen(courseId: 1);
      case 4:
        return const ProfilePage();
      default:
        return const UserDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onBottomNavTap(context, index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: themeProvider.primaryColor,
          unselectedItemColor: themeProvider.isDarkMode
              ? Colors.grey.shade600
              : Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Home', 0,
                themeProvider),
            _buildNavItem(
                Icons.folder_outlined, Icons.folder, 'File', 1, themeProvider),
            _buildNavItem(Icons.translate_outlined, Icons.translate,
                'Translate', 2, themeProvider),
            _buildNavItem(Icons.stars_outlined, Icons.stars, 'Challenges', 3,
                themeProvider),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4,
                themeProvider),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon,
      String label, int index, ThemeProvider themeProvider) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? themeProvider.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(selectedIndex == index ? activeIcon : icon),
      ),
      label: label,
    );
  }
}
