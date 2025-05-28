import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import 'Quiz.dart';

class LessonScreen extends StatefulWidget {
  final Course course;
  final List<Lesson> lessons;

  const LessonScreen({
    super.key,
    required this.course,
    required this.lessons,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LessonService _lessonService = LessonService();
  int _currentLessonIndex = 0;
  List<LessonContent>? _currentLessonContent;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentLessonContent();
  }

  Future<void> _loadCurrentLessonContent() async {
    if (_currentLessonIndex >= widget.lessons.length) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _lessonService.getLessonContent(
        widget.lessons[_currentLessonIndex].id,
      );
      setState(() {
        _currentLessonContent = [content];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextLesson() {
    if (_currentLessonIndex < widget.lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      _loadCurrentLessonContent();
    }
  }

  void _previousLesson() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
      });
      _loadCurrentLessonContent();
    }
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizStartScreen(
          lessonId: widget.lessons[_currentLessonIndex].id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = widget.lessons[_currentLessonIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLesson.title),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCurrentLessonContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Lesson content
                      if (_currentLessonContent != null)
                        ..._currentLessonContent!.map((content) {
                          switch (content.contentType) {
                            case 'TEXT':
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  content.contentData,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            case 'AUDIO':
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(content.contentData),
                                    if (content.mediaUrl != null)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement audio playback
                                        },
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('Play Audio'),
                                      ),
                                  ],
                                ),
                              );
                            case 'IMAGE':
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(content.contentData),
                                    if (content.mediaUrl != null)
                                      Image.network(
                                        content.mediaUrl!,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        }).toList(),

                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _currentLessonIndex > 0
                                  ? _previousLesson
                                  : null,
                              child: const Text('Previous'),
                            ),
                            ElevatedButton(
                              onPressed: _startQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B4513),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Take Quiz'),
                            ),
                            ElevatedButton(
                              onPressed: _currentLessonIndex < widget.lessons.length - 1
                                  ? _nextLesson
                                  : null,
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
} 