import 'package:afrilingo/features/dashboard/screens/notifications.dart';
import 'package:afrilingo/features/dashboard/screens/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/features/profile/user_profile.dart';
import 'package:afrilingo/core/services/user_cache_service.dart';
import 'package:afrilingo/utils/profile_image_helper.dart';
import 'package:afrilingo/features/lessons/services/lesson_service.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';

import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:afrilingo/features/dashboard/screens/activity.dart';
import 'package:afrilingo/features/courses/screens/courses.dart';
import 'package:afrilingo/features/chat/screens/chatbotScreenState.dart';
import 'package:afrilingo/features/language/screens/language_selection_screen.dart';
import 'package:afrilingo/features/profile/services/profile_service.dart';
import 'package:afrilingo/features/chat/screens/translating.dart';
import 'package:afrilingo/features/auth/screens/sign_in_screen.dart';

import 'dart:async';
import 'dart:math';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  bool _isLoadingProfile = false;
  String _cachedFirstName = '';
  String? _cachedEmail;
  String? _cachedProfilePicture;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  Timer? _refreshTimer;

  // Dashboard data
  Map<String, dynamic>? _dashboardData;
  int _completedLessons = 0;
  int _streak = 0;
  double _courseProgress = 0.0;
  Map<String, dynamic>? _currentCourse;

  // Services
  late ProfileService _profileService;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _initializeServices();

    // Load data in sequence to ensure profile is loaded first
    _loadDataSequentially();

    // Start the animation
    _animationController.forward();

    // Set up auto-refresh timer to update data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshData(showIndicator: false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeServices() {
    _profileService = ProfileService(
      baseUrl: 'http://10.0.2.2:8080/api/v1',
      getHeaders: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) throw Exception('No authentication token found');
        return {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      },
    );
  }

  Future<void> _loadDataSequentially() async {
    try {
      // First load directly from SharedPreferences for immediate display
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('user_first_name');
      final lastName = prefs.getString('user_last_name');
      final email = prefs.getString('user_email');
      final authType = prefs.getString('auth_type');

      if (firstName != null && firstName.isNotEmpty) {
        setState(() {
          _cachedFirstName = firstName;
          _cachedEmail = email ?? '';

          // For Google users, also check for profile picture
          if (authType == 'google') {
            _cachedProfilePicture = prefs.getString('user_photo');
          }
        });
        print("Loaded user info from SharedPreferences: $firstName $lastName");
      }

      // Then load cached data for other fields
      await _loadCachedUserInfo();

      // Then load the full profile (this will update UI when completed)
      await _loadUserProfile();

      // Then load other dashboard data
      await Future.wait([
        _loadDashboardData(),
        _loadStreakData(),
      ]);

      _logCompletedLessonsInfo();
    } catch (e) {
      print("Error in _loadDataSequentially: $e");
      // Continue with regular loading if there's an error
      await _loadCachedUserInfo();
      await _loadUserProfile();
      await Future.wait([
        _loadDashboardData(),
        _loadStreakData(),
      ]);
      _logCompletedLessonsInfo();
    }
  }

  Future<void> _loadCachedUserInfo() async {
    // Get cached user identity first for immediate UI display
    final identity = await UserCacheService.getCurrentUserIdentity();
    if (identity != null) {
      if (mounted) {
        setState(() {
          _cachedFirstName = identity.firstName;
          _cachedEmail = identity.email;
          _cachedProfilePicture = identity.profilePicture;
          _streak = identity.streak;
        });
      }
      print(
          'Dashboard: Loaded user identity - name: "${identity.firstName}", email: ${identity.email}');
    } else {
      // Fall back to individual cached fields
      final firstName = await UserCacheService.getCachedFirstName();
      final profilePicture = await UserCacheService.getCachedProfilePicture();
      final email = await UserCacheService.getCachedEmail();
      final streak = await UserCacheService.getCachedStreak();

      if (mounted) {
        setState(() {
          _cachedFirstName = firstName;
          _cachedEmail = email;
          _cachedProfilePicture = profilePicture;
          _streak = streak;
        });
      }
      print(
          'Dashboard: Loaded cached info - firstName: "$firstName", email: $email');
    }
  }

  Future<void> _loadUserProfile() async {
    if (_isLoadingProfile) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Force refresh from server - don't rely on cached data
      print('Dashboard: Refreshing user profile from server...');
      final profile =
          await _profileService.getCurrentUserProfile(forceRefresh: true);

      if (mounted) {
        setState(() {
          // Always update with latest data
          if (profile.firstName != null && profile.firstName!.isNotEmpty) {
            _cachedFirstName = profile.firstName!;
          }

          if (profile.email != null && profile.email!.isNotEmpty) {
            _cachedEmail = profile.email;
          }

          // Handle potential invalid URL in profile picture
          if (profile.profilePicture != null &&
              profile.profilePicture!.isNotEmpty) {
            try {
              // Don't use SVG URLs from DiceBear as they cause errors
              if (profile.profilePicture!.contains("dicebear") &&
                  profile.profilePicture!.contains(".svg")) {
                _cachedProfilePicture =
                    profile.profilePicture!.replaceAll(".svg", ".png");
              } else {
                final uri = Uri.parse(profile.profilePicture!);
                _cachedProfilePicture = profile.profilePicture;
              }
            } catch (e) {
              // If URL is invalid, try to fix it
              if (profile.profilePicture!.startsWith('//')) {
                _cachedProfilePicture = 'https:${profile.profilePicture}';
              } else if (!profile.profilePicture!.startsWith('http')) {
                _cachedProfilePicture = 'https://${profile.profilePicture}';
              }
            }
          }

          _profile = profile;
        });
      }

      // Also refresh the Google photo if user is authenticated with Google
      await _checkForGoogleProfilePicture();
    } catch (e) {
      print('Dashboard: Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _checkForGoogleProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authType = prefs.getString('auth_type');

      if (authType == 'google') {
        final googlePhotoUrl = prefs.getString('user_photo');
        if (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty) {
          setState(() {
            _cachedProfilePicture = googlePhotoUrl;
          });
          print(
              "Dashboard: Loaded Google profile picture: $_cachedProfilePicture");
        }
      }
    } catch (e) {
      print("Dashboard: Error loading Google profile picture: $e");
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      print('Loading dashboard data...');

      // Get dashboard data using the profile service
      final dashboardData = await _profileService.getUserDashboard();

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;

          // Extract learning stats
          if (dashboardData.containsKey('learningStats') &&
              dashboardData['learningStats'] != null) {
            final stats = dashboardData['learningStats'];

            // Get completed lessons count
            final completedLessons = stats['completedLessons'];
            if (completedLessons != null) {
              _completedLessons = completedLessons is int
                  ? completedLessons
                  : int.parse(completedLessons.toString());

              // Update local storage to keep it in sync with server
              _updateLocalCompletedLessonsCount(_completedLessons);
            }

            // Get streak
            final streak = stats['streak'];
            if (streak != null) {
              _streak = streak is int ? streak : int.parse(streak.toString());
              print('Dashboard: Loaded streak value from dashboard: $_streak');

              // Update local streak to keep it in sync with server
              _updateLocalStreak(_streak);
            }
          }

          // Get first course from recommendations or current courses
          if (dashboardData.containsKey('recommendedCourses') &&
              dashboardData['recommendedCourses'] != null &&
              (dashboardData['recommendedCourses'] as List).isNotEmpty) {
            _currentCourse = dashboardData['recommendedCourses'][0];
          } else {
            // Try to get current course from completed lessons
            if (dashboardData.containsKey('courseProgress') &&
                dashboardData['courseProgress'] != null &&
                (dashboardData['courseProgress'] as Map).isNotEmpty) {
              // Get the course with the highest progress
              var highestProgress = 0.0;
              String? highestCourseId;

              dashboardData['courseProgress'].forEach((courseId, progress) {
                final progressValue = progress is double
                    ? progress
                    : double.parse(progress.toString());
                if (progressValue > highestProgress) {
                  highestProgress = progressValue;
                  highestCourseId = courseId;
                }
              });

              if (highestCourseId != null &&
                  dashboardData.containsKey('coursesByLanguage') &&
                  dashboardData['coursesByLanguage'] != null) {
                // Try to find the course in coursesByLanguage
                Map<String, dynamic> allCourses = {};
                dashboardData['coursesByLanguage'].forEach((language, courses) {
                  (courses as List).forEach((course) {
                    allCourses[course['id'].toString()] = course;
                  });
                });

                if (allCourses.containsKey(highestCourseId)) {
                  _currentCourse = allCourses[highestCourseId];
                }
              }
            }

            // Use default course if still null
            if (_currentCourse == null) {
              _currentCourse = {
                'id': 1,
                'title': 'Basic Kinyarwanda',
                'level': 'Beginner'
              };
            }
          }

          // Get course progress
          bool foundProgress = false;
          if (_currentCourse != null &&
              dashboardData.containsKey('courseProgress') &&
              dashboardData['courseProgress'] != null) {
            final courseId = _currentCourse!['id'].toString();
            final progress = dashboardData['courseProgress'][courseId];
            if (progress != null) {
              final progressValue = progress is double
                  ? progress
                  : double.parse(progress.toString());
              _courseProgress =
                  progressValue / 100.0; // Convert to 0.0-1.0 range
              foundProgress = true;
            }
          }

          // Use default progress if we couldn't get real progress
          if (!foundProgress) {
            // Estimate course progress based on completed lessons
            _courseProgress = (_completedLessons / 10.0).clamp(0.0, 1.0);
          }
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Use local data on error
      if (mounted) {
        setState(() {
          // Try to load completed lessons count from local storage
          _getCachedCompletedLessonsCount();

          // Don't update streak here - it's handled separately

          // Set default current course
          _currentCourse = {
            'id': 1,
            'title': 'Basic Kinyarwanda',
            'level': 'Beginner'
          };
        });
      }
    }
  }

  // Update local storage completed lessons count
  Future<void> _updateLocalCompletedLessonsCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completed_lessons_count', count);
      print('Updated local completed lessons count to $count');
    } catch (e) {
      print('Error updating local completed lessons count: $e');
    }
  }

  // Update local streak value
  Future<void> _updateLocalStreak(int streak) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_streak', streak);
      await UserCacheService.cacheStreak(streak);
      print('Updated local streak to $streak');
    } catch (e) {
      print('Error updating local streak: $e');
    }
  }

  // Get completed lessons count from local storage
  Future<void> _getCachedCompletedLessonsCount() async {
    try {
      final lessonService = LessonService();
      final completedCount = await lessonService.getCompletedLessonsCount();

      if (mounted && completedCount > 0) {
        setState(() {
          _completedLessons = completedCount;

          // Estimate course progress based on completed lessons
          // Assuming a course has around 10 lessons on average
          _courseProgress = (completedCount / 10).clamp(0.0, 1.0);
        });
      }
    } catch (e) {
      print('Error getting cached completed lessons count: $e');
    }
  }

  Future<void> _loadStreakData() async {
    try {
      print('Loading streak data...');

      // First try to get streak from user identity
      final identity = await UserCacheService.getCurrentUserIdentity();
      if (identity != null && identity.streak > 0) {
        print('Loaded streak from identity: ${identity.streak}');
        if (mounted) {
          setState(() {
            _streak = identity.streak;
          });
        }
        return;
      }

      // Try to get from UserCacheService
      final cachedStreak = await UserCacheService.getCachedStreak();
      if (cachedStreak > 0) {
        print('Loaded streak from UserCacheService: $cachedStreak');
        if (mounted) {
          setState(() {
            _streak = cachedStreak;
          });
        }
        return;
      }

      // Use the dedicated streak method if identity doesn't have it
      final streak = await _profileService.getUserStreak();
      print('Loaded streak from profile service: $streak');

      if (mounted) {
        setState(() {
          _streak = streak;
        });
      }
    } catch (e) {
      print('Error loading streak data: $e');

      // Try to load streak from local storage directly
      try {
        final prefs = await SharedPreferences.getInstance();
        final localStreak = prefs.getInt('user_streak') ?? 0;
        print('Loaded streak from direct local storage: $localStreak');

        if (mounted && localStreak > 0) {
          setState(() {
            _streak = localStreak;
          });
        }
      } catch (storageError) {
        print('Error loading streak from local storage: $storageError');
      }
    }
  }

  // Debug method to log information about completed lessons
  Future<void> _logCompletedLessonsInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedLessons = prefs.getInt('completed_lessons_count') ?? 0;
      final streak = prefs.getInt('user_streak') ?? 0;
      final lastUpdate = prefs.getString('last_streak_update') ?? 'never';

      print('DEBUG: Local storage stats:');
      print('  - Completed lessons: $completedLessons');
      print('  - Streak: $streak');
      print('  - Last streak update: $lastUpdate');
    } catch (e) {
      print('Error logging completed lessons info: $e');
    }
  }

  // Pull-to-refresh functionality
  Future<void> _refreshData({bool showIndicator = true}) async {
    try {
      await _loadUserProfile();
      await _loadDashboardData();
      await _loadStreakData();
      await _logCompletedLessonsInfo();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      if (showIndicator && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data refreshed successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              color: themeProvider.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'AfriLingo',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Serif Display',
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: themeProvider.textColor,
            ),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: themeProvider.textColor,
            ),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: themeProvider.textColor,
            ),
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: RefreshIndicator(
          color: themeProvider.primaryColor,
          onRefresh: () => _refreshData(showIndicator: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User welcome card
                  _buildWelcomeCard(themeProvider),
                  const SizedBox(height: 24),

                  // Progress section
                  _buildProgressSection(themeProvider),
                  const SizedBox(height: 24),

                  // Course section
                  _buildCourseSection(themeProvider),
                  const SizedBox(height: 24),

                  // Features section
                  _buildFeaturesSection(themeProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 0),
    );
  }

  Widget _buildWelcomeCard(ThemeProvider themeProvider) {
    // Use the actual firstName that was loaded from the backend
    // Avoid hardcoding "Guest" as a fallback value
    final String displayName =
        _cachedFirstName.isEmpty ? 'User' : _cachedFirstName;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  themeProvider.primaryColor.withOpacity(0.8),
                  themeProvider.primaryColor.withOpacity(0.6),
                ]
              : [
                  themeProvider.primaryColor,
                  themeProvider.secondaryColor,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Profile circle with initial
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Welcome text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_cachedEmail != null && _cachedEmail!.isNotEmpty)
                    Text(
                      _cachedEmail!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Points display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700), // Gold color
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_dashboardData?['points'] ?? 0} Points',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
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

  Widget _buildProgressSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProgressScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: themeProvider.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress stats cards
        Row(
          children: [
            // Completed lessons card
            Expanded(
              child: _buildProgressCard(
                title: 'Completed',
                value: '$_completedLessons',
                subtitle: 'Lessons',
                icon: Icons.check_circle_outline,
                color: Colors.green.shade400,
                themeProvider: themeProvider,
              ),
            ),
            const SizedBox(width: 16),

            // Daily streak card
            Expanded(
              child: _buildProgressCard(
                title: 'Streak',
                value: '$_streak',
                subtitle: 'Days',
                icon: Icons.local_fire_department_outlined,
                color: Colors.orange.shade400,
                themeProvider: themeProvider,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Progress card widget with dark mode support and improved animations
  Widget _buildProgressCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated icon container
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: title == 'Streak'
                          ? _buildAnimatedStreakIcon(color)
                          : Icon(
                              icon,
                              color: color,
                              size: 24,
                            ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Animated value counter with updated animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 0, end: double.parse(value == '' ? '0' : value)),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.lightTextColor,
            ),
          ),
          if (title == 'Streak' && _streak > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildStreakIndicator(_streak, themeProvider),
            ),
        ],
      ),
    );
  }

  // Animated streak flame icon
  Widget _buildAnimatedStreakIcon(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            Icons.local_fire_department,
            color: color,
            size: 24,
          ),
        );
      },
      // Make the animation repeat
      onEnd: () => setState(() {}),
    );
  }

  // Visual streak indicator with better feedback
  Widget _buildStreakIndicator(int streak, ThemeProvider themeProvider) {
    final List<Widget> indicators = [];
    final int weekCount = (streak / 7).ceil();

    // Generate streak indicators
    for (int i = 0; i < min(weekCount, 7); i++) {
      final int daysInThisWeek = min(7, max(0, streak - (i * 7)));
      indicators.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'This week',
                    style: TextStyle(
                      fontSize: 10,
                      color: themeProvider.lightTextColor,
                    ),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: daysInThisWeek / 7,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  color: _getStreakColor(daysInThisWeek),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      );
      // Add spacing between indicators
      if (i < min(weekCount, 7) - 1) {
        indicators.add(const SizedBox(width: 4));
      }
    }

    return Row(children: indicators);
  }

  // Get color based on streak length
  Color _getStreakColor(int days) {
    if (days <= 2) return Colors.orange;
    if (days <= 4) return Colors.orange.shade700;
    return Colors.red;
  }

  Widget _buildCourseSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Course',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoursesScreen(),
                  ),
                );
              },
              child: Text(
                'All Courses',
                style: TextStyle(
                  color: themeProvider.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current course progress card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentCourse != null
                              ? _currentCourse!['title']
                              : 'English for Beginners',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: themeProvider.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentCourse != null
                              ? _currentCourse!['description'] ??
                                  'Continue your language learning journey'
                              : 'Continue your language learning journey',
                          style: TextStyle(
                            color: themeProvider.lightTextColor,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Progress indicator
                  const SizedBox(height: 24),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: _courseProgress),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final percentage = (value * 100).toInt();
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Show progress details when tapped
                              _showProgressDetails(context, themeProvider);
                            },
                            child: CircularPercentIndicator(
                              radius: 45,
                              lineWidth: 12.0,
                              percent: value,
                              center: Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: themeProvider.textColor,
                                ),
                              ),
                              progressColor: _getCourseProgressColor(value),
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              circularStrokeCap: CircularStrokeCap.round,
                              footer: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Course Progress',
                                      style: TextStyle(
                                        color: themeProvider.textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: themeProvider.lightTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // Continue learning button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoursesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add a small bounce animation to the icon
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(Icons.play_arrow_rounded, size: 24),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.25,
          children: [
            _buildMenuCard(
              context,
              Icons.menu_book,
              'Courses',
              'Learn structured lessons',
              themeProvider,
            ),
            _buildMenuCard(
              context,
              Icons.chat_bubble_outline,
              'Chatbot',
              'Practice conversations',
              themeProvider,
            ),
            _buildMenuCard(
              context,
              Icons.quiz_outlined,
              'Quizzes',
              'Test your knowledge',
              themeProvider,
            ),
            _buildMenuCard(
              context,
              Icons.translate,
              'Translate',
              'Instant translations',
              themeProvider,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _getDestinationScreen(title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: themeProvider.primaryColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.lightTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDestinationScreen(String title) {
    switch (title.toLowerCase()) {
      case 'courses':
        return const CoursesScreen();
      case 'chatbot':
        return const ChatbotScreen();
      case 'quizzes':
        return const ProgressScreen(); // Replace with actual quiz screen when available
      case 'translate':
        return const TranslationScreen();
      default:
        return const UserDashboard();
    }
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Completed',
                  _completedLessons > 0 ? _completedLessons.toString() : '0',
                  Icons.check_circle_outline),
              _buildStatItem('In Progress', '3', Icons.trending_up),
              _buildStatItem('Daily Streak', _streak.toString(),
                  Icons.local_fire_department),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    // For the streak, show a special animation if the streak is active
    bool isStreak = label == 'Daily Streak';

    // For streaks, determine color based on streak value
    Color iconColor = Colors.white;
    Color textColor = Colors.white;

    if (isStreak) {
      final streakValue = int.tryParse(value) ?? 0;
      if (streakValue > 0) {
        if (streakValue >= 7) {
          // Gold for 7+ day streaks
          iconColor = Colors.amber;
          textColor = Colors.amber;
        } else if (streakValue >= 3) {
          // Orange for 3+ day streaks
          iconColor = Colors.orange;
          textColor = Colors.orange;
        } else {
          // Light orange for 1-2 day streaks
          iconColor = Colors.orange.shade300;
          textColor = Colors.orange.shade300;
        }
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isStreak && (int.tryParse(value) ?? 0) > 0
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                    // Only show the animation if the streak is active
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if ((int.tryParse(value) ?? 0) >= 7)
                      // Add sparkle effect for high streaks
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                  ],
                )
              : Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // For development debugging purposes only - remove in production
  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Debug Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text('Streak: $_streak'),
          Text('Completed Lessons: $_completedLessons'),
          Text(
              'Course Progress: ${(_courseProgress * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              // Reset progress for testing
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('completed_lessons_count', 0);
              await prefs.setInt('user_streak', 1);
              _refreshData();
            },
            child: const Text('Reset Progress'),
          ),
          OutlinedButton(
            onPressed: () async {
              // Increment progress for testing
              final prefs = await SharedPreferences.getInstance();
              final current = prefs.getInt('completed_lessons_count') ?? 0;
              await prefs.setInt('completed_lessons_count', current + 1);

              final currentStreak = prefs.getInt('user_streak') ?? 0;
              await prefs.setInt('user_streak', currentStreak + 1);
              _refreshData();
            },
            child: const Text('Increment Progress'),
          ),
        ],
      ),
    );
  }

  // Add logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: themeProvider.lightTextColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.lightTextColor,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
              onPressed: () async {
                // Clear user data
                await UserCacheService.clearCache();

                // Clear SharedPreferences auth data
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                await prefs.remove('user_id');

                // Navigate to login page and clear navigation history
                if (context.mounted) {
                  // Use MaterialPageRoute instead of named route for more reliability
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          const SignInScreen(), // Import this at the top
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Get color based on course progress percentage
  Color _getCourseProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  // Show progress details in a bottom sheet
  void _showProgressDetails(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Course Progress Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Lessons:',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  Text(
                    '$_completedLessons',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Lessons:',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  Text(
                    '${_currentCourse != null ? (_currentCourse!['totalLessons'] ?? 10) : 10}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Percentage Complete:',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  Text(
                    '${(_courseProgress * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy screens for navigation
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Courses();
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProgressPage();
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: const Center(child: Text('Test Screen')),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActivityPage();
  }
}
