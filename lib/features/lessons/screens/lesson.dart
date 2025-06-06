import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/courses/models/course.dart';
import 'package:afrilingo/features/lessons/models/lesson.dart';
import 'package:afrilingo/features/lessons/services/lesson_service.dart';
import 'package:afrilingo/core/widgets/lesson_content_widget.dart';
import 'package:afrilingo/features/quiz/screens/QuizScreen.dart';

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
  // Track if current lesson is already completed
  bool _currentLessonCompleted = false;

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
      _currentLessonCompleted = false;
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

  // Mark the current lesson as completed
  Future<void> _markLessonCompleted() async {
    if (_currentLessonCompleted) return;

    try {
      await _lessonService.markLessonCompleted(
        widget.lessons[_currentLessonIndex].id,
      );
      _currentLessonCompleted = true;
    } catch (e) {
      print('Error marking lesson as completed: $e');
    }
  }

  void _nextLesson() async {
    // Mark current lesson as completed when moving to the next
    await _markLessonCompleted();

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

  void _startQuiz() async {
    // Mark lesson as completed before starting the quiz
    await _markLessonCompleted();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lessonId: widget.lessons[_currentLessonIndex].id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = widget.lessons[_currentLessonIndex];
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(currentLesson.title),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: themeProvider.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCurrentLessonContent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Lesson content - using the LessonContentWidget
                    Expanded(
                      child: LessonContentWidget(
                        lesson: currentLesson,
                        onContentCompleted: () {
                          // This callback gets triggered when user has viewed all content
                          _markLessonCompleted();
                        },
                      ),
                    ),

                    // Navigation buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                themeProvider.isDarkMode ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _currentLessonIndex > 0
                                ? _previousLesson
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.cardColor,
                              foregroundColor: themeProvider.primaryColor,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _currentLessonIndex > 0
                                      ? themeProvider.primaryColor
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                            child: const Text('Previous'),
                          ),
                          ElevatedButton(
                            onPressed: _startQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Take Quiz'),
                          ),
                          ElevatedButton(
                            onPressed:
                                _currentLessonIndex < widget.lessons.length - 1
                                    ? _nextLesson
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.cardColor,
                              foregroundColor: themeProvider.primaryColor,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _currentLessonIndex <
                                          widget.lessons.length - 1
                                      ? themeProvider.primaryColor
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
