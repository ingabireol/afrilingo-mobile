import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/services/theme_provider.dart';
import '../models/quiz.dart';
import '../services/lesson_service.dart';

// Keeping these as fallback colors
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class QuizStartScreen extends StatelessWidget {
  final int lessonId;

  const QuizStartScreen({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz,
                size: 64,
                color: themeProvider.accentColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Let's Test Your Knowledge",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Answer the questions to check your understanding of this lesson.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.lightTextColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(lessonId: lessonId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final int lessonId;

  const QuizScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final LessonService _lessonService = LessonService();
  Quiz? _quiz;
  int _currentQuestionIndex = 0;
  List<QuizAnswer> _answers = [];
  bool _isLoading = true;
  String? _error;
  bool _quizCompleted = false;
  QuizResult? _quizResult;
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quiz = await _lessonService.getQuizForLesson(widget.lessonId);
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _submitQuizAnswer() {
    if (_quiz == null || _selectedOptionId == null) return;

    HapticFeedback.lightImpact();

    final question = _quiz!.questions[_currentQuestionIndex];
    _answers.add(QuizAnswer(
      questionId: question.id,
      answer: _selectedOptionId.toString(),
      selectedOptionId: _selectedOptionId!,
    ));

    print(
        'Added answer: questionId=${question.id}, optionId=${_selectedOptionId}');

    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionId = null; // Reset selected option for the next question
      });
    } else {
      _submitQuiz();
    }
  }

  void _handleSubmissionError() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Error Submitting Quiz',
          style: TextStyle(
            color: themeProvider.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'There was a problem submitting your quiz. Would you like to try again or return to your lesson?',
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _submitQuiz(); // Try again
            },
            child: Text(
              'Try Again',
              style: TextStyle(color: themeProvider.primaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to lesson
            },
            child: const Text('Back to Lesson'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz() async {
    if (_quiz == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Debug output before submission
      print('Submitting quiz ${_quiz!.id} with ${_answers.length} answers:');
      for (var answer in _answers) {
        print(
            '- Question ${answer.questionId}: selected option ${answer.answer}');
      }

      final result = await _lessonService.submitQuizAnswers(
        _quiz!.id,
        _answers,
      );

      setState(() {
        _quizResult = result;
        _quizCompleted = true;
        _isLoading = false;
      });

      // After successful completion, update progress tracking
      if (result.passed) {
        // Try to mark the lesson as completed
        try {
          // Get the lesson ID associated with this quiz
          final lessonId = _quiz!.lessonId;
          if (lessonId != null) {
            await _lessonService.markLessonCompleted(lessonId);
          }
        } catch (e) {
          print('Error marking lesson as completed after quiz: $e');
        }
      }
    } catch (e) {
      // Extract a more user-friendly error message
      String errorMessage = e.toString();

      // If there's a specific error about encoding/converting, show a simpler message
      if (errorMessage.contains('Converting object') ||
          errorMessage.contains('encodable object') ||
          errorMessage.contains('Map len') ||
          errorMessage.contains('parse error')) {
        errorMessage =
            'There was a problem submitting your quiz. Please try again.';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      // Show error dialog with retry option
      _handleSubmissionError();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers = [];
      _quizCompleted = false;
      _quizResult = null;
      _selectedOptionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: themeProvider.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading quiz...',
                style: TextStyle(
                  color: themeProvider.lightTextColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 24),
                Text(
                  'An error occurred',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.lightTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loadQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 64, color: themeProvider.lightTextColor),
                const SizedBox(height: 24),
                Text(
                  'No quiz available',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'There is no quiz available for this lesson yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.lightTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Back to Lesson'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quizCompleted && _quizResult != null) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          title: const Text('Quiz Results'),
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _quizResult!.passed ? Colors.green[50] : Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _quizResult!.passed ? Icons.check_circle : Icons.cancel,
                    size: 80,
                    color: _quizResult!.passed ? Colors.green : Colors.red[400],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _quizResult!.passed ? 'Congratulations!' : 'Keep practicing!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _quizResult!.passed ? Colors.green : Colors.red[400],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _quizResult!.passed
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Your score: ${_quizResult!.score}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _quizResult!.passed
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: themeProvider.primaryColor,
                  ),
                  child: const Text('Back to Lesson'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
            'Question ${_currentQuestionIndex + 1}/${_quiz!.questions.length}'),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _quiz!.questions.length,
              backgroundColor: themeProvider.dividerColor,
              color: themeProvider.primaryColor,
              minHeight: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      color: themeProvider.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentQuestion.question,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...currentQuestion.options.map((option) {
                      final isSelected = _selectedOptionId == option.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: isSelected ? 4 : 1,
                          color: themeProvider.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? themeProvider.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOptionId = option.id;
                              });
                              HapticFeedback.selectionClick();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? themeProvider.primaryColor
                                            : themeProvider.lightTextColor,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? themeProvider.primaryColor
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option.optionText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? themeProvider.primaryColor
                                            : themeProvider.textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentQuestionIndex > 0
                      ? TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                              // Restore previous answer if available
                              if (_answers.length > _currentQuestionIndex) {
                                final previousAnswer =
                                    _answers[_currentQuestionIndex];
                                // Set the selected option ID from the stored answer
                                _selectedOptionId =
                                    previousAnswer.selectedOptionId;
                                // Remove the answer since we're going back
                                _answers.removeAt(_currentQuestionIndex);
                              } else {
                                _selectedOptionId = null;
                              }
                            });
                            HapticFeedback.lightImpact();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: TextButton.styleFrom(
                            foregroundColor: themeProvider.primaryColor,
                          ),
                        )
                      : const SizedBox(width: 100),
                  ElevatedButton(
                    onPressed:
                        _selectedOptionId != null ? _submitQuizAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          themeProvider.lightTextColor.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex < _quiz!.questions.length - 1
                          ? 'Next'
                          : 'Submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function that handles showing the quiz result
  Widget _buildQuizResultView() {
    if (_quizResult == null) return Container();

    final bool isPassed = _quizResult!.passed;
    final int score = _quizResult!.score;

    // Update the lesson progress status after quiz completion
    // (regardless of pass/fail, the user has engaged with the content)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (_quiz?.lessonId != null) {
          _lessonService.markLessonCompleted(_quiz!.lessonId!);
        }
      } catch (e) {
        print('Error updating lesson progress: $e');
      }
    });

    return Column(
        // ... rest of the method
        );
  }
}
