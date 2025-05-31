import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/language.dart';
import '../../models/course.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_course_service.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kTextColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar with custom design
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: kLightTextColor,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(
                  text: 'Languages',
                  icon: Icon(Icons.language),
                ),
                Tab(
                  text: 'Courses',
                  icon: Icon(Icons.book),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading data...',
                      style: TextStyle(
                        color: kLightTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: TabBarView(
              controller: _tabController,
              children: [
                _buildLanguagesTab(),
                _buildCoursesTab(),
                ],
              ),
            ),
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
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return _languages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.language,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No languages available',
                  style: TextStyle(
                    fontSize: 18,
                    color: kLightTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddLanguageDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Language'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: language.flagImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                          language.flagImage,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.language, color: kPrimaryColor, size: 30),
                                ),
                              )
                            : const Icon(Icons.language, color: kPrimaryColor, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: kTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${language.code}',
                              style: TextStyle(
                                color: kLightTextColor,
                                fontSize: 14,
                              ),
                            ),
                            if (language.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                language.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                    children: [
                      IconButton(
                            icon: const Icon(Icons.edit, color: kAccentColor),
                        onPressed: () => _showEditLanguageDialog(language),
                            tooltip: 'Edit',
                      ),
                      IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                        onPressed: () => _confirmDeleteLanguage(language),
                            tooltip: 'Delete',
                          ),
                        ],
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
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses available',
                  style: TextStyle(
                    fontSize: 18,
                    color: kLightTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddCourseDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              
              // Create a color based on difficulty level
              Color difficultyColor;
              switch (course.difficulty) {
                case 'BEGINNER':
                  difficultyColor = Colors.green;
                  break;
                case 'INTERMEDIATE':
                  difficultyColor = Colors.orange;
                  break;
                case 'ADVANCED':
                  difficultyColor = Colors.red;
                  break;
                default:
                  difficultyColor = kPrimaryColor;
              }
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course header with image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            color: kPrimaryColor.withOpacity(0.1),
                            child: course.image.isNotEmpty
                      ? Image.network(
                          course.image,
                                    fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.image_not_supported, size: 40)),
                                  )
                                : const Center(child: Icon(Icons.book, size: 40)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              course.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Course details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Language and difficulty
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                                    const Icon(Icons.language, size: 16, color: kPrimaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      course.language.name,
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.signal_cellular_alt, size: 16, color: difficultyColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      course.difficulty,
                                      style: TextStyle(
                                        color: difficultyColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Description
                          if (course.description?.isNotEmpty == true) ...[
                            Text(
                              course.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: kLightTextColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                        icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                        onPressed: () => _showEditCourseDialog(course),
                                style: TextButton.styleFrom(
                                  foregroundColor: kAccentColor,
                      ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                        icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                        onPressed: () => _confirmDeleteCourse(course),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade400,
                                ),
                      ),
                    ],
                  ),
                        ],
                      ),
                    ),
                  ],
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
        title: Row(
          children: [
            Icon(Icons.language, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text('Add New Language'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                nameController,
                'Language Name',
                Icons.text_fields,
                'Enter language name',
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                codeController,
                'Language Code',
                Icons.code,
                'e.g., EN, FR, KIN',
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                descriptionController,
                'Description',
                Icons.description,
                'Brief description of language',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                flagImageController,
                'Flag Image URL',
                Icons.image,
                'Enter image URL',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Language ${newLanguage.name} added successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding language: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        title: Row(
          children: [
            Icon(Icons.edit, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text('Edit ${language.name}'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                nameController,
                'Language Name',
                Icons.text_fields,
                'Enter language name',
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                codeController,
                'Language Code',
                Icons.code,
                'e.g., EN, FR, KIN',
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                descriptionController,
                'Description',
                Icons.description,
                'Brief description of language',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                flagImageController,
                'Flag Image URL',
                Icons.image,
                'Enter image URL',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Language updated successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating language: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Confirm Delete'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          'Are you sure you want to delete ${language.name}? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteLanguage(language.id);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('${language.name} deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting language: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        title: Row(
          children: [
            Icon(Icons.book, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text('Add New Course'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                titleController,
                'Course Title',
                Icons.title,
                'Enter course title',
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                descriptionController,
                'Description',
                Icons.description,
                'Course description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                imageUrlController,
                'Image URL',
                Icons.image,
                'Enter image URL',
              ),
              const SizedBox(height: 16),
              
              // Difficulty dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kDividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    prefixIcon: Icon(Icons.signal_cellular_alt),
                    border: InputBorder.none,
                  ),
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
              ),
              
              const SizedBox(height: 16),
              
              // Language dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kDividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<int>(
                value: selectedLanguageId,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    prefixIcon: Icon(Icons.language),
                    border: InputBorder.none,
                  ),
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
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                image: imageUrlController.text,
                language: language,
                difficulty: selectedDifficulty,
              );

              try {
                await _adminService.createCourse(newCourse);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Course ${newCourse.title} added successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding course: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Course course) {
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description);
    final imageUrlController = TextEditingController(text: course.image);
    String selectedDifficulty = course.difficulty;
    int selectedLanguageId = course.language.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text('Edit ${course.title}'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                titleController,
                'Course Title',
                Icons.title,
                'Enter course title',
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                descriptionController,
                'Description',
                Icons.description,
                'Course description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                imageUrlController,
                'Image URL',
                Icons.image,
                'Enter image URL',
              ),
              const SizedBox(height: 16),
              
              // Difficulty dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kDividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    prefixIcon: Icon(Icons.signal_cellular_alt),
                    border: InputBorder.none,
                  ),
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
              ),
              
              const SizedBox(height: 16),
              
              // Language dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kDividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<int>(
                value: selectedLanguageId,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    prefixIcon: Icon(Icons.language),
                    border: InputBorder.none,
                  ),
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
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                image: imageUrlController.text,
                language: language,
                difficulty: selectedDifficulty,
              );

              try {
                await _adminService.updateCourse(course.id, updatedCourse);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Course updated successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating course: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Confirm Delete'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          'Are you sure you want to delete ${course.title}? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kLightTextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteCourse(course.id);
                Navigator.pop(context);
                _loadData(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('${course.title} deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting course: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper method for dialog text fields
  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kLightTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor),
        ),
      ),
    );
  }
}