import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/language_course_service.dart';

class CourseListScreen extends StatefulWidget {
  final int languageId;

  const CourseListScreen({super.key, required this.languageId});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final LanguageCourseService _service = LanguageCourseService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAuthError = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _service.getCoursesByLanguageId(widget.languageId);
      setState(() {
        _courses = courses;
        _isLoading = false;
        _isAuthError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAuthError = e.toString().contains('Authentication required');
        _errorMessage = _isAuthError
            ? 'Your session has expired. Please log in again to continue.'
            : 'Failed to load courses. Please check your internet connection and try again.';
      });
    }
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isAuthError = false;
    });
    await _loadCourses();
  }

  void _handleLoginRedirect() {
    // TODO: Navigate to login screen
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 48,
              color: _isAuthError ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isAuthError ? _handleLoginRedirect : _refreshCourses,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAuthError ? Colors.orange : Colors.blue,
              ),
              child: Text(_isAuthError ? 'Log In' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return const Center(
        child: Text(
          'No courses available for this language yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: course.image.isNotEmpty
                ? Image.network(
                    course.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 50);
                    },
                  )
                : const Icon(Icons.book, size: 50),
            title: Text(course.title),
            subtitle: Text(course.description),
            trailing: Text(
              course.difficulty,
              style: TextStyle(
                color: _getDifficultyColor(course.difficulty),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: Navigate to course details
            },
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
