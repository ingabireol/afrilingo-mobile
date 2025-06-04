import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/models/user_profile.dart';
import 'package:afrilingo/services/user_cache_service.dart';
import 'package:afrilingo/services/profile_service.dart';
import 'package:afrilingo/utils/profile_image_helper.dart';
import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/services/theme_provider.dart';
import 'package:afrilingo/screens/auth/sign_in_screen.dart';

// Keep these as fallback colors
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstLanguageController =
      TextEditingController();
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadCachedProfile();
    _fetchProfile();
  }

  Future<void> _loadCachedProfile() async {
    final cachedProfile = await UserCacheService.getCachedUserProfile();
    if (cachedProfile != null && mounted) {
      setState(() {
        _profile = cachedProfile;
        _firstNameController.text = cachedProfile.firstName ?? '';
        _lastNameController.text = cachedProfile.lastName ?? '';
        _usernameController.text = cachedProfile.email ?? '';
        _firstLanguageController.text = cachedProfile.firstLanguage ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;

    setState(() {
      if (_profile == null) _isLoading = true;
      _error = null;
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

      // First get the user's name
      print('Profile: Getting user name...');
      final nameData = await profileService.getUserName();
      if (mounted) {
        setState(() {
          _firstNameController.text = nameData['firstName'] ?? '';
          _lastNameController.text = nameData['lastName'] ?? '';
          _usernameController.text = nameData['email'] ?? '';
        });
      }

      // Then get the full profile for other data
      print('Profile: Loading full profile...');
      final profile = await profileService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _firstLanguageController.text = profile.firstLanguage ?? '';
          _isLoading = false;
        });

        // Update cache
        await UserCacheService.cacheUserProfile(profile);

        // Also cache individual fields for quicker access
        if (nameData['firstName'] != null) {
          await UserCacheService.cacheFirstName(nameData['firstName']!);
        }
        if (nameData['email'] != null) {
          await UserCacheService.cacheEmail(nameData['email']!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      // TODO: Replace with real upload logic
      String newProfilePictureUrl = await uploadImageAndGetUrl(pickedFile.path);
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
      await profileService.updateProfilePicture(newProfilePictureUrl);
      await _fetchProfile();
    }
  }

  Future<String> uploadImageAndGetUrl(String path) async {
    // TODO: Implement real upload logic (to backend or storage)
    // For now, just return a placeholder URL
    return 'https://via.placeholder.com/150';
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;
    setState(() {
      _isSavingProfile = true;
    });
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

    try {
      await profileService.createOrUpdateUserProfile({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _usernameController.text,
        'firstLanguage': _firstLanguageController.text,
        // Add other fields as needed
      });
      await _fetchProfile();

      // Update the cache with the updated information
      if (_profile != null) {
        if (_firstNameController.text.isNotEmpty) {
          await UserCacheService.cacheFirstName(_firstNameController.text);
        }
        if (_usernameController.text.isNotEmpty) {
          await UserCacheService.cacheEmail(_usernameController.text);
        }

        // Also cache entire profile to ensure consistency
        UserProfile updatedProfile = UserProfile(
          id: _profile!.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _usernameController.text,
          firstLanguage: _firstLanguageController.text,
          profilePicture: _profile!.profilePicture,
          country: _profile!.country,
          reasonToLearn: _profile!.reasonToLearn,
          dailyReminders: _profile!.dailyReminders,
          dailyGoalMinutes: _profile!.dailyGoalMinutes,
          preferredLearningTime: _profile!.preferredLearningTime,
          languagesToLearn: _profile!.languagesToLearn,
        );

        await UserCacheService.cacheUserProfile(updatedProfile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSavingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
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
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: themeProvider.primaryColor))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _buildProfileContent(context),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 4),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final profile = _profile!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return RefreshIndicator(
      onRefresh: _fetchProfile,
      color: themeProvider.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile header with avatar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeProvider.isDarkMode
                      ? [
                          themeProvider.primaryColor.withOpacity(0.8),
                          themeProvider.secondaryColor.withOpacity(0.6)
                        ]
                      : [
                          themeProvider.primaryColor,
                          themeProvider.secondaryColor
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ProfileImageHelper.buildProfileAvatar(
                          imageUrl: profile.profilePicture,
                          radius: 60,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: themeProvider.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // Show full name from text controllers for consistency
                    '${_firstNameController.text} ${_lastNameController.text}'
                        .trim(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Show email or alternative text if not available
                  Text(
                    _usernameController.text.isNotEmpty
                        ? _usernameController.text
                        : 'No email provided',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Information Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Learning Progress Card
                  _buildProgressCard(),

                  const SizedBox(height: 24),

                  // Personal Information Card
                  _buildPersonalInfoCard(),

                  const SizedBox(height: 24),

                  // Achievements Card
                  _buildAchievementsCard(profile),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSavingProfile ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        disabledBackgroundColor:
                            themeProvider.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isSavingProfile
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: ProfileService(
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
      ).getUserDashboard(),
      builder: (context, snapshot) {
        // Default values
        int completedLessons = 0;
        double progress = 0.0;

        // Extract values from dashboard data if available
        if (snapshot.hasData) {
          final dashboardData = snapshot.data!;
          if (dashboardData.containsKey('learningStats') &&
              dashboardData['learningStats'] != null) {
            completedLessons =
                dashboardData['learningStats']['completedLessons'] ?? 0;
          }

          if (dashboardData.containsKey('courseProgress') &&
              dashboardData['courseProgress'] != null &&
              dashboardData['courseProgress'].isNotEmpty) {
            // Get first course progress
            progress = dashboardData['courseProgress'].values.first / 100.0;
          }
        }

        return Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: themeProvider.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Learning Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: themeProvider.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.primaryColor),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.auto_stories,
                        color: themeProvider.secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'You completed $completedLessons ${completedLessons == 1 ? 'Chapter' : 'Chapters'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.lightTextColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Navigate to progress details
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: themeProvider.accentColor,
                      ),
                      child: const Text('Details'),
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

  Widget _buildPersonalInfoCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: themeProvider.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 20),

            // Username (Email) - Read-only
            Text(
              'Username/Email',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: themeProvider.lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? Colors.black12
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.lock_outline,
                    color: themeProvider.lightTextColor),
              ),
              style: TextStyle(color: themeProvider.textColor),
            ),
            const SizedBox(height: 16),

            // First Name
            Text(
              'First Name',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: themeProvider.lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? themeProvider.surfaceColor
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeProvider.dividerColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your first name',
              ),
              style: TextStyle(color: themeProvider.textColor),
            ),
            const SizedBox(height: 16),

            // Last Name
            Text(
              'Last Name',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: themeProvider.lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? themeProvider.surfaceColor
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeProvider.dividerColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your last name',
              ),
              style: TextStyle(color: themeProvider.textColor),
            ),
            const SizedBox(height: 16),

            // First Language
            Text(
              'First Language',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: themeProvider.lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstLanguageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? themeProvider.surfaceColor
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeProvider.dividerColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your first language',
              ),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(UserProfile profile) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<int>(
      future: ProfileService(
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
      ).getUserStreak(),
      builder: (context, snapshot) {
        // Default value
        int streak = 0;

        // Use streak from API if available
        if (snapshot.hasData) {
          streak = snapshot.data!;
        }

        return Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: themeProvider.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Streaks
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Streak',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: themeProvider.lightTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$streak ${streak == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: themeProvider.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: themeProvider.dividerColor),
                const SizedBox(height: 16),

                // Points
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Points',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: themeProvider.lightTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Map<String, dynamic>>(
                          future: ProfileService(
                            baseUrl: 'http://10.0.2.2:8080/api/v1',
                            getHeaders: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('auth_token');
                              if (token == null)
                                throw Exception(
                                    'No authentication token found');
                              return {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                              };
                            },
                          ).getUserDashboard(),
                          builder: (context, snapshot) {
                            // Default value
                            int points = 0;

                            // Extract points from dashboard if available
                            if (snapshot.hasData) {
                              final dashboardData = snapshot.data!;
                              if (dashboardData.containsKey('learningStats') &&
                                  dashboardData['learningStats'] != null) {
                                // Try to get points or calculate from other stats
                                points = dashboardData['learningStats']
                                        ['totalPoints'] ??
                                    (dashboardData['learningStats']
                                                    ['completedLessons'] ??
                                                0) *
                                            100 +
                                        (dashboardData['learningStats']
                                                    ['streak'] ??
                                                0) *
                                            50;
                              }
                            }

                            return Text(
                              '$points points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: themeProvider.textColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        // View all achievements
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: themeProvider.accentColor,
                      ),
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

  // Add a method to show logout confirmation dialog
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
}
