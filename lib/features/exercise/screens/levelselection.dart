import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:afrilingo/features/exercise/screens/wordmatching.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/lessons/services/lesson_service.dart';
import 'package:afrilingo/features/lessons/models/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/features/quiz/screens/QuizScreen.dart';
import 'package:afrilingo/features/quiz/models/quiz.dart';
import 'package:afrilingo/core/services/user_cache_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  final int courseId;

  const LevelSelectionScreen({
    super.key,
    this.courseId = 1, // Default to course ID 1 if not provided
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final LessonService _lessonService = LessonService();
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _error;
  int _highestUnlockedLevel = 1; // Default to level 1 unlocked
  Map<int, bool> _completedLevels = {};
  String _courseName = 'Quiz Progression'; // Default course name
  String _userName = ''; // User's name

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    _loadUserName();
  }

  // Load all quizzes and user progress
  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 1. Load lessons for the course
      final lessons =
          await _lessonService.getLessonsByCourseId(widget.courseId);

      // 2. Sort lessons by orderIndex
      lessons.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      // 3. Fetch quiz for each lesson
      final List<Quiz> quizzes = [];
      for (var lesson in lessons) {
        try {
          final quiz = await _lessonService.getQuizForLesson(lesson.id);
          quizzes.add(quiz);
        } catch (e) {
          print('Error loading quiz for lesson ${lesson.id}: $e');
          // Continue to next lesson if quiz can't be loaded
        }
      }

      // 4. Load user progress from shared preferences
      await _loadProgress();

      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
        if (lessons.isNotEmpty) {
          _courseName = '${lessons[0].type} Assessment';
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Load progress from preferences
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the highest unlocked level
      final highestLevel =
          prefs.getInt('quiz_highest_unlocked_level_${widget.courseId}') ?? 1;

      // Get completed levels
      final completedLevelsStr =
          prefs.getString('quiz_completed_levels_${widget.courseId}') ?? '';

      setState(() {
        _highestUnlockedLevel = highestLevel;

        // Parse completed levels from string
        if (completedLevelsStr.isNotEmpty) {
          final levelsList = completedLevelsStr.split(',');
          for (var level in levelsList) {
            if (level.isNotEmpty) {
              _completedLevels[int.parse(level)] = true;
            }
          }
        }
      });
    } catch (e) {
      print('Error loading progress: $e');
      // Set defaults if error
      setState(() {
        _highestUnlockedLevel = 1;
        _completedLevels = {1: false};
      });
    }
  }

  // Load user's name from cache
  Future<void> _loadUserName() async {
    try {
      final name =
          await UserCacheService.getCachedFullName(defaultValue: 'User');
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      // Default to empty if error
      setState(() {
        _userName = 'User';
      });
    }
  }

  // Mark a level as completed with 100% score
  Future<void> _markLevelCompleted(int levelIndex, bool isPerfectScore) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update completed levels only if perfect score
      if (isPerfectScore) {
        setState(() {
          _completedLevels[levelIndex] = true;

          // Unlock next level if available
          if (levelIndex < _quizzes.length &&
              levelIndex + 1 > _highestUnlockedLevel) {
            _highestUnlockedLevel = levelIndex + 1;
          }
        });

        // Save to preferences
        await prefs.setInt('quiz_highest_unlocked_level_${widget.courseId}',
            _highestUnlockedLevel);

        final completedLevels = _completedLevels.keys
            .where((k) => _completedLevels[k] == true)
            .join(',');
        await prefs.setString(
            'quiz_completed_levels_${widget.courseId}', completedLevels);
      }
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: themeProvider.textColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                                width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: themeProvider.isDarkMode
                                ? Colors.grey.shade800
                                : Colors.white,
                            child: Icon(
                              Icons.person,
                              color: themeProvider.isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const RwandaFlagCircle(),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(
                                themeProvider.isDarkMode ? 0.2 : 0.3),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: themeProvider.primaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.secondaryColor, // Light brown
                      themeProvider.primaryColor, // Dark brown
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Quiz Progression: $_courseName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'Complete each quiz with 100% score to unlock the next level!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? _buildLoadingView(themeProvider)
                    : _error != null
                        ? _buildErrorView(themeProvider)
                        : _quizzes.isEmpty
                            ? _buildEmptyView(themeProvider)
                            : CurvedLevelPath(
                                quizzes: _quizzes,
                                highestUnlockedLevel: _highestUnlockedLevel,
                                completedLevels: _completedLevels,
                                onLevelSelected: (quiz, levelIndex) {
                                  // Navigate to the quiz screen
                                  if (quiz.lessonId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizScreen(
                                          lessonId: quiz.lessonId!,
                                          isLevelProgressionMode: true,
                                        ),
                                      ),
                                    ).then((result) {
                                      // When returning from the quiz, check if we should unlock the next level
                                      // This would require modifying the QuizScreen to return the score
                                      if (result != null &&
                                          result is Map<String, dynamic>) {
                                        final score =
                                            result['score'] as int? ?? 0;
                                        final isPerfectScore = score == 100;

                                        // Only mark as completed if 100% score
                                        _markLevelCompleted(
                                            levelIndex, isPerfectScore);

                                        // Show a message about unlocking next level
                                        if (isPerfectScore &&
                                            levelIndex < _quizzes.length - 1) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Perfect score! You\'ve unlocked level ${levelIndex + 2}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (!isPerfectScore) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'You need 100% to unlock the next level. Try again!'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  }
                                },
                                themeProvider: themeProvider,
                              ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 3),
    );
  }

  Widget _buildLoadingView(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: themeProvider.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading quizzes...',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load quizzes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuizzes,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: themeProvider.lightTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No quizzes found for this course',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class RwandaFlagCircle extends StatelessWidget {
  const RwandaFlagCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: themeProvider.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            width: 1),
      ),
      child: ClipOval(
        child: CustomPaint(
          size: const Size(18, 18),
          painter: RwandaFlagPainter(),
        ),
      ),
    );
  }
}

class RwandaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Rwanda flag colors
    const blue = Color(0xFF00A1DE);
    const yellow = Color(0xFFE5BE01);
    const green = Color(0xFF1EB53A);

    // Create a circular flag
    final Paint paint = Paint();

    // Draw blue background for entire circle
    paint.color = blue;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Yellow stripe in the middle
    paint.color = yellow;
    final yellowRect =
        Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3);
    canvas.drawRect(yellowRect, paint);

    // Green stripe at the bottom
    paint.color = green;
    final greenRect =
        Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35);
    canvas.drawRect(greenRect, paint);

    // Draw boundary circle to clip the edges
    paint.color = Colors.transparent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedLevelPath extends StatelessWidget {
  final List<Quiz> quizzes;
  final int highestUnlockedLevel;
  final Map<int, bool> completedLevels;
  final Function(Quiz, int) onLevelSelected;
  final ThemeProvider themeProvider;

  const CurvedLevelPath({
    super.key,
    required this.quizzes,
    required this.highestUnlockedLevel,
    required this.completedLevels,
    required this.onLevelSelected,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Limit to maximum 6 levels for this UI
    final displayQuizzes = quizzes.length > 6 ? quizzes.sublist(0, 6) : quizzes;

    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 500),
          painter: CurvedPathPainter(themeProvider: themeProvider),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Dynamically generate level circles based on quizzes
            for (int i = 0; i < displayQuizzes.length; i++)
              _buildLevelRow(
                context,
                i,
                displayQuizzes[i],
                isLeftAligned: i % 2 == 0, // Alternate left/right alignment
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelRow(BuildContext context, int index, Quiz quiz,
      {bool isLeftAligned = true}) {
    final levelNumber = index + 1;
    final isLocked = levelNumber > highestUnlockedLevel;
    final isCompleted = completedLevels[levelNumber] == true;

    // Choose icon based on quiz status
    IconData icon;
    if (isLocked) {
      icon = Icons.lock;
    } else if (isCompleted) {
      icon = Icons.check_circle;
    } else {
      icon = Icons.quiz;
    }

    // Set circle color based on status
    Color circleColor;
    if (isLocked) {
      circleColor = themeProvider.isDarkMode
          ? Colors.grey.shade700
          : Colors.grey.shade400;
    } else if (isCompleted) {
      circleColor = Colors.green.withOpacity(0.7);
    } else if (levelNumber == highestUnlockedLevel) {
      circleColor = themeProvider.primaryColor;
    } else {
      circleColor = themeProvider.accentColor.withOpacity(0.7);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isLeftAligned) const SizedBox(width: 80),
        GestureDetector(
          onTap: isLocked ? null : () => onLevelSelected(quiz, levelNumber),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: levelNumber == highestUnlockedLevel
                      ? Border.all(color: themeProvider.primaryColor, width: 4)
                      : null,
                  boxShadow: levelNumber == highestUnlockedLevel
                      ? [
                          BoxShadow(
                            color: themeProvider.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Level icon
                    Icon(
                      icon,
                      color:
                          (levelNumber == highestUnlockedLevel && !isCompleted)
                              ? Colors.white
                              : Colors.white,
                      size: 28,
                    ),

                    // Level number indicator at the bottom
                    Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey.shade600
                              : themeProvider.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$levelNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (!isLocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green
                          : themeProvider.dividerColor,
                    ),
                  ),
                  child: Text(
                    isCompleted ? "100% Score" : "Quiz ${levelNumber}",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isCompleted ? Colors.green : themeProvider.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isLeftAligned) const SizedBox(width: 80),
      ],
    );
  }
}

class CurvedPathPainter extends CustomPainter {
  final ThemeProvider themeProvider;

  CurvedPathPainter({required this.themeProvider});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeProvider.primaryColor
          .withOpacity(themeProvider.isDarkMode ? 0.3 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = themeProvider.primaryColor
          .withOpacity(themeProvider.isDarkMode ? 0.3 : 0.5)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Starting point - center of the screen
    final centerX = size.width / 2;
    final spacing = size.height / 7;
    final curveOffset = 30.0;

    // Coordinates for the first level circle
    final level1X = centerX;
    final level1Y = spacing * 1.5;

    // Coordinates for the second level circle
    final level2X = centerX + 80;
    final level2Y = spacing * 2.5;

    // Coordinates for the third level circle
    final level3X = centerX;
    final level3Y = spacing * 3.5;

    // Coordinates for the fourth level circle
    final level4X = centerX + 80;
    final level4Y = spacing * 4.5;

    // Coordinates for the fifth level circle
    final level5X = centerX;
    final level5Y = spacing * 5.5;

    // Coordinates for the sixth level circle
    final level6X = centerX + 80;
    final level6Y = spacing * 6.5;

    // Draw a curved path connecting all level points
    path.moveTo(level1X, spacing);

    // Curve to level 1
    path.quadraticBezierTo(level1X, level1Y - curveOffset, level1X, level1Y);

    // Curve to level 2
    path.quadraticBezierTo(centerX + curveOffset,
        level1Y + (level2Y - level1Y) / 2, level2X, level2Y);

    // Curve to level 3
    path.quadraticBezierTo(level2X - curveOffset,
        level2Y + (level3Y - level2Y) / 2, level3X, level3Y);

    // Curve to level 4
    path.quadraticBezierTo(centerX + curveOffset,
        level3Y + (level4Y - level3Y) / 2, level4X, level4Y);

    // Curve to level 5
    path.quadraticBezierTo(level4X - curveOffset,
        level4Y + (level5Y - level4Y) / 2, level5X, level5Y);

    // Curve to level 6
    path.quadraticBezierTo(centerX + curveOffset,
        level5Y + (level6Y - level5Y) / 2, level6X, level6Y);

    canvas.drawPath(path, paint);

    // Draw dots along the curved path at more irregular intervals
    List<double> dotPositions = [0.15, 0.3, 0.45, 0.55, 0.7, 0.85];

    // Curve 1 - from top to level 1
    for (var position in dotPositions) {
      final t = position;
      final x = level1X;
      final y = spacing + (level1Y - spacing) * t;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 2 - from level 1 to level 2
    for (var position in dotPositions) {
      final t = position;
      final controlX = centerX + curveOffset;
      final controlY = level1Y + (level2Y - level1Y) / 2;

      final x = (1 - t) * (1 - t) * level1X +
          2 * (1 - t) * t * controlX +
          t * t * level2X;
      final y = (1 - t) * (1 - t) * level1Y +
          2 * (1 - t) * t * controlY +
          t * t * level2Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 3 - from level 2 to level 3
    for (var position in dotPositions) {
      final t = position;
      final controlX = level2X - curveOffset;
      final controlY = level2Y + (level3Y - level2Y) / 2;

      final x = (1 - t) * (1 - t) * level2X +
          2 * (1 - t) * t * controlX +
          t * t * level3X;
      final y = (1 - t) * (1 - t) * level2Y +
          2 * (1 - t) * t * controlY +
          t * t * level3Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 4 - from level 3 to level 4
    for (var position in dotPositions) {
      final t = position;
      final controlX = centerX + curveOffset;
      final controlY = level3Y + (level4Y - level3Y) / 2;

      final x = (1 - t) * (1 - t) * level3X +
          2 * (1 - t) * t * controlX +
          t * t * level4X;
      final y = (1 - t) * (1 - t) * level3Y +
          2 * (1 - t) * t * controlY +
          t * t * level4Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Curve 5 - from level 4 to level 5
    for (var position in dotPositions) {
      final t = position;
      final controlX = level4X - curveOffset;
      final controlY = level4Y + (level5Y - level4Y) / 2;

      final x = (1 - t) * (1 - t) * level4X +
          2 * (1 - t) * t * controlX +
          t * t * level5X;
      final y = (1 - t) * (1 - t) * level4Y +
          2 * (1 - t) * t * controlY +
          t * t * level5Y;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
