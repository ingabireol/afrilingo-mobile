import 'package:flutter/material.dart';
import '../../models/language.dart';
import '../../models/course.dart';
import '../../services/language_course_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedDifficulty = 'BEGINNER';
  Language? _selectedLanguage;
  List<Language> _languages = [];
  
  bool _isLoading = false;
  bool _isLoadingLanguages = true;
  String? _errorMessage;
  
  final LanguageCourseService _service = LanguageCourseService();
  
  final List<String> _difficulties = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final languages = await _service.getAllLanguages();
      setState(() {
        _languages = languages;
        _isLoadingLanguages = false;
        if (languages.isNotEmpty) {
          _selectedLanguage = languages.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingLanguages = false;
        _errorMessage = 'Failed to load languages: $e';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedLanguage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new course object
        final course = Course(
          id: 0, // ID will be assigned by the backend
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          language: _selectedLanguage!,
          difficulty: _selectedDifficulty,
        );

        // Send to backend
        await _service.createCourse(course);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully')),
          );
          Navigator.pop(context, true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating course: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLanguages) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Course'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Course'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLanguages,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_languages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Course'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No languages available. Please add a language first.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-language');
                },
                child: const Text('Add Language'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Course'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  hintText: 'e.g. Swahili for Beginners',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the course',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'URL to the course image',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty Level',
                ),
                items: _difficulties.map((difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Text(difficulty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Language>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Language',
                ),
                items: _languages.map((language) {
                  return DropdownMenuItem<Language>(
                    value: language,
                    child: Text(language.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a language';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}