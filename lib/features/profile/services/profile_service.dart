import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:afrilingo/core/services/user_cache_service.dart';
import 'package:afrilingo/features/profile/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl;
  final Future<Map<String, String>> Function() getHeaders;
  static const Duration _timeout = Duration(seconds: 10);

  ProfileService({required this.baseUrl, required this.getHeaders});

  // Add a method to fetch and set user identity
  Future<UserIdentity?> fetchAndSetUserIdentity() async {
    try {
      print("Fetching and setting user identity...");
      final headers = await getHeaders();

      // Try the profile/name endpoint first as it's lightweight
      try {
        final nameResponse = await http
            .get(Uri.parse('$baseUrl/profile/name'), headers: headers)
            .timeout(_timeout);

        if (nameResponse.statusCode == 200) {
          final data = json.decode(nameResponse.body);
          final nameData = data['data'] as Map<String, dynamic>;

          final userIdentity = UserIdentity(
              id: await UserCacheService.getCachedUserId(),
              firstName: nameData['firstName'] ?? '',
              lastName: nameData['lastName'] ?? '',
              email: nameData['email'] ?? '',
              profilePicture: await UserCacheService.getCachedProfilePicture(),
              streak: await getUserStreak());

          // Cache the identity
          await UserCacheService.cacheUserIdentity(userIdentity);
          print(
              "Set user identity from name endpoint: ${userIdentity.firstName}");

          return userIdentity;
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }

      // Try the auth/me endpoint if name endpoint fails
      try {
        final userResponse = await http
            .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
            .timeout(_timeout);

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          final user = userData['data'] ?? userData;

          final userIdentity = UserIdentity(
              id: user['id'] ?? 0,
              firstName: user['firstName'] ?? '',
              lastName: user['lastName'] ?? '',
              email: user['email'] ?? '',
              profilePicture: await UserCacheService.getCachedProfilePicture(),
              streak: await getUserStreak());

          // Cache the identity
          await UserCacheService.cacheUserIdentity(userIdentity);
          print(
              "Set user identity from auth endpoint: ${userIdentity.firstName}");

          return userIdentity;
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }

      // If we get here, try to use existing cached identity
      return await UserCacheService.getCurrentUserIdentity();
    } catch (e) {
      print("Error in fetchAndSetUserIdentity: $e");
      return null;
    }
  }

  Future<UserProfile> getCurrentUserProfile({bool forceRefresh = false}) async {
    // Try to get from cache first, unless forceRefresh is true
    if (!forceRefresh) {
      final isCacheValid = await UserCacheService.isCacheValid();
      if (isCacheValid) {
        final cachedProfile = await UserCacheService.getCachedUserProfile();
        if (cachedProfile != null) {
          return cachedProfile;
        }
      }
    } else {
      print("Force refreshing user profile from server...");
    }

    // First fetch and set user identity to ensure consistent data
    await fetchAndSetUserIdentity();

    // If no valid cache, fetch from network
    try {
      final headers = await getHeaders();

      // First try to use the dashboard endpoint which includes all user data
      try {
        print("Trying to fetch from dashboard endpoint...");
        final dashboardResponse = await http
            .get(Uri.parse('$baseUrl/dashboard'), headers: headers)
            .timeout(
              _timeout,
              onTimeout: () =>
                  throw Exception('Dashboard connection timed out'),
            );

        if (dashboardResponse.statusCode == 200) {
          final data = json.decode(dashboardResponse.body);
          final dashboardData = data['data'] ?? data;

          // Extract user profile from dashboard data
          if (dashboardData['userProfile'] != null) {
            final userProfileData = dashboardData['userProfile'];

            // The dashboard data includes both User and UserProfile
            // But we need to extract the user's first name and last name from the User entity
            final userData = userProfileData['user'];

            if (userData != null) {
              // Build a complete profile with user data merged in
              final completeProfileData = <String, dynamic>{...userProfileData};

              // Add the user data (firstName, lastName, email) directly to the profile
              completeProfileData['firstName'] = userData['firstName'];
              completeProfileData['lastName'] = userData['lastName'];
              completeProfileData['email'] = userData['email'];

              print(
                  "User data found in dashboard response: firstName=${userData['firstName']}, lastName=${userData['lastName']}");

              final profile = UserProfile.fromJson(completeProfileData);

              // Cache the profile for future use
              await UserCacheService.cacheUserProfile(profile);

              // Also create a UserIdentity object for consistent data
              final userIdentity = UserIdentity(
                  id: userData['id'] is int
                      ? userData['id']
                      : int.tryParse(userData['id'].toString()) ?? 0,
                  firstName: userData['firstName'] ?? '',
                  lastName: userData['lastName'] ?? '',
                  email: userData['email'] ?? '',
                  profilePicture: userProfileData['profilePicture'],
                  streak: await getUserStreak());

              await UserCacheService.cacheUserIdentity(userIdentity);

              return profile;
            }
          }
        }
      } catch (e) {
        print("Error fetching from dashboard endpoint: $e");
      }

      // Try the regular profile endpoint as fallback
      try {
        print("Trying to fetch from profile endpoint...");
        final response = await http
            .get(Uri.parse('$baseUrl/profile'), headers: headers)
            .timeout(
              _timeout,
              onTimeout: () => throw Exception('Profile connection timed out'),
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final responseData = data['data'] ?? data;

          // Try to extract user data from the profile response
          final profileData = <String, dynamic>{...responseData};

          // If the response contains user info, extract it
          if (responseData['user'] != null) {
            final userData = responseData['user'];
            // Prioritize user entity data for these fields
            if (userData['firstName'] != null)
              profileData['firstName'] = userData['firstName'];
            if (userData['lastName'] != null)
              profileData['lastName'] = userData['lastName'];
            if (userData['email'] != null)
              profileData['email'] = userData['email'];

            print(
                "User data found in profile response: firstName=${userData['firstName']}, lastName=${userData['lastName']}");

            // Create a UserIdentity for consistent data
            final userIdentity = UserIdentity(
                id: userData['id'] is int
                    ? userData['id']
                    : int.tryParse(userData['id'].toString()) ?? 0,
                firstName: userData['firstName'] ?? '',
                lastName: userData['lastName'] ?? '',
                email: userData['email'] ?? '',
                profilePicture: profileData['profilePicture'],
                streak: await getUserStreak());

            await UserCacheService.cacheUserIdentity(userIdentity);
          }

          final profile = UserProfile.fromJson(profileData);

          // Cache the profile for future use
          await UserCacheService.cacheUserProfile(profile);

          return profile;
        }
      } catch (e) {
        print("Error fetching from profile endpoint: $e");
      }

      // Try getting direct user info as a last resort
      try {
        print("Trying to fetch direct user info...");
        final userResponse = await http
            .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
            .timeout(_timeout);

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          final user = userData['data'] ?? userData;

          print(
              "User data found from auth endpoint: firstName=${user['firstName']}, lastName=${user['lastName']}");

          // Create a minimal profile from user data
          final profile = UserProfile(
            id: user['id'] ?? 0,
            firstName: user['firstName'],
            lastName: user['lastName'],
            email: user['email'],
            // Other fields will be null
            country: null,
            firstLanguage: null,
            profilePicture: null,
            languagesToLearn: [],
          );

          // Cache this minimal profile
          await UserCacheService.cacheUserProfile(profile);

          // Also create a UserIdentity for consistent data
          final userIdentity = UserIdentity(
              id: user['id'] is int
                  ? user['id']
                  : int.tryParse(user['id'].toString()) ?? 0,
              firstName: user['firstName'] ?? '',
              lastName: user['lastName'] ?? '',
              email: user['email'] ?? '',
              profilePicture: null,
              streak: await getUserStreak());

          await UserCacheService.cacheUserIdentity(userIdentity);

          return profile;
        }
      } catch (e) {
        print("Error fetching from auth endpoint: $e");
      }

      // If all server requests fail but we have a cached profile, return it
      final cachedProfile = await UserCacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        print("Using cached profile as fallback");
        return cachedProfile;
      }

      // Create a mock profile for development purposes
      print("Using mock profile as last resort");
      return _createMockProfile();
    } catch (e) {
      print("Error in getCurrentUserProfile: $e");

      // On error, try to use cached data as fallback
      final cachedProfile = await UserCacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        print("Using cached profile after error");
        return cachedProfile;
      }

      // Create a mock profile for development purposes
      print("Using mock profile after error");
      return _createMockProfile();
    }
  }

  Future<bool> checkUserProfileExists() async {
    final headers = await getHeaders();
    final response = await http
        .get(Uri.parse('$baseUrl/profile/exists'), headers: headers)
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Connection timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] == true;
    } else {
      throw Exception('Failed to check user profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createOrUpdateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      final headers = await getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/profile'),
            headers: headers,
            body: json.encode(profileData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<UserProfile> updateLanguagesToLearn(List<int> languageIds) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/profile/languages'),
      headers: headers,
      body: json.encode(languageIds),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data'] ?? data);
    } else {
      throw Exception(
          'Failed to update languages to learn: ${response.statusCode}');
    }
  }

  Future<UserProfile> updateLearningPreferences({
    required bool dailyReminders,
    required int dailyGoalMinutes,
    String? preferredLearningTime,
  }) async {
    final headers = await getHeaders();
    final params = <String, String>{
      'dailyReminders': dailyReminders.toString(),
      'dailyGoalMinutes': dailyGoalMinutes.toString(),
    };
    if (preferredLearningTime != null) {
      params['preferredLearningTime'] = preferredLearningTime;
    }
    final uri = Uri.parse('$baseUrl/profile/preferences')
        .replace(queryParameters: params);
    final response = await http.put(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data'] ?? data);
    } else {
      throw Exception(
          'Failed to update learning preferences: ${response.statusCode}');
    }
  }

  // Update Profile Picture
  Future<bool> updateProfilePicture(String imageData) async {
    try {
      final headers = await getHeaders();

      // Check if the image is already a URL or a base64 string
      final bool isBase64 = !imageData.startsWith('http');

      print(
          "Sending profile picture update request: ${isBase64 ? 'Base64 image' : 'URL: $imageData'}");

      // Format the request based on backend expectations
      // The backend expects either a URL string or a base64 string with prefix
      final String formattedImage = isBase64
          ? (imageData.startsWith('data:image')
              ? imageData
              : 'data:image/jpeg;base64,$imageData')
          : imageData;

      final response = await http
          .put(
            Uri.parse('$baseUrl/profile/picture'),
            headers: headers,
            body: json
                .encode(formattedImage), // Send properly formatted image data
          )
          .timeout(_timeout);

      print(
          "Profile picture update response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        // Extract profile picture URL from the response if available
        try {
          final data = json.decode(response.body);
          if (data['data'] != null && data['data']['profilePicture'] != null) {
            final updatedPictureUrl = data['data']['profilePicture'];

            // Cache the updated profile picture URL
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_profile_picture', updatedPictureUrl);

            // Update user identity to ensure consistency
            try {
              final identity = await UserCacheService.getCurrentUserIdentity();
              if (identity != null) {
                await UserCacheService.updateUserIdentityField(
                    'profilePicture', updatedPictureUrl);
              }
            } catch (e) {
              print("Error updating user identity: $e");
              // Continue despite error - we've already saved to SharedPreferences
            }

            print("Profile picture updated successfully: $updatedPictureUrl");
          }
        } catch (e) {
          print("Error extracting updated profile picture URL: $e");
        }

        return true;
      } else {
        print(
            "Failed to update profile picture. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating profile picture: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserDashboard() async {
    try {
      final headers = await getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/dashboard'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dashboardData = data['data'] ?? data;

        print("Dashboard data received: ${dashboardData.keys}");

        // Make sure we extract user profile data if it exists
        if (dashboardData.containsKey('userProfile') &&
            dashboardData['userProfile'] != null) {
          final userProfile = dashboardData['userProfile'];

          // If the profile includes user data, cache it for faster access
          if (userProfile.containsKey('user') && userProfile['user'] != null) {
            final userData = userProfile['user'];

            // Cache key user information
            if (userData['firstName'] != null &&
                userData['firstName'].toString().isNotEmpty) {
              await UserCacheService.cacheFirstName(userData['firstName']);
            }

            if (userData['email'] != null &&
                userData['email'].toString().isNotEmpty) {
              await UserCacheService.cacheEmail(userData['email']);
            }

            if (userProfile['profilePicture'] != null &&
                userProfile['profilePicture'].toString().isNotEmpty) {
              await UserCacheService.cacheProfilePicture(
                  userProfile['profilePicture']);
            }

            // Also cache the full profile
            try {
              final profile = UserProfile(
                id: userProfile['id'] ?? 0,
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                email: userData['email'],
                country: userProfile['country'],
                firstLanguage: userProfile['firstLanguage'],
                profilePicture: userProfile['profilePicture'],
                reasonToLearn: userProfile['reasonToLearn'],
                dailyReminders: userProfile['dailyReminders'] == true,
                dailyGoalMinutes: userProfile['dailyGoalMinutes'] ?? 0,
                preferredLearningTime: userProfile['preferredLearningTime'],
                languagesToLearn: [], // We don't cache languages in this quick operation
              );

              await UserCacheService.cacheUserProfile(profile);
            } catch (cacheError) {
              print("Error caching profile: $cacheError");
            }
          }
        }

        return dashboardData;
      } else {
        print(
            "Dashboard endpoint returned status code: ${response.statusCode}");
        print("Response body: ${response.body}");

        // Return fallback data structure instead of throwing
        return await _getFallbackDashboardData();
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");

      // Return fallback data structure instead of throwing
      return await _getFallbackDashboardData();
    }
  }

  // Create a more robust fallback method for dashboard data
  Future<Map<String, dynamic>> _getFallbackDashboardData() async {
    // Get cached streak and completed lessons count
    final streak = await UserCacheService.getCachedStreak();

    // Get completed lessons count
    int completedLessons = 0;
    double courseProgress = 0.0;

    try {
      final prefs = await SharedPreferences.getInstance();
      completedLessons = prefs.getInt('completed_lessons_count') ?? 0;

      // Calculate course progress based on completed lessons
      courseProgress = completedLessons > 0
          ? (completedLessons / 10.0 * 100).clamp(0.0, 100.0)
          : 30.0;
    } catch (e) {
      print("Error getting completed lessons count: $e");
    }

    // First try to get user profile from the /profile/name endpoint
    try {
      final nameData = await getUserName();
      if (nameData['firstName']!.isNotEmpty) {
        final userProfile = {
          'id': 1,
          'firstName': nameData['firstName'],
          'lastName': nameData['lastName'] ?? '',
          'email': nameData['email'] ?? '',
          'user': {
            'firstName': nameData['firstName'],
            'lastName': nameData['lastName'] ?? '',
            'email': nameData['email'] ?? ''
          },
          'profilePicture': await UserCacheService.getCachedProfilePicture()
        };

        return {
          'userProfile': userProfile,
          'learningStats': {
            'completedLessons': completedLessons,
            'streak': streak,
            'averageQuizScore': 85,
            'totalLearningMinutes': completedLessons * 10,
            'passRate': 90
          },
          'recommendedCourses': [
            {
              'id': 1,
              'title': 'Basic Kinyarwanda',
              'level': 'Beginner',
              'language': {'name': 'Kinyarwanda', 'code': 'RW'}
            }
          ],
          'courseProgress': {'1': courseProgress}
        };
      }
    } catch (e) {
      print("Error in name fallback: $e");
    }

    // If that fails, try to get the cached profile
    try {
      final cachedProfile = await UserCacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        return {
          'userProfile': {
            'id': cachedProfile.id,
            'firstName': cachedProfile.firstName,
            'lastName': cachedProfile.lastName,
            'email': cachedProfile.email,
            'profilePicture': cachedProfile.profilePicture,
            'user': {
              'firstName': cachedProfile.firstName,
              'lastName': cachedProfile.lastName,
              'email': cachedProfile.email
            }
          },
          'learningStats': {
            'completedLessons': completedLessons,
            'streak': streak,
            'averageQuizScore': 85,
            'totalLearningMinutes': completedLessons * 10,
            'passRate': 90
          },
          'recommendedCourses': [
            {
              'id': 1,
              'title': 'Basic Kinyarwanda',
              'level': 'Beginner',
              'language': {'name': 'Kinyarwanda', 'code': 'RW'}
            }
          ],
          'courseProgress': {'1': courseProgress}
        };
      }
    } catch (e) {
      print("Error getting cached profile: $e");
    }

    // Last resort - use mock data with real progress values
    final mockUser = _createMockProfile();
    return {
      'userProfile': {
        'id': mockUser.id,
        'firstName': mockUser.firstName,
        'lastName': mockUser.lastName,
        'email': mockUser.email,
        'profilePicture': mockUser.profilePicture,
        'user': {
          'firstName': mockUser.firstName,
          'lastName': mockUser.lastName,
          'email': mockUser.email
        }
      },
      'learningStats': {
        'completedLessons': completedLessons,
        'streak': streak,
        'averageQuizScore': 85,
        'totalLearningMinutes': completedLessons * 10,
        'passRate': 90
      },
      'recommendedCourses': [
        {
          'id': 1,
          'title': 'Basic Kinyarwanda',
          'level': 'Beginner',
          'language': {'name': 'Kinyarwanda', 'code': 'RW'}
        }
      ],
      'courseProgress': {'1': courseProgress}
    };
  }

  Future<Map<String, String>> getUserName() async {
    try {
      // Try to get from existing identity first
      final identity = await UserCacheService.getCurrentUserIdentity();
      if (identity != null && identity.firstName.isNotEmpty) {
        print("Using existing identity for user name: ${identity.firstName}");
        return {
          'firstName': identity.firstName,
          'lastName': identity.lastName,
          'email': identity.email
        };
      }

      final headers = await getHeaders();

      // Try using the /auth/me endpoint to get user details
      try {
        print("Getting user info from $baseUrl/auth/me");
        final response = await http
            .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final userData = data['user'] ?? data;

          print(
              "Successfully retrieved user info: ${userData['firstName']} ${userData['lastName']}");

          // Create user identity object
          final userIdentity = UserIdentity(
              id: userData['id'] ?? await UserCacheService.getCachedUserId(),
              firstName: userData['firstName'] ?? '',
              lastName: userData['lastName'] ?? '',
              email: userData['email'] ?? '',
              profilePicture: await UserCacheService.getCachedProfilePicture(),
              streak: await getUserStreak());

          // Cache the complete identity
          await UserCacheService.cacheUserIdentity(userIdentity);

          return {
            'firstName': userData['firstName'] ?? '',
            'lastName': userData['lastName'] ?? '',
            'email': userData['email'] ?? ''
          };
        }
      } catch (e) {
        print("Error getting user info from auth/me: $e");
      }

      // Fallback to profile/name
      print("Falling back to $baseUrl/profile/name");
      final response = await http
          .get(Uri.parse('$baseUrl/profile/name'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nameData = data['data'] as Map<String, dynamic>;

        print(
            "Successfully retrieved user name: ${nameData['firstName']} ${nameData['lastName']}");

        // Create user identity object
        final userIdentity = UserIdentity(
            id: await UserCacheService.getCachedUserId(),
            firstName: nameData['firstName'] ?? '',
            lastName: nameData['lastName'] ?? '',
            email: nameData['email'] ?? '',
            profilePicture: await UserCacheService.getCachedProfilePicture(),
            streak: await getUserStreak());

        // Cache the complete identity
        await UserCacheService.cacheUserIdentity(userIdentity);

        return {
          'firstName': nameData['firstName'] ?? '',
          'lastName': nameData['lastName'] ?? '',
          'email': nameData['email'] ?? ''
        };
      } else {
        print("Failed to get user name. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");

        // Try getting user data from SharedPreferences as final fallback
        try {
          final prefs = await SharedPreferences.getInstance();
          final firstName = prefs.getString('user_first_name');
          final lastName = prefs.getString('user_last_name');
          final email = prefs.getString('user_email');

          if (firstName != null && firstName.isNotEmpty) {
            print(
                "Using user data from SharedPreferences: $firstName $lastName");

            // Create user identity from SharedPreferences
            final userIdentity = UserIdentity(
                id: 0, // No ID available from SharedPreferences
                firstName: firstName,
                lastName: lastName ?? '',
                email: email ?? '',
                profilePicture:
                    await UserCacheService.getCachedProfilePicture(),
                streak: await getUserStreak());

            await UserCacheService.cacheUserIdentity(userIdentity);

            return {
              'firstName': firstName,
              'lastName': lastName ?? '',
              'email': email ?? ''
            };
          }
        } catch (e) {
          print("Error getting user data from SharedPreferences: $e");
        }

        throw Exception('Failed to get user name from any source');
      }
    } catch (e) {
      print('Error getting user name: $e');

      // Try existing identity as fallback
      final identity = await UserCacheService.getCurrentUserIdentity();
      if (identity != null && identity.firstName.isNotEmpty) {
        return {
          'firstName': identity.firstName,
          'lastName': identity.lastName,
          'email': identity.email
        };
      }

      // If we don't have good cached data, try getting directly from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('user_first_name');
      final lastName = prefs.getString('user_last_name');
      final email = prefs.getString('user_email');

      if (firstName != null && firstName.isNotEmpty) {
        return {
          'firstName': firstName,
          'lastName': lastName ?? '',
          'email': email ?? ''
        };
      }

      return {'firstName': 'User', 'lastName': '', 'email': ''};
    }
  }

  // Create a mock profile for development when backend is not available
  UserProfile _createMockProfile() {
    // Use empty data instead of hardcoded mock values
    return UserProfile(
      id: 1,
      firstName: "",
      lastName: "",
      email: "",
      country: "Rwanda",
      firstLanguage: "English",
      profilePicture: null,
      reasonToLearn: "To learn African languages",
      languagesToLearn: [],
      dailyReminders: true,
      dailyGoalMinutes: 30,
      preferredLearningTime: "19:00",
    );
  }

  // Add a dedicated method to get streak data
  Future<int> getUserStreak({bool forceRefresh = false}) async {
    try {
      // Always get from server if forceRefresh is true
      if (forceRefresh) {
        final headers = await getHeaders();
        int streak = 0;

        // Try the dedicated streak endpoint
        try {
          print(
              "Getting streak from dedicated streak endpoint (forced refresh)");
          final streakResponse = await http
              .get(Uri.parse('$baseUrl/progress/streak'), headers: headers)
              .timeout(_timeout);

          if (streakResponse.statusCode == 200) {
            final data = json.decode(streakResponse.body);
            final responseData = data['data'] ?? data;

            if (responseData is Map && responseData.containsKey('streak')) {
              final fetchedStreak = responseData['streak'];
              if (fetchedStreak is int || fetchedStreak is double) {
                streak = fetchedStreak is int
                    ? fetchedStreak
                    : fetchedStreak.toInt();
                // Cache the latest streak value
                await UserCacheService.cacheStreak(streak);
                print(
                    "Got streak from dedicated endpoint (forced refresh): $streak");
                return streak;
              }
            }
          } else {
            print("Streak endpoint failed: ${streakResponse.statusCode}");
          }
        } catch (e) {
          print("Error getting streak from dedicated endpoint: $e");
        }

        // If all methods fail, return 0
        return 0;
      }

      // Regular flow - try cache first then server
      // Skip cache if force refresh is requested
      final cachedStreak = await UserCacheService.getCachedStreak();
      // If we have a valid cached streak, use it
      if (cachedStreak > 0) {
        print("Using cached streak: $cachedStreak");
        return cachedStreak;
      }

      final headers = await getHeaders();
      int streak = 0;

      // ONLY use the dedicated streak endpoint - this is the most accurate
      try {
        print("Getting streak from dedicated streak endpoint");
        final streakResponse = await http
            .get(Uri.parse('$baseUrl/progress/streak'), headers: headers)
            .timeout(_timeout);

        if (streakResponse.statusCode == 200) {
          final data = json.decode(streakResponse.body);
          final responseData = data['data'] ?? data;

          if (responseData is Map && responseData.containsKey('streak')) {
            final fetchedStreak = responseData['streak'];
            if (fetchedStreak is int || fetchedStreak is double) {
              streak =
                  fetchedStreak is int ? fetchedStreak : fetchedStreak.toInt();
              // Cache the latest streak value
              await UserCacheService.cacheStreak(streak);
              print("Got streak from dedicated endpoint: $streak");
              return streak;
            }
          }
        } else {
          print("Streak endpoint failed: ${streakResponse.statusCode}");
        }
      } catch (e) {
        print("Error getting streak from dedicated endpoint: $e");
      }

      // If we have a cached streak, return it
      if (cachedStreak > 0) {
        return cachedStreak;
      }

      // Try to get from identity
      final identity = await UserCacheService.getCurrentUserIdentity();
      if (identity != null && identity.streak > 0) {
        return identity.streak;
      }

      // If all methods fail and no cached streak, return 0
      return 0;
    } catch (e) {
      print("Error in getUserStreak: $e");
      // Try to get cached streak as last resort
      final cachedStreak = await UserCacheService.getCachedStreak();
      return cachedStreak;
    }
  }

  // Get course progress for a specific course
  Future<double> getCourseProgress(int courseId) async {
    try {
      final headers = await getHeaders();

      // First try to get from dashboard data
      final dashboardData = await getUserDashboard();

      if (dashboardData.containsKey('courseProgress') &&
          dashboardData['courseProgress'] != null) {
        final progress = dashboardData['courseProgress'][courseId.toString()];
        if (progress != null) {
          return (progress is double)
              ? progress
              : double.parse(progress.toString());
        }
      }

      // If we couldn't get from dashboard, try the completed lessons count approach
      final prefs = await SharedPreferences.getInstance();
      final completedLessons = prefs.getInt('completed_lessons_count') ?? 0;

      // Estimate course progress based on completed lessons
      // Assuming a course has around 10 lessons on average
      return (completedLessons / 10.0 * 100).clamp(0.0, 100.0);
    } catch (e) {
      print("Error getting course progress: $e");
      return 0.0;
    }
  }

  // Get completed lessons count
  Future<int> getCompletedLessonsCount() async {
    try {
      final headers = await getHeaders();

      // First try to get from dashboard data
      final dashboardData = await getUserDashboard();

      if (dashboardData.containsKey('learningStats') &&
          dashboardData['learningStats'] != null &&
          dashboardData['learningStats'].containsKey('completedLessons')) {
        final completedLessons =
            dashboardData['learningStats']['completedLessons'];
        if (completedLessons != null) {
          return completedLessons is int
              ? completedLessons
              : int.parse(completedLessons.toString());
        }
      }

      // If we couldn't get from dashboard, use the local storage value
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('completed_lessons_count') ?? 0;
    } catch (e) {
      print("Error getting completed lessons count: $e");
      return 0;
    }
  }

  // Check if user is authenticated with Google
  Future<bool> isGoogleAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authType = prefs.getString('auth_type');
      return authType == 'google';
    } catch (e) {
      print('Error checking Google authentication: $e');
      return false;
    }
  }

  // Get user data for Google-authenticated users
  Future<UserIdentity?> getGoogleUserIdentity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? '';
      final userEmail = prefs.getString('user_email') ?? '';
      final userPhoto = prefs.getString('user_photo') ?? '';
      final userId = prefs.getString('user_id') ?? '0';

      // Try to parse the name into first and last name
      String firstName = userName;
      String lastName = '';

      if (userName.contains(' ')) {
        final nameParts = userName.split(' ');
        firstName = nameParts.first;
        lastName = nameParts.skip(1).join(' ');
      }

      final userIdentity = UserIdentity(
        id: int.tryParse(userId) ?? 0,
        firstName: firstName,
        lastName: lastName,
        email: userEmail,
        profilePicture: userPhoto,
        streak: await getUserStreak(),
      );

      // Cache the identity
      await UserCacheService.cacheUserIdentity(userIdentity);

      return userIdentity;
    } catch (e) {
      print('Error getting Google user identity: $e');
      return null;
    }
  }

  // Save authentication type (google or email/password)
  Future<void> saveAuthType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_type', type);
    } catch (e) {
      print('Error saving authentication type: $e');
    }
  }
}
