import 'package:flutter/material.dart';
import '../models/lesson.dart';

class LessonContentView extends StatelessWidget {
  final LessonContent content;
  final bool isExpanded;

  const LessonContentView({
    Key? key,
    required this.content,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: _buildStructuredContent(context),
    );
  }

  Widget _buildStructuredContent(BuildContext context) {
    // Split content into lines
    final lines = content.contentData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    List<Widget> widgets = [];
    String? currentSection;

    for (final line in lines) {
      final headerMatch = RegExp(r'^(#+) (.*)').firstMatch(line);
      if (headerMatch != null) {
        // It's a header
        final level = headerMatch.group(1)!.length;
        final text = headerMatch.group(2)!;
        currentSection = text;
        widgets.add(Padding(
          padding: EdgeInsets.only(top: level == 1 ? 16 : 12, bottom: 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: level == 1 ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ));
      } else if (line.trim().startsWith('*')) {
        // It's a bullet point, remove markdown and asterisks
        final cleanLine = line.replaceAll(RegExp(r'^\*+\s*|\*+'), '').trim();
        widgets.add(Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          child: ListTile(
            leading: Icon(Icons.arrow_right, color: Colors.blue[400]),
            title: Text(
              cleanLine,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ));
      } else {
        // Plain text
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line.trim(),
            style: const TextStyle(fontSize: 16),
          ),
        ));
      }
    }

    // Optionally add media
    if (content.mediaUrl != null) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(_buildMediaContent());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildMediaContent() {
    if (content.mediaUrl == null) return const SizedBox.shrink();
    if (content.mediaUrl!.toLowerCase().endsWith('.jpg') ||
        content.mediaUrl!.toLowerCase().endsWith('.jpeg') ||
        content.mediaUrl!.toLowerCase().endsWith('.png')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          content.mediaUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('Failed to load image'),
            );
          },
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Media content available'),
      ),
    );
  }
} 