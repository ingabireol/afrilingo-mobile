import 'package:flutter/material.dart';

/// Helper utility for handling profile images consistently throughout the app
class ProfileImageHelper {
  /// Convert any profile image URL to a usable format
  /// Handles SVG to PNG conversion and fixes malformed URLs
  static String? getValidProfileImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    try {
      // Replace SVG with PNG for DiceBear URLs to prevent rendering issues
      if (url.contains("dicebear") && url.contains(".svg")) {
        return url.replaceAll(".svg", ".png");
      }

      // Check if it's a valid URL with a scheme
      final uri = Uri.parse(url);
      if (!uri.hasScheme) {
        // Add https scheme if missing
        return 'https://${url.startsWith('//') ? url.substring(2) : url}';
      }

      return url;
    } catch (e) {
      print('Invalid profile image URL: $url - $e');
      return null;
    }
  }

  /// Creates a NetworkImage provider if URL is valid, otherwise returns null
  static ImageProvider? getProfileImageProvider(String? url) {
    final validUrl = getValidProfileImageUrl(url);
    if (validUrl != null) {
      return NetworkImage(validUrl);
    }
    return null;
  }

  /// Build a consistent CircleAvatar for profile images throughout the app
  static Widget buildProfileAvatar({
    required String? imageUrl,
    double radius = 30,
    Color backgroundColor = Colors.white24,
    Color iconColor = Colors.white,
    bool showLoading = false,
  }) {
    final validUrl = getValidProfileImageUrl(imageUrl);

    // If we have a valid URL, use NetworkImage with error handling
    if (validUrl != null && !showLoading) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(validUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
      );
    }

    // Fallback for no image URL or loading state
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: showLoading
          ? CircularProgressIndicator(
              strokeWidth: 2,
              color: iconColor,
            )
          : Icon(
              Icons.person,
              size: radius,
              color: iconColor.withOpacity(0.9),
            ),
    );
  }
}
