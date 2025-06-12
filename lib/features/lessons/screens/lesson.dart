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
  // Track if quiz has been completed for the current lesson
  bool _quizCompleted = false;
  // Track content completion
  bool _contentViewed = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLessonContent();
    _checkLessonCompletion();
    _checkQuizCompletion();
  }

  Future<void> _loadCurrentLessonContent() async {
    if (_currentLessonIndex >= widget.lessons.length) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _contentViewed = false;
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

  // Check if the current lesson has been completed
  Future<void> _checkLessonCompletion() async {
    try {
      final completed = await _lessonService.isLessonCompleted(
        widget.lessons[_currentLessonIndex].id,
      );
      setState(() {
        _currentLessonCompleted = completed;
      });
    } catch (e) {
      print('Error checking lesson completion: $e');
    }
  }

  // Check if the quiz for the current lesson has been completed
  Future<void> _checkQuizCompletion() async {
    try {
      final completed = await _lessonService.isQuizCompleted(
        widget.lessons[_currentLessonIndex].id,
      );
      setState(() {
        _quizCompleted = completed;
      });
    } catch (e) {
      print('Error checking quiz completion: $e');
    }
  }

  // Mark the current lesson as completed
  Future<void> _markLessonCompleted() async {
    if (_currentLessonCompleted) return;

    try {
      await _lessonService.markLessonCompleted(
        widget.lessons[_currentLessonIndex].id,
      );
      setState(() {
        _currentLessonCompleted = true;
      });
    } catch (e) {
      print('Error marking lesson as completed: $e');
    }
  }

  void _nextLesson() async {
    // Only proceed if current lesson and quiz are completed
    if (!_currentLessonCompleted || !_quizCompleted) {
      _showCompletionRequiredDialog();
      return;
    }

    if (_currentLessonIndex < widget.lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _contentViewed = false;
        _currentLessonCompleted = false;
        _quizCompleted = false;
      });
      _loadCurrentLessonContent();
      _checkLessonCompletion();
      _checkQuizCompletion();
    }
  }

  void _previousLesson() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
        _contentViewed = false;
      });
      _loadCurrentLessonContent();
      _checkLessonCompletion();
      _checkQuizCompletion();
    }
  }

  void _startQuiz() async {
    // Mark lesson as completed before starting the quiz
    await _markLessonCompleted();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lessonId: widget.lessons[_currentLessonIndex].id,
        ),
      ),
    );

    // Check if quiz was completed after returning from quiz screen
    if (result == true) {
      setState(() {
        _quizCompleted = true;
      });
    } else {
      _checkQuizCompletion();
    }
  }

  void _showCompletionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          title: Text(
            'Completion Required',
            style: TextStyle(
              color: themeProvider.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_contentViewed)
                const Text(
                  'Please view all the lesson content.',
                  style: TextStyle(fontSize: 16),
                ),
              if (!_currentLessonCompleted)
                const Text(
                  'Please complete the current lesson.',
                  style: TextStyle(fontSize: 16),
                ),
              if (!_quizCompleted)
                const Text(
                  'Please complete the quiz for this lesson.',
                  style: TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              const Text(
                'You need to complete both the lesson and its quiz before moving to the next lesson.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.primaryColor,
              ),
              child: const Text('OK'),
            ),
            if (!_quizCompleted && _currentLessonCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startQuiz();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Take Quiz'),
              ),
          ],
        );
      },
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
                          setState(() {
                            _contentViewed = true;
                          });
                          _markLessonCompleted();
                        },
                      ),
                    ),

                    // Status indicators
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      color: themeProvider.cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusIndicator(
                              "Content", _contentViewed, themeProvider),
                          const SizedBox(width: 24),
                          _buildStatusIndicator(
                              "Lesson", _currentLessonCompleted, themeProvider),
                          const SizedBox(width: 24),
                          _buildStatusIndicator(
                              "Quiz", _quizCompleted, themeProvider),
                        ],
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
                            onPressed: _currentLessonIndex <
                                        widget.lessons.length - 1 &&
                                    _currentLessonCompleted &&
                                    _quizCompleted
                                ? _nextLesson
                                : _currentLessonIndex <
                                        widget.lessons.length - 1
                                    ? () => _showCompletionRequiredDialog()
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.cardColor,
                              foregroundColor: _currentLessonIndex <
                                          widget.lessons.length - 1 &&
                                      _currentLessonCompleted &&
                                      _quizCompleted
                                  ? themeProvider.primaryColor
                                  : _currentLessonIndex <
                                          widget.lessons.length - 1
                                      ? Colors.orange
                                      : Colors.grey.withOpacity(0.5),
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _currentLessonIndex <
                                          widget.lessons.length - 1
                                      ? _currentLessonCompleted &&
                                              _quizCompleted
                                          ? themeProvider.primaryColor
                                          : Colors.orange
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

  Widget _buildStatusIndicator(
      String label, bool isCompleted, ThemeProvider themeProvider) {
    return Column(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? Colors.green : Colors.orange,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
