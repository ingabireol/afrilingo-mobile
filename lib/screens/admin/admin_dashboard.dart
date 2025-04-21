import 'package:flutter/material.dart';
import '../../models/language.dart';
import '../../models/course.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_course_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  final LanguageCourseService _languageCourseService = LanguageCourseService();
  final AuthService _authService = AuthService();
  
  List<Language> _languages = [];
  List<Course> _courses = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminStatus();
    _loadData();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
    
    if (!isAdmin) {
      // Show unauthorized message if not admin
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not authorized to access this page')),
        );
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final languages = await _languageCourseService.getAllLanguages();
      final courses = await _languageCourseService.getAllCourses();
      
      setState(() {
        _languages = languages;
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Unauthorized Access')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Languages'),
            Tab(text: 'Courses'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLanguagesTab(),
                _buildCoursesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddLanguageDialog();
          } else {
            _showAddCourseDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return _languages.isEmpty
        ? const Center(child: Text('No languages available'))
        : ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: language.flagImage.isNotEmpty
                      ? Image.network(
                          language.flagImage,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.language),
                        )
                      : const Icon(Icons.language),
                  title: Text(language.name),
                  subtitle: Text('Code: ${language.code}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditLanguageDialog(language),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteLanguage(language),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCoursesTab() {
    return _courses.isEmpty
        ? const Center(child: Text('No courses available'))
        : ListView.builder(
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: course.imageUrl.isNotEmpty
                      ? Image.network(
                          course.imageUrl,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
                  title: Text(course.title),
                  subtitle: Text(
                      'Language: ${course.language.name} | Difficulty: ${course.difficulty}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCourseDialog(course),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteCourse(course),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Language management methods
  void _showAddLanguageDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    final flagImageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Language Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Language Code'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: flagImageController,
                decoration: const InputDecoration(labelText: 'Flag Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and code are required')),
                );
                return;
              }

              final newLanguage = Language(
                id: 0, // Will be assigned by the server
                name: nameController.text,
                code: codeController.text,
                description: descriptionController.text,
                flagImage: flagImageController.text,
              );

              try {
                await _adminService.createLanguage(newLanguage);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding language: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditLanguageDialog(Language language) {
    final nameController = TextEditingController(text: language.name);
    final codeController = TextEditingController(text: language.code);
    final descriptionController = TextEditingController(text: language.description);
    final flagImageController = TextEditingController(text: language.flagImage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Language Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Language Code'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: flagImageController,
                decoration: const InputDecoration(labelText: 'Flag Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and code are required')),
                );
                return;
              }

              final updatedLanguage = Language(
                id: language.id,
                name: nameController.text,
                code: codeController.text,
                description: descriptionController.text,
                flagImage: flagImageController.text,
              );

              try {
                await _adminService.updateLanguage(language.id, updatedLanguage);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating language: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLanguage(Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${language.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _adminService.deleteLanguage(language.id);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting language: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Course management methods
  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedDifficulty = 'BEGINNER';
    int selectedLanguageId = _languages.isNotEmpty ? _languages[0].id : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Course Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDifficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED']
                    .map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDifficulty = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedLanguageId,
                decoration: const InputDecoration(labelText: 'Language'),
                items: _languages
                    .map((language) => DropdownMenuItem(
                          value: language.id,
                          child: Text(language.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedLanguageId = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  selectedLanguageId == 0 ||
                  _languages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Title and language are required')),
                );
                return;
              }

              final language = _languages.firstWhere(
                  (lang) => lang.id == selectedLanguageId);

              final newCourse = Course(
                id: 0, // Will be assigned by the server
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: imageUrlController.text,
                language: language,
                difficulty: selectedDifficulty,
              );

              try {
                await _adminService.createCourse(newCourse);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding course: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Course course) {
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description);
    final imageUrlController = TextEditingController(text: course.imageUrl);
    String selectedDifficulty = course.difficulty;
    int selectedLanguageId = course.language.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Course Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDifficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED']
                    .map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDifficulty = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedLanguageId,
                decoration: const InputDecoration(labelText: 'Language'),
                items: _languages
                    .map((language) => DropdownMenuItem(
                          value: language.id,
                          child: Text(language.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedLanguageId = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title is required')),
                );
                return;
              }

              final language = _languages.firstWhere(
                  (lang) => lang.id == selectedLanguageId);

              final updatedCourse = Course(
                id: course.id,
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: imageUrlController.text,
                language: language,
                difficulty: selectedDifficulty,
              );

              try {
                await _adminService.updateCourse(course.id, updatedCourse);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating course: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${course.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _adminService.deleteCourse(course.id);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting course: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}