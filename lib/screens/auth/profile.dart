import 'package:flutter/material.dart';
import 'package:afrilingo/services/profile_service.dart';
import 'package:afrilingo/models/user_profile.dart';
import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afrilingo/services/user_cache_service.dart';

// African-inspired color palette
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
  final TextEditingController _firstLanguageController = TextEditingController();
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
      final profile = await profileService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _firstNameController.text = profile.firstName ?? '';
          _lastNameController.text = profile.lastName ?? '';
          _usernameController.text = profile.email ?? '';
          _firstLanguageController.text = profile.firstLanguage ?? '';
          _isLoading = false;
        });
        // Update cache
        await UserCacheService.cacheUserProfile(profile);
        
        // Also cache these fields individually for quicker access
        if (profile.firstName != null) {
          await UserCacheService.cacheFirstName(profile.firstName!);
        }
        if (profile.email != null) {
          await UserCacheService.cacheEmail(profile.email!);
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
    setState(() { _isSavingProfile = true; });
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
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: kPrimaryColor,
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
      setState(() { _isSavingProfile = false; });
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
          'My Profile',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                            backgroundColor: kPrimaryColor,
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
    return RefreshIndicator(
      onRefresh: _fetchProfile,
      color: kPrimaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile header with avatar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
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
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: profile.profilePicture != null && profile.profilePicture!.isNotEmpty
                              ? NetworkImage(profile.profilePicture!)
                              : const AssetImage('assets/images/profile.jpg') as ImageProvider,
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
                              decoration: const BoxDecoration(
                                color: kAccentColor,
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
                    // Show full name if available
                    '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
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
                        backgroundColor: kPrimaryColor,
                        disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
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
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
                  ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                  'Learning Progress',
                            style: TextStyle(
                    fontSize: 18,
                              fontWeight: FontWeight.bold,
                    color: kTextColor,
                            ),
                          ),
                          Text(
                            '50%',
                            style: TextStyle(
                    fontSize: 18,
                              fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.auto_stories, color: kSecondaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                        'You completed 3 Chapters',
                  style: TextStyle(
                    fontSize: 14,
                    color: kLightTextColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to progress details
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kAccentColor,
                  ),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
                  ),
      child: Padding(
        padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
              'Personal Information',
                        style: TextStyle(
                fontSize: 18,
                          fontWeight: FontWeight.bold,
                color: kTextColor,
                        ),
                      ),
            const SizedBox(height: 20),

            // Username (Email) - Read-only
            const Text(
              'Username/Email',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: kLightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: const Icon(Icons.lock_outline, color: kLightTextColor),
              ),
            ),
            const SizedBox(height: 16),
            
            // First Name
                                const Text(
              'First Name',
                                  style: TextStyle(
                fontWeight: FontWeight.w500,
                color: kLightTextColor,
                                    fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your first name',
              ),
            ),
            const SizedBox(height: 16),
            
            // Last Name
            const Text(
              'Last Name',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: kLightTextColor,
                fontSize: 14,
                            ),
                        ),
                      const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your last name',
              ),
            ),
            const SizedBox(height: 16),
            
            // First Language
                                const Text(
              'First Language',
                                  style: TextStyle(
                fontWeight: FontWeight.w500,
                color: kLightTextColor,
                                    fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstLanguageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Enter your first language',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAchievementsCard(UserProfile profile) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
                  ),
      child: Padding(
        padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
              'Achievements',
                        style: TextStyle(
                fontSize: 18,
                          fontWeight: FontWeight.bold,
                color: kTextColor,
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
                const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text(
                      'Daily Streak',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: kLightTextColor,
                        ),
                      ),
                            SizedBox(height: 4),
                    Text(
                      '3 days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
              ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: kDividerColor),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Points',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: kLightTextColor,
        ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1,240 points',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                    foregroundColor: kAccentColor,
                  ),
                ),
              ],
          ),
        ],
        ),
      ),
    );
  }
}