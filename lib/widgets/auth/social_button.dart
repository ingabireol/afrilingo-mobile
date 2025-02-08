import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final dynamic icon; // Can be IconData or String (image path)
  final String text;
  final String socialName;
  final bool showBorder;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.socialName,
    this.showBorder = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: showBorder
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[700],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLeadingWidget(),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                socialName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (icon is IconData) {
      return Icon(
        icon,
        color: Colors.grey[700],
        size: 24,
      );
    } else if (icon is String) {
      return Image.asset(
        icon,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return const Icon(
            Icons.error,
            color: Colors.red,
            size: 24,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
