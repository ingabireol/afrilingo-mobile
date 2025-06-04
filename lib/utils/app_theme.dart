import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afrilingo/services/theme_provider.dart';

/// Utility class to provide consistent theme-based styling across the app
class AppTheme {
  // App bar theme with automatic status bar style based on theme mode
  static AppBar appBarWithTheme(
    ThemeProvider themeProvider, {
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    double elevation = 0,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: elevation,
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(color: themeProvider.textColor),
      systemOverlayStyle: themeProvider.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  // Consistent card decoration
  static BoxDecoration cardDecoration(ThemeProvider themeProvider) {
    return BoxDecoration(
      color: themeProvider.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Button styles for primary actions
  static ButtonStyle primaryButtonStyle(ThemeProvider themeProvider) {
    return ElevatedButton.styleFrom(
      backgroundColor: themeProvider.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );
  }

  // Secondary button style
  static ButtonStyle secondaryButtonStyle(ThemeProvider themeProvider) {
    return ElevatedButton.styleFrom(
      backgroundColor: themeProvider.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      foregroundColor: themeProvider.textColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeProvider.isDarkMode
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
      ),
      elevation: 0,
    );
  }

  // Text button style
  static ButtonStyle textButtonStyle(ThemeProvider themeProvider) {
    return TextButton.styleFrom(
      foregroundColor: themeProvider.accentColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Text field decoration
  static InputDecoration textFieldDecoration(
    ThemeProvider themeProvider, {
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: themeProvider.isDarkMode
          ? Colors.black.withOpacity(0.2)
          : Colors.grey.shade50,
      hintText: hintText,
      hintStyle: TextStyle(color: themeProvider.lightTextColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeProvider.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeProvider.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  // Dialog decoration
  static ShapeBorder dialogShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
  }

  // Transition animations for page navigation
  static PageRouteBuilder pageTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
