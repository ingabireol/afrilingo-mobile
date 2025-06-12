import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afrilingo/features/profile/user_profile.dart';
import 'package:afrilingo/core/services/user_cache_service.dart';
import 'package:afrilingo/features/profile/services/profile_service.dart';
import 'package:afrilingo/utils/profile_image_helper.dart';
import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/auth/screens/sign_in_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

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
  String? _cachedProfilePicture;

  // Learning time data
  Map<String, int> _learningTime = {
    'today': 0,
    'week': 0,
    'month': 0,
    'total': 0,
  };
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCachedProfile();
    _loadCachedProfilePicture();
    _fetchProfile();
    _loadLearningTimeData();

    // Set up auto-refresh timer to update data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadLearningTimeData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Load learning time data from SharedPreferences
  Future<void> _loadLearningTimeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get user ID for user-specific time tracking
      final userId = await UserCacheService.getCachedUserId();
      final userIdStr = userId != null ? userId.toString() : 'default';

      // Use the same key prefix as in dashboard
      const String timeTrackingKey = 'app_learning_time';

      if (mounted) {
        setState(() {
          _learningTime = {
            'today': prefs.getInt('${timeTrackingKey}_today_$userIdStr') ?? 0,
            'week': prefs.getInt('${timeTrackingKey}_week_$userIdStr') ?? 0,
            'month': prefs.getInt('${timeTrackingKey}_month_$userIdStr') ?? 0,
            'total': prefs.getInt('${timeTrackingKey}_total_$userIdStr') ?? 0,
          };
        });
      }
    } catch (e) {
      print('Error loading learning time data: $e');
    }
  }

  // Format seconds into readable time
  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else if (seconds < 3600) {
      return '${(seconds / 60).floor()} min';
    } else if (seconds < 86400) {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).floor();
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}';
    } else {
      final days = (seconds / 86400).floor();
      final hours = ((seconds % 86400) / 3600).floor();
      return '$days d ${hours > 0 ? '$hours h' : ''}';
    }
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

  Future<void> _loadCachedProfilePicture() async {
    try {
      // Try to get from SharedPreferences first (for Google accounts)
      final prefs = await SharedPreferences.getInstance();
      final profilePic = prefs.getString('user_photo');

      if (profilePic != null && profilePic.isNotEmpty) {
        setState(() {
          _cachedProfilePicture = profilePic;
        });
        print(
            'Loaded profile picture from SharedPreferences: ${profilePic.substring(0, 30)}...');
      }

      // Also try from UserCacheService
      final cachedPic = await UserCacheService.getCachedProfilePicture();
      if (cachedPic != null && cachedPic.isNotEmpty) {
        setState(() {
          _cachedProfilePicture = cachedPic;
        });
        print(
            'Loaded profile picture from UserCacheService: ${cachedPic.substring(0, 30)}...');
      }

      if (_cachedProfilePicture == null || _cachedProfilePicture!.isEmpty) {
        print('No cached profile picture found');
      }
    } catch (e) {
      print('Error loading cached profile picture: $e');
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
    // Show a dialog to choose between camera, gallery, or generated avatar
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return SimpleDialog(
          title: Text('Choose profile picture'),
          backgroundColor: themeProvider.cardColor,
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'camera'),
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: themeProvider.primaryColor),
                  const SizedBox(width: 8),
                  Text('Take a photo',
                      style: TextStyle(color: themeProvider.textColor)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'gallery'),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: themeProvider.primaryColor),
                  const SizedBox(width: 8),
                  Text('Select from gallery',
                      style: TextStyle(color: themeProvider.textColor)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'avatar'),
              child: Row(
                children: [
                  Icon(Icons.account_circle, color: themeProvider.primaryColor),
                  const SizedBox(width: 8),
                  Text('Generate an avatar',
                      style: TextStyle(color: themeProvider.textColor)),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String profilePictureUrl;

      if (choice == 'avatar') {
        // Generate an avatar using UI Avatars API
        final firstName = _firstNameController.text.isNotEmpty
            ? _firstNameController.text
            : 'User';
        final lastName =
            _lastNameController.text.isNotEmpty ? _lastNameController.text : '';
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // Add timestamp to ensure unique URL
        profilePictureUrl =
            "https://ui-avatars.com/api/?name=$firstName+$lastName&background=random&color=fff&size=200&t=$timestamp";
      } else {
        // Choose from gallery or camera
        final source =
            choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
        final pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 600,
          maxHeight: 600,
          imageQuality: 85,
        );

        if (pickedFile == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Read the image file as bytes and convert to base64
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Create base64 data URI
        profilePictureUrl = 'data:image/jpeg;base64,$base64Image';
      }

      // Create a profileService
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

      // Cache profile picture locally first for immediate feedback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo', profilePictureUrl);
      await UserCacheService.cacheProfilePicture(profilePictureUrl);

      // Update the local state with the new image
      setState(() {
        _cachedProfilePicture = profilePictureUrl;
        if (_profile != null) {
          _profile = UserProfile(
            id: _profile!.id,
            firstName: _profile!.firstName,
            lastName: _profile!.lastName,
            email: _profile!.email,
            country: _profile!.country,
            firstLanguage: _profile!.firstLanguage,
            profilePicture: profilePictureUrl,
            reasonToLearn: _profile!.reasonToLearn,
            languagesToLearn: _profile!.languagesToLearn,
            dailyReminders: _profile!.dailyReminders,
            dailyGoalMinutes: _profile!.dailyGoalMinutes,
            preferredLearningTime: _profile!.preferredLearningTime,
          );
        }
      });

      // Upload the URL to the server
      await profileService.updateProfilePicture(profilePictureUrl);

      // Force clear any image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
            _buildProfileHeader(themeProvider),

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

                  // Learning Time Section
                  _buildLearningTimeSection(themeProvider),

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

  Widget _buildProfileHeader(ThemeProvider themeProvider) {
    // Get profile picture URL or fallback
    String? profilePictureUrl;
    if (_profile != null &&
        _profile!.profilePicture != null &&
        _profile!.profilePicture!.isNotEmpty) {
      profilePictureUrl = _profile!.profilePicture;
      print(
          'Using profile picture from profile: ${profilePictureUrl!.substring(0, math.min(30, profilePictureUrl.length))}...');
    } else if (_cachedProfilePicture != null &&
        _cachedProfilePicture!.isNotEmpty) {
      // Try to get from cache
      profilePictureUrl = _cachedProfilePicture;
      print(
          'Using cached profile picture: ${profilePictureUrl!.substring(0, math.min(30, profilePictureUrl.length))}...');
    } else {
      // Generate a default avatar as fallback
      final firstName = _firstNameController.text.isNotEmpty
          ? _firstNameController.text
          : 'User';
      final lastName =
          _lastNameController.text.isNotEmpty ? _lastNameController.text : '';
      profilePictureUrl =
          "https://ui-avatars.com/api/?name=$firstName+$lastName&background=random&color=fff&size=200";
      print('Using generated avatar as fallback');
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: themeProvider.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            // Profile picture with tap handler to change it
            GestureDetector(
              onTap: _isLoading ? null : _changeProfilePicture,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? ProfileImageHelper.buildProfileAvatar(
                            imageUrl: null,
                            radius: 60,
                            showLoading: true,
                          )
                        : Hero(
                            tag: 'profilePicture',
                            child: ProfileImageHelper.buildProfileAvatar(
                              imageUrl: profilePictureUrl,
                              radius: 60,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              iconColor: Colors.white,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _firstNameController.text + ' ' + _lastNameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _usernameController.text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
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

  Widget _buildLearningTimeSection(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: themeProvider.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learning Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  Icon(
                    Icons.timer,
                    color: themeProvider.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Today's learning time
              _buildLearningTimeRow(
                'Today',
                _formatTime(_learningTime['today'] ?? 0),
                (_learningTime['today'] ?? 0) / 3600,
                themeProvider,
              ),
              const SizedBox(height: 16),

              // This week's learning time
              _buildLearningTimeRow(
                'This Week',
                _formatTime(_learningTime['week'] ?? 0),
                (_learningTime['week'] ?? 0) / 21600,
                themeProvider,
              ),
              const SizedBox(height: 16),

              // This month's learning time
              _buildLearningTimeRow(
                'This Month',
                _formatTime(_learningTime['month'] ?? 0),
                (_learningTime['month'] ?? 0) / 86400,
                themeProvider,
              ),
              const SizedBox(height: 16),

              // Total learning time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Learning Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  Text(
                    _formatTime(_learningTime['total'] ?? 0),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Keep learning consistently to improve your language skills!',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: themeProvider.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningTimeRow(String label, String value, double progress,
      ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0), // Ensure value is between 0 and 1
          backgroundColor: themeProvider.dividerColor,
          color: themeProvider.primaryColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
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
