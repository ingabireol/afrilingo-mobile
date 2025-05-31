import 'package:afrilingo/screens/auth/notifications.dart';
import 'package:afrilingo/screens/auth/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/models/user_profile.dart';
import 'package:afrilingo/services/user_cache_service.dart';

import '../../widgets/auth/navigation_bar.dart';
import 'activity.dart';
import 'courses.dart';
import 'package:afrilingo/screens/chatbotScreenState.dart';
import '../language_selection_screen.dart';
import '../../services/profile_service.dart';
import '../../screens/translating.dart';

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

class _UserDashboardState extends State<UserDashboard> {
  UserProfile? _profile;
  bool _isLoadingProfile = false;
  String _cachedFirstName = '';
  String? _cachedEmail;
  String? _cachedProfilePicture;
  
  // Dashboard data
  Map<String, dynamic>? _dashboardData;
  int _completedLessons = 0;
  int _streak = 0;
  double _courseProgress = 0.0;
  Map<String, dynamic>? _currentCourse;

  @override
  void initState() {
    super.initState();
    _loadCachedUserInfo();
    _loadUserProfile();
    _loadDashboardData();
  }

  Future<void> _loadCachedUserInfo() async {
    // Load cached data immediately for instant UI
    final firstName = await UserCacheService.getCachedFirstName();
    final profilePicture = await UserCacheService.getCachedProfilePicture();
    final email = await UserCacheService.getCachedEmail();
    
    // Try to get name from SharedPreferences as a backup
    String displayName = firstName;
    if (displayName.isEmpty || displayName == "Buntu" || displayName == "User") {
      final prefs = await SharedPreferences.getInstance();
      final storedFirstName = prefs.getString('user_firstName');
      final storedName = prefs.getString('user_name'); // Some systems store as user_name
      final storedUsername = prefs.getString('username');
      
      if (storedFirstName != null && storedFirstName.isNotEmpty) {
        displayName = storedFirstName;
      } else if (storedName != null && storedName.isNotEmpty) {
        displayName = storedName;
      } else if (storedUsername != null && storedUsername.isNotEmpty) {
        displayName = storedUsername;
      } else if (email != null && email.isNotEmpty) {
        displayName = email.contains('@') ? email.split('@')[0] : email;
      } else {
        displayName = "Guest"; // Default to Guest instead of Buntu
      }
    }
    
    print('Dashboard: Loaded cached info - firstName: "$displayName", email: $email');
    
    if (mounted) {
      setState(() {
        // Use cached firstName if available, otherwise use default "Guest"
        _cachedFirstName = displayName.isNotEmpty ? displayName : "Guest";
        _cachedProfilePicture = profilePicture;
        _cachedEmail = email;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    if (_isLoadingProfile) return;
    
    setState(() {
      _isLoadingProfile = true;
    });
    
    try {
      final profileService = ProfileService(
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
      
      // First get the user's name from the new endpoint
      print('Dashboard: Getting user name...');
      final nameData = await profileService.getUserName();
      String displayName = nameData['firstName'] ?? '';
      
      if (displayName.isEmpty) {
        displayName = nameData['lastName'] ?? '';
      }
      
      if (displayName.isEmpty && nameData['email'] != null && nameData['email']!.isNotEmpty) {
        displayName = nameData['email']!.contains('@') 
            ? nameData['email']!.split('@')[0] 
            : nameData['email']!;
      }
      
      // If we still don't have a name, try localStorage directly
      if (displayName.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final storedFirstName = prefs.getString('user_firstName');
        final storedName = prefs.getString('user_name'); // Some systems store as user_name
        final storedEmail = prefs.getString('user_email');
        
        if (storedFirstName != null && storedFirstName.isNotEmpty) {
          displayName = storedFirstName;
        } else if (storedName != null && storedName.isNotEmpty) {
          displayName = storedName;
        } else if (storedEmail != null && storedEmail.isNotEmpty) {
          displayName = storedEmail.contains('@') 
              ? storedEmail.split('@')[0] 
              : storedEmail;
        }
      }
      
      // Last resort fallback - better than "User"
      if (displayName.isEmpty) {
        displayName = "Guest";
      }
      
      // Update state with name data
      if (mounted) {
        setState(() {
          _cachedFirstName = displayName;
          if (nameData['email'] != null && nameData['email']!.isNotEmpty) {
            _cachedEmail = nameData['email'];
          }
        });
      }
      
      // Then get the full profile for other data
      print('Dashboard: Loading user profile...');
      final profile = await profileService.getCurrentUserProfile();
      print('Dashboard: Profile loaded - firstName: ${profile.firstName}, lastName: ${profile.lastName}, email: ${profile.email}');
      
      if (mounted) {
        setState(() {
          _profile = profile;
          // Update cached values with new data
          if (profile.email != null && profile.email!.isNotEmpty) {
            _cachedEmail = profile.email;
          }
          // Handle potential invalid URL in profile picture
          if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
            try {
              final uri = Uri.parse(profile.profilePicture!);
              _cachedProfilePicture = profile.profilePicture;
            } catch (e) {
              // If URL is invalid, try to fix it
              if (profile.profilePicture!.startsWith('//')) {
                _cachedProfilePicture = 'https:${profile.profilePicture}';
              } else if (!profile.profilePicture!.startsWith('http')) {
                _cachedProfilePicture = 'https://${profile.profilePicture}';
              }
            }
          }
          _isLoadingProfile = false;
        });
        
        // Save to cache for faster loading next time
        await UserCacheService.cacheUserProfile(profile);
        
        // Also cache individual fields for quicker access
        if (profile.email != null && profile.email!.isNotEmpty) {
          await UserCacheService.cacheEmail(profile.email!);
        }
        
        if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
          // Use the potentially fixed profile picture URL
          await UserCacheService.cacheProfilePicture(_cachedProfilePicture ?? profile.profilePicture!);
        }
      }
    } catch (e) {
      print("Error in _loadUserProfile: $e");
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          
          // Make sure we have some name to display
          if (_cachedFirstName.isEmpty) {
            _cachedFirstName = "Guest";
          }
        });
      }
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      print('Loading dashboard data...');
      final profileService = ProfileService(
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
      
      // Get dashboard data using the profile service
      final dashboardData = await profileService.getUserDashboard();
      
      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          
          // Extract learning stats
          if (dashboardData.containsKey('learningStats') && dashboardData['learningStats'] != null) {
            final stats = dashboardData['learningStats'];
            _completedLessons = stats['completedLessons'] ?? 0;
            _streak = stats['streak'] ?? 0;
          } else {
            // Use default values
            _completedLessons = 3;
            _streak = 5;
          }
          
          // Get first course from recommendations or current courses
          if (dashboardData.containsKey('recommendedCourses') && 
              dashboardData['recommendedCourses'] != null &&
              (dashboardData['recommendedCourses'] as List).isNotEmpty) {
            _currentCourse = dashboardData['recommendedCourses'][0];
          } else {
            // Use default course
            _currentCourse = {
              'id': 1,
              'title': 'Basic Kinyarwanda',
              'level': 'Beginner'
            };
          }
          
          // Get course progress
          bool foundProgress = false;
          if (_currentCourse != null && 
              dashboardData.containsKey('courseProgress') && 
              dashboardData['courseProgress'] != null) {
            final courseId = _currentCourse!['id'].toString();
            final progress = dashboardData['courseProgress'][courseId];
            if (progress != null) {
              _courseProgress = progress / 100.0; // Convert to 0.0-1.0 range
              foundProgress = true;
            }
          }
          
          // Use default progress if we couldn't get real progress
          if (!foundProgress) {
            _courseProgress = 0.3; // 30% progress
          }
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Use default values
      if (mounted) {
        setState(() {
          _completedLessons = 3;
          _streak = 5;
          _courseProgress = 0.3;
          _currentCourse = {
            'id': 1,
            'title': 'Basic Kinyarwanda',
            'level': 'Beginner'
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Afrilingo',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: kTextColor, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _buildProfileContent(context),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 0),
    );
  }

  // Helper method to get a valid image URL
  String? _getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Check if the URL is valid
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme) {
        // Add https scheme if missing
        return 'https://${url.startsWith('//') ? url.substring(2) : url}';
      }
      return url;
    } catch (e) {
      print('Invalid image URL: $url - $e');
      return null;
    }
  }

  Widget _buildHeader(BuildContext context) {
    // Never show "Set up your profile" if we have a name
    String displayText = _cachedFirstName.isNotEmpty && _cachedFirstName != "Buntu"
        ? _cachedFirstName 
        : "Guest"; // Default to "Guest" instead of "User" or "Buntu"
    
    print('Dashboard: Building header with name: $displayText');
    
    // Get a valid profile image URL
    String? validProfilePicture = _getValidImageUrl(_cachedProfilePicture);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: _isLoadingProfile && validProfilePicture == null
                ? const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: validProfilePicture != null
                        ? NetworkImage(validProfilePicture)
                        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
            style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 20,
              fontWeight: FontWeight.bold,
                    color: Colors.white,
          ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                const Text(
                  '1,240',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Points',
                  style: TextStyle(
                    color: kTextColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      color: kPrimaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context),
              const SizedBox(height: 32),
              
              // Progress Section
              _buildProgressSection(),
              const SizedBox(height: 32),
              
              // Menu Grid
              _buildMenuGrid(context),
              const SizedBox(height: 32),
              
              // Stats Section
              _buildStatsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgressScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: kAccentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Course',
                        style: TextStyle(
                          color: kLightTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentCourse != null ? 
                            _currentCourse!['title'] : 'Basic Kinyarwanda',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, 
                            color: kSecondaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Continue Learning',
                            style: TextStyle(
                              color: kSecondaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: _courseProgress > 0 ? _courseProgress : 0.3,
                    center: Text(
                      "${((_courseProgress > 0 ? _courseProgress : 0.3) * 100).round()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    progressColor: kPrimaryColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _courseProgress > 0 ? _courseProgress : 0.3,
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _completedLessons > 0 ? 
                        '$_completedLessons Lessons Completed' : 
                        '3/10 Lessons Completed',
                    style: const TextStyle(
                      color: kLightTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    '7 Left',
                    style: TextStyle(
                      color: kLightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextColor,
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
            _buildMenuCard(context, Icons.menu_book, 'Courses', 'Learn structured lessons'),
            _buildMenuCard(context, Icons.chat_bubble_outline, 'Chatbot', 'Practice conversations'),
            _buildMenuCard(context, Icons.quiz_outlined, 'Quizzes', 'Test your knowledge'),
            _buildMenuCard(context, Icons.translate, 'Translate', 'Instant translations'),
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
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _getDestinationScreen(title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                icon,
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: kTextColor.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
        return const ProgressScreen(); // Replace with actual quiz screen
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
              _buildStatItem('Completed', 
                  _completedLessons > 0 ? _completedLessons.toString() : '12', 
                  Icons.check_circle_outline),
              _buildStatItem('In Progress', '3', Icons.trending_up),
              _buildStatItem('Daily Streak', 
                  _streak > 0 ? _streak.toString() : '7', 
                  Icons.local_fire_department),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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