import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:afrilingo/features/courses/services/language_course_service.dart';
import 'package:afrilingo/features/lessons/services/lesson_service.dart';
import 'package:afrilingo/features/courses/models/course.dart';
import 'package:afrilingo/features/lessons/screens/lesson.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/dashboard/screens/notifications.dart';

// Keeping these as fallback colors
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

/// This widget uses a TabController to let the user switch between
/// the "Course Review" and "Categories" subscreens.
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LanguageCourseService _courseService = LanguageCourseService();
  final LessonService _lessonService = LessonService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Two tabs: "Course Review" and "Categories"
    _tabController = TabController(length: 2, vsync: this);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final courses = await _courseService.getAllCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToLessons(Course course) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final lessons = await _lessonService.getLessonsByCourseId(course.id);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(
            course: course,
            lessons: lessons,
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Kinyarwanda Courses',
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: themeProvider.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              height: 52,
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: themeProvider.primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: themeProvider.lightTextColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Course Review'),
                  Tab(text: 'Categories'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // "Course Review" content
                  _buildCourseReviewTab(),
                  // "Categories" content
                  _buildCategoriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 0),
    );
  }

  /// "Course Review" tab content: displays clickable chapter tiles.
  Widget _buildCourseReviewTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading courses...',
              style: TextStyle(
                color: themeProvider.lightTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load courses',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCourses,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: themeProvider.isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available yet',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      color: themeProvider.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          // Create a random color for each course
          final colors = [
            const Color(0xFFFCE4EC), // pink light
            const Color(0xFFE1F5FE), // light blue
            const Color(0xFFF1F8E9), // light green
            const Color(0xFFFFF3E0), // light orange
            const Color(0xFFE8EAF6), // light indigo
          ];
          final color = colors[index % colors.length];

          return _buildCourseCard(
            course: course,
            color: color,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildCourseCard({
    required Course course,
    required Color color,
    required int index,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToLessons(course),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header with background color
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? color.withOpacity(0.5) // Darken the colors in dark mode
                      : color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Course image
                    Positioned(
                      right: 20,
                      bottom: 0,
                      child: Image.network(
                        course.image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.school,
                              size: 80, color: themeProvider.primaryColor);
                        },
                      ),
                    ),
                    // Chapter badge
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Chapter ${course.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: themeProvider.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Course description
                    Text(
                      course.description ??
                          'Learn key vocabulary and phrases for everyday conversations.',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.lightTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Course details
                    Row(
                      children: [
                        _buildCourseDetailItem(
                          icon: Icons.access_time,
                          text: '${10 + index * 5} lessons',
                        ),
                        const SizedBox(width: 16),
                        _buildCourseDetailItem(
                          icon: Icons.bolt_outlined,
                          text: '${index * 10 + 50}% complete',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Start/Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToLessons(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Learning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDetailItem(
      {required IconData icon, required String text}) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeProvider.lightTextColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.lightTextColor,
          ),
        ),
      ],
    );
  }

  /// "Categories" tab content: displays a clickable search bar and category items.
  Widget _buildCategoriesTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Categories list
    final categories = [
      {
        'title': 'Foundations',
        'description': 'Learn the basics of Kinyarwanda',
        'icon': Icons.school_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Daily Life',
        'description': 'Essential phrases for everyday situations',
        'icon': Icons.home_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Expanding Expression',
        'description': 'Enhance your vocabulary and fluency',
        'icon': Icons.auto_stories_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Society and Culture',
        'description': 'Understand Rwandan traditions and customs',
        'icon': Icons.people_outlined,
        'color': Colors.purple,
      },
      {
        'title': 'Comprehension',
        'description': 'Practice understanding spoken Kinyarwanda',
        'icon': Icons.hearing_outlined,
        'color': Colors.red,
      },
      {
        'title': 'Advanced Communication',
        'description': 'Master complex conversations and topics',
        'icon': Icons.forum_outlined,
        'color': Colors.teal,
      },
      {
        'title': 'Creation and Analysis',
        'description': 'Create and analyze written content',
        'icon': Icons.create_outlined,
        'color': Colors.indigo,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for categories...',
                hintStyle: TextStyle(color: themeProvider.lightTextColor),
                prefixIcon:
                    Icon(Icons.search, color: themeProvider.lightTextColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          const SizedBox(height: 24),

          // Categories section title
          Text(
            'Learning Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore these categories to master Kinyarwanda',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 16),

          // Categories list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(
                title: category['title'] as String,
                description: category['description'] as String,
                icon: category['icon'] as IconData,
                color: category['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds a clickable category item (for the Categories tab).
  Widget _buildCategoryItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: themeProvider.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => debugPrint("$title tapped"),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        color.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                // Category details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.lightTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: themeProvider.lightTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
