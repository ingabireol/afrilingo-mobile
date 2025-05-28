// quiz_start_screen.dart
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/lesson_service.dart';

class QuizStartScreen extends StatelessWidget {
  final int lessonId;

  const QuizStartScreen({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Let's see how far you've got",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '(◕‿◕)',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultipleChoiceScreen(lessonId: lessonId),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B4513),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultipleChoiceScreen extends StatefulWidget {
  final int lessonId;

  const MultipleChoiceScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  final LessonService _lessonService = LessonService();
  Quiz? _quiz;
  int _currentQuestionIndex = 0;
  List<QuizAnswer> _answers = [];
  bool _isLoading = true;
  String? _error;
  bool _quizCompleted = false;
  QuizResult? _quizResult;

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

  void _submitAnswer(String answer) {
    if (_quiz == null) return;

    final question = _quiz!.questions[_currentQuestionIndex];
    _answers.add(QuizAnswer(
      questionId: question.id,
      answer: answer,
    ));

    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    if (_quiz == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _lessonService.submitQuizAnswers(
        _quiz!.id,
        _answers,
      );

      setState(() {
        _quizResult = result;
        _quizCompleted = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers = [];
      _quizCompleted = false;
      _quizResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuiz,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_quiz == null) {
      return const Scaffold(
        body: Center(
          child: Text('No quiz available for this lesson'),
        ),
      );
    }

    if (_quizCompleted && _quizResult != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _quizResult!.passed ? 'Congratulations!' : 'Keep practicing!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your score: ${_quizResult!.score}%',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Lesson'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${_quiz!.questions.length}'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...currentQuestion.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B4513),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF8B4513)),
                    ),
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}