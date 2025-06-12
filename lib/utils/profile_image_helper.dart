import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

/// Helper utility for handling profile images consistently throughout the app
class ProfileImageHelper {
  /// Convert any profile image URL to a usable format
  /// Handles SVG to PNG conversion, fixes malformed URLs, and supports base64 images
  static String? getValidProfileImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    try {
      // Handle UI Avatars API URLs - they're already valid, just return them
      if (url.contains("ui-avatars.com")) {
        return url;
      }

      // Handle base64 encoded images
      if (url.startsWith('data:image')) {
        return url; // Already properly formatted
      }

      // Check if it might be a base64 image without proper prefix
      if (url.length > 100 && !url.contains('://') && !url.contains('/')) {
        try {
          // Try to decode to validate if it's base64
          base64Decode(url);
          return 'data:image/jpeg;base64,$url';
        } catch (e) {
          // Not valid base64, continue with URL processing
        }
      }

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

  /// Creates an ImageProvider for the profile image, handling both network and memory images
  static ImageProvider? getProfileImageProvider(String? url) {
    final validUrl = getValidProfileImageUrl(url);
    if (validUrl == null) return null;

    // Handle base64 images
    if (validUrl.startsWith('data:image')) {
      try {
        // Extract the base64 part
        final base64String = validUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return null;
      }
    }

    // Otherwise use network image
    return NetworkImage(validUrl);
  }

  /// Build a consistent CircleAvatar for profile images throughout the app
  static Widget buildProfileAvatar({
    required String? imageUrl,
    double radius = 30,
    Color backgroundColor = Colors.white24,
    Color iconColor = Colors.white,
    bool showLoading = false,
  }) {
    if (showLoading) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: iconColor,
        ),
      );
    }

    // Special handling for UI Avatars URLs - they work reliably
    if (imageUrl != null && imageUrl.contains("ui-avatars.com")) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    final validImageUrl = getValidProfileImageUrl(imageUrl);

    // If image URL is valid, use CachedNetworkImage for better reliability
    if (validImageUrl != null) {
      if (validImageUrl.startsWith('data:image')) {
        try {
          // Extract the base64 part
          final base64String = validImageUrl.split(',')[1];
          final bytes = base64Decode(base64String);

          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (e) {
          print('Error rendering base64 profile image: $e');
          // Fall through to default avatar
        }
      } else {
        // Use CachedNetworkImage for network images
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: validImageUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.person,
                size: radius,
                color: iconColor.withOpacity(0.9),
              ),
            ),
          ),
        );
      }
    }

    // Fallback for no image
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Icon(
        Icons.person,
        size: radius,
        color: iconColor.withOpacity(0.9),
      ),
    );
  }
}
