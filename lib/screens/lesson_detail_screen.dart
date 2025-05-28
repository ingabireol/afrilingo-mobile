import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_content_widget.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: LessonContentWidget(lesson: lesson),
    );
  }
} 