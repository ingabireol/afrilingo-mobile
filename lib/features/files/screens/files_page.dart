import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/exercises/screens/foodanddrinks.dart';
import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:afrilingo/utils/app_theme.dart';
import 'package:afrilingo/features/lessons/services/lesson_service.dart';
import 'package:afrilingo/features/lessons/screens/lesson.dart';
import 'package:afrilingo/features/lessons/models/lesson.dart';
import 'package:afrilingo/features/courses/models/course.dart';
import 'package:afrilingo/features/language/models/language.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class FilesPage extends StatefulWidget {
  final int initialTabIndex;

  const FilesPage({super.key, this.initialTabIndex = 0});

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _username = 'buntu Levy Caleb';
  final String _language = 'Kinyarwanda';
  final LessonService _lessonService = LessonService();

  // State variables for dynamic categories
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _loadCategories();
  }

  // Load lesson categories from the server
  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categories = await _lessonService.getLessonTypes();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Use default categories if there's an error
        _categories = _lessonService.getDefaultCategories();
      });
    }
  }

  // Navigate to lessons of a specific type
  Future<void> _navigateToLessonsByType(String lessonType) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get lessons by type
      final lessons = await _lessonService.getLessonsByType(lessonType);

      setState(() {
        _isLoading = false;
      });

      if (lessons.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No lessons found for this category yet'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!mounted) return;

      // Navigate to the first lesson in this category
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(
            lessons: lessons,
            // Create a mock course object with just the essential information
            course: Course(
              id: 1,
              title: 'Category Lessons',
              description: 'Lessons by category',
              image: '',
              language: Language(
                id: 1,
                name: 'Kinyarwanda',
                code: 'rw',
                description: 'The language of Rwanda',
                flagImage: '',
              ),
              difficulty: 'Beginner',
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading lessons: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Column(
          children: [
            Text(
              _username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _language,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: themeProvider.lightTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: themeProvider.primaryColor,
            ),
            onPressed: () {
              // Handle search
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeProvider.primaryColor,
          labelColor: themeProvider.primaryColor,
          unselectedLabelColor: themeProvider.lightTextColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(width: 3.0, color: themeProvider.primaryColor),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          tabs: const [
            Tab(text: 'Sets'),
            Tab(text: 'Created'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? _buildLoadingIndicator(themeProvider)
              : _error != null
                  ? _buildErrorState(themeProvider)
                  : _buildGridSection(themeProvider),
          _buildEmptyTab('No created files yet.', themeProvider),
          _buildEmptyTab('No saved files yet.', themeProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new file/set
        },
        backgroundColor: themeProvider.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: themeProvider.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load categories',
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
            onPressed: _loadCategories,
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

  Widget _buildGridSection(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'Learning Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore these categories to learn Kinyarwanda vocabulary',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];

              return _buildCategoryCard(
                title: category['title'],
                icon: category['icon'],
                color: category['color'],
                isSelected:
                    false, // We could track selected categories if needed
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to lessons of this type
                  _navigateToLessonsByType(category['type']);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    bool isSelected = false,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: themeProvider.primaryColor, width: 2)
              : Border.all(color: themeProvider.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to explore',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message, ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: themeProvider.lightTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
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
