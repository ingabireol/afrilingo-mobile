import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:afrilingo/features/profile/services/profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import '../../dashboard/screens/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isNewUser;

  const ProfileSetupScreen({
    Key? key,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  // Controllers for animations
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  // Controllers for form inputs
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _firstLanguageController =
      TextEditingController();

  // Current step in the setup process
  int _currentStep = 0;

  // Options for the dropdowns
  List<String> _countries = [];
  List<String> _languages = [];
  List<String> _reasonsToLearn = [];
  List<Map<String, dynamic>> _languagesToLearn = [];
  List<int> _dailyGoalOptions = [5, 10, 15, 20, 30, 45, 60];
  List<String> _preferredTimes = [];

  // Selected values
  String? _selectedCountry;
  String? _selectedFirstLanguage;
  String? _selectedReasonToLearn;
  List<int> _selectedLanguagesToLearn = [];
  int _selectedDailyGoal = 15;
  String? _selectedPreferredTime;
  bool _enableDailyReminders = true;
  String? _profilePictureUrl;
  File? _profileImageFile;

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Profile Service
  late ProfileService _profileService;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
    );

    _initializeServices();
    _loadProfileSetupOptions();
    _checkForGoogleProfilePicture();
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

  Future<void> _checkForGoogleProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authType = prefs.getString('auth_type');

      if (authType == 'google') {
        // Load Google user info
        final googlePhotoUrl = prefs.getString('user_photo');
        final firstName = prefs.getString('user_first_name');
        final lastName = prefs.getString('user_last_name');

        if (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty) {
          setState(() {
            _profilePictureUrl = googlePhotoUrl;
          });
          print("Loaded Google profile picture: $_profilePictureUrl");
        }

        // Pre-select country if available from Google profile
        if (firstName != null && firstName.isNotEmpty) {
          _countryController.text = firstName;
        }

        // Pre-select language if available from Google profile
        if (lastName != null && lastName.isNotEmpty) {
          _firstLanguageController.text = lastName;
        }
      } else if (authType == 'email') {
        // Load regular user info
        final firstName = prefs.getString('user_first_name');
        final lastName = prefs.getString('user_last_name');

        if (firstName != null && firstName.isNotEmpty) {
          _countryController.text = firstName;
        }

        if (lastName != null && lastName.isNotEmpty) {
          _firstLanguageController.text = lastName;
        }
      }
    } catch (e) {
      print("Error loading Google profile picture: $e");
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImageFile = File(image.path);
          // For now, just use the local file path - we'll upload it later when saving
          _profilePictureUrl = null; // Clear the URL as we're using a file now
        });
        print("Image selected: ${image.path}");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadProfileSetupOptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the profile setup options from the backend
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile-setup/options'),
        headers: await _profileService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final options = data['data'] as Map<String, dynamic>;

        setState(() {
          _countries = List<String>.from(options['countries'] ?? []);
          _languages = List<String>.from(options['commonLanguages'] ?? []);
          _reasonsToLearn = List<String>.from(options['learningReasons'] ?? []);
          _languagesToLearn = List<Map<String, dynamic>>.from(
            (options['availableLanguages'] ?? []).map((lang) => {
                  'id': lang['id'],
                  'name': lang['name'],
                  'code': lang['code'],
                }),
          );
          _preferredTimes =
              List<String>.from(options['preferredLearningTimes'] ?? []);

          if (options['dailyGoalOptions'] != null) {
            _dailyGoalOptions = List<int>.from(options['dailyGoalOptions']);
          }

          _isLoading = false;
        });

        // Start the animation
        _pageController.forward();
      } else {
        // Handle error
        print('Failed to load profile setup options: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });

        // Use default values
        setState(() {
          _countries = [
            'United States',
            'Canada',
            'United Kingdom',
            'Australia',
            'Other'
          ];
          _languages = ['English', 'French', 'Spanish', 'Portuguese', 'Other'];
          _reasonsToLearn = [
            'Travel',
            'Business',
            'Cultural Interest',
            'Education',
            'Other'
          ];
          _languagesToLearn = [
            {'id': 1, 'name': 'Swahili', 'code': 'sw'},
            {'id': 2, 'name': 'Yoruba', 'code': 'yo'},
            {'id': 3, 'name': 'Igbo', 'code': 'ig'},
            {'id': 4, 'name': 'Hausa', 'code': 'ha'},
            {'id': 5, 'name': 'Amharic', 'code': 'am'},
          ];
          _preferredTimes = [
            'Morning (6AM-12PM)',
            'Afternoon (12PM-5PM)',
            'Evening (5PM-10PM)',
            'Night (10PM-6AM)',
          ];
        });
      }
    } catch (e) {
      print('Error loading profile setup options: $e');
      setState(() {
        _isLoading = false;

        // Use default values
        _countries = [
          'United States',
          'Canada',
          'United Kingdom',
          'Australia',
          'Other'
        ];
        _languages = ['English', 'French', 'Spanish', 'Portuguese', 'Other'];
        _reasonsToLearn = [
          'Travel',
          'Business',
          'Cultural Interest',
          'Education',
          'Other'
        ];
        _languagesToLearn = [
          {'id': 1, 'name': 'Swahili', 'code': 'sw'},
          {'id': 2, 'name': 'Yoruba', 'code': 'yo'},
          {'id': 3, 'name': 'Igbo', 'code': 'ig'},
          {'id': 4, 'name': 'Hausa', 'code': 'ha'},
          {'id': 5, 'name': 'Amharic', 'code': 'am'},
        ];
        _preferredTimes = [
          'Morning (6AM-12PM)',
          'Afternoon (12PM-5PM)',
          'Evening (5PM-10PM)',
          'Night (10PM-6AM)',
        ];
      });
    }
  }

  Future<void> _saveUserProfile() async {
    if (_selectedLanguagesToLearn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one language to learn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // If there's a profile image file, upload it first
      String? finalProfilePictureUrl = _profilePictureUrl;
      if (_profileImageFile != null) {
        finalProfilePictureUrl = await _uploadProfileImage(_profileImageFile!);
        if (finalProfilePictureUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Failed to upload profile picture. Try again or skip for now.'),
                backgroundColor: Colors.orange,
              ),
            );
            // Continue with profile creation even if image upload fails
          }
        }
      }

      // Prepare the profile data
      final Map<String, dynamic> profileData = {
        'country': _selectedCountry,
        'firstLanguage': _selectedFirstLanguage,
        'reasonToLearn': _selectedReasonToLearn,
        'languagesToLearnIds': _selectedLanguagesToLearn,
        'dailyReminders': _enableDailyReminders,
        'dailyGoalMinutes': _selectedDailyGoal,
        'preferredLearningTime': _selectedPreferredTime,
        'profilePicture': finalProfilePictureUrl,
      };

      print("Saving profile with data: $profileData");

      // Send the profile data to the backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile'),
        headers: await _profileService.getHeaders(),
        body: json.encode(profileData),
      );

      print(
          "Profile creation response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Profile created successfully
        if (mounted) {
          // Navigate to the user dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const UserDashboard(),
            ),
            (route) => false,
          );
        }
      } else {
        // Handle error
        print('Failed to save profile: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Method to upload profile image to a service and get back a URL
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      // Read the image as bytes
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      print("Uploading profile image, size: ${base64Image.length} bytes");

      // Set up proper headers with auth token
      final headers = await _profileService.getHeaders();

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile/picture'),
        headers: headers,
        body: json.encode(base64Image), // Send the base64 string directly
      );

      print(
          "Profile picture upload response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the profile picture URL from the response
        if (data['data'] != null && data['data']['profilePicture'] != null) {
          final pictureUrl = data['data']['profilePicture'];
          print("Profile picture uploaded successfully: $pictureUrl");

          // Cache the profile picture URL
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile_picture', pictureUrl);

          return pictureUrl;
        }
      } else {
        print(
            "Failed to upload profile picture. Status: ${response.statusCode}, Body: ${response.body}");
      }

      // If we can't get a URL, try a fallback approach - generate a name-based avatar
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('user_first_name') ?? 'User';
      final lastName = prefs.getString('user_last_name') ?? '';
      final fullName = '$firstName $lastName'.trim();

      // Create a UI Avatars URL based on the user's name
      return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&size=200&background=random';
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countryController.dispose();
    _firstLanguageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step
    if (_currentStep == 0) {
      if (_selectedCountry == null || _selectedFirstLanguage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedReasonToLearn == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a reason to learn'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_selectedLanguagesToLearn.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one language to learn'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (_selectedPreferredTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a preferred learning time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_currentStep < 4) {
      // Reset animation and go to next step
      _pageController.reset();
      setState(() {
        _currentStep++;
      });
      _pageController.forward();
    } else {
      // Save the profile
      _saveUserProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      // Reset animation and go to previous step
      _pageController.reset();
      setState(() {
        _currentStep--;
      });
      _pageController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: themeProvider.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Set Up Your Profile',
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: themeProvider.dividerColor,
              color: themeProvider.primaryColor,
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _currentStep
                          ? themeProvider.primaryColor
                          : themeProvider.dividerColor,
                    ),
                  );
                }),
              ),
            ),

            // Content
            Expanded(
              child: AnimatedBuilder(
                animation: _pageAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _pageAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(_pageAnimation),
                      child: _buildCurrentStep(themeProvider),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      style: TextButton.styleFrom(
                        foregroundColor: themeProvider.primaryColor,
                      ),
                      child: const Text('Back'),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentStep < 4 ? 'Next' : 'Finish',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildCurrentStep(ThemeProvider themeProvider) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(themeProvider);
      case 1:
        return _buildLearningReasonStep(themeProvider);
      case 2:
        return _buildLanguageSelectionStep(themeProvider);
      case 3:
        return _buildLearningPreferencesStep(themeProvider);
      case 4:
        return _buildProfilePictureStep(themeProvider);
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This information helps us personalize your learning experience',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Country dropdown
          Text(
            'Country',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.dividerColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select your country'),
                value: _selectedCountry,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 16,
                ),
                dropdownColor: themeProvider.cardColor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                items: _countries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // First language dropdown
          Text(
            'Native Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.dividerColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select your native language'),
                value: _selectedFirstLanguage,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 16,
                ),
                dropdownColor: themeProvider.cardColor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFirstLanguage = newValue;
                  });
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningReasonStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why are you learning?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reason helps us tailor content to your goals',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Reasons grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _reasonsToLearn.length,
            itemBuilder: (context, index) {
              final reason = _reasonsToLearn[index];
              final isSelected = _selectedReasonToLearn == reason;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedReasonToLearn = reason;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeProvider.primaryColor.withOpacity(0.2)
                        : themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? themeProvider.primaryColor
                          : themeProvider.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        reason,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? themeProvider.primaryColor
                              : themeProvider.textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Languages to Learn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more languages you want to learn',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Languages list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _languagesToLearn.length,
            itemBuilder: (context, index) {
              final language = _languagesToLearn[index];
              final languageId = language['id'] as int;
              final isSelected = _selectedLanguagesToLearn.contains(languageId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLanguagesToLearn.remove(languageId);
                      } else {
                        _selectedLanguagesToLearn.add(languageId);
                      }
                    });
                  },
                  tileColor: themeProvider.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? themeProvider.primaryColor
                          : themeProvider.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? themeProvider.primaryColor
                        : themeProvider.dividerColor,
                    child: Text(
                      language['code'] as String,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : themeProvider.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    language['name'] as String,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: themeProvider.primaryColor,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          color: themeProvider.dividerColor,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPreferencesStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your learning experience',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Daily goal
          Text(
            'Daily Goal (minutes)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: _dailyGoalOptions.map((goal) {
              final isSelected = _selectedDailyGoal == goal;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDailyGoal = goal;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeProvider.primaryColor
                        : themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? themeProvider.primaryColor
                          : themeProvider.dividerColor,
                    ),
                  ),
                  child: Text(
                    '$goal min',
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : themeProvider.textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Preferred learning time
          Text(
            'Preferred Learning Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.dividerColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select your preferred time'),
                value: _selectedPreferredTime,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 16,
                ),
                dropdownColor: themeProvider.cardColor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPreferredTime = newValue;
                  });
                },
                items: _preferredTimes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daily reminders
          Row(
            children: [
              Expanded(
                child: Text(
                  'Enable Daily Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.textColor,
                  ),
                ),
              ),
              Switch(
                value: _enableDailyReminders,
                onChanged: (value) {
                  setState(() {
                    _enableDailyReminders = value;
                  });
                },
                activeColor: themeProvider.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a profile picture to personalize your account',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Profile picture
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeProvider.primaryColor,
                      width: 3,
                    ),
                    image: _profileImageFile != null
                        ? DecorationImage(
                            image: FileImage(_profileImageFile!),
                            fit: BoxFit.cover,
                          )
                        : _profilePictureUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profilePictureUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child:
                      (_profileImageFile == null && _profilePictureUrl == null)
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: themeProvider.primaryColor,
                            )
                          : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to change profile picture',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Ready to start your learning journey?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
