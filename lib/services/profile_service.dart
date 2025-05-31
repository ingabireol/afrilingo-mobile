import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'user_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl;
  final Future<Map<String, String>> Function() getHeaders;
  static const Duration _timeout = Duration(seconds: 10);

  ProfileService({required this.baseUrl, required this.getHeaders});

  Future<UserProfile> getCurrentUserProfile() async {
    // Try to get from cache first
    final isCacheValid = await UserCacheService.isCacheValid();
    if (isCacheValid) {
      final cachedProfile = await UserCacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        return cachedProfile;
      }
    }

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
              onTimeout: () => throw Exception('Dashboard connection timed out'),
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
              
              print("User data found in dashboard response: firstName=${userData['firstName']}, lastName=${userData['lastName']}");
              
              final profile = UserProfile.fromJson(completeProfileData);
              
              // Cache the profile for future use
              await UserCacheService.cacheUserProfile(profile);
              
              // Also cache individual fields for quick access
              if (userData['firstName'] != null) {
                await UserCacheService.cacheFirstName(userData['firstName']);
              }
              if (userData['email'] != null) {
                await UserCacheService.cacheEmail(userData['email']);
              }
              
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
            if (userData['firstName'] != null) profileData['firstName'] = userData['firstName'];
            if (userData['lastName'] != null) profileData['lastName'] = userData['lastName'];
            if (userData['email'] != null) profileData['email'] = userData['email'];
            
            print("User data found in profile response: firstName=${userData['firstName']}, lastName=${userData['lastName']}");
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
          
          print("User data found from auth endpoint: firstName=${user['firstName']}, lastName=${user['lastName']}");
          
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
          
          // Also cache individual fields for quick access
          if (user['firstName'] != null) {
            await UserCacheService.cacheFirstName(user['firstName']);
          }
          if (user['email'] != null) {
            await UserCacheService.cacheEmail(user['email']);
          }
          
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

  Future<Map<String, dynamic>> createOrUpdateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: json.encode(profileData),
      ).timeout(_timeout);

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
      throw Exception('Failed to update languages to learn: ${response.statusCode}');
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
    final uri = Uri.parse('$baseUrl/profile/preferences').replace(queryParameters: params);
    final response = await http.put(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to update learning preferences: ${response.statusCode}');
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profile/picture'),
        headers: headers,
        body: json.encode({'profilePicture': imageUrl}),
      ).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update profile picture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
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
        return data['data'] ?? data;
      } else {
        print("Dashboard endpoint returned status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        // Return empty data structure instead of throwing
        return {
          'userProfile': await _getFallbackUserProfile(headers),
          'learningStats': {
            'completedLessons': 3,
            'streak': 5,
            'averageQuizScore': 85,
            'totalLearningMinutes': 120,
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
          'courseProgress': {
            '1': 30.0 // 30% progress on course 1
          }
        };
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      
      // Return empty data structure instead of throwing
      return {
        'userProfile': await _getFallbackUserProfile(null),
        'learningStats': {
          'completedLessons': 3,
          'streak': 5,
          'averageQuizScore': 85,
          'totalLearningMinutes': 120,
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
        'courseProgress': {
          '1': 30.0 // 30% progress on course 1
        }
      };
    }
  }
  
  // Helper method to get user profile from other endpoints if dashboard fails
  Future<Map<String, dynamic>> _getFallbackUserProfile(Map<String, String>? headers) async {
    try {
      // Try to get cached user profile first
      final cachedProfile = await UserCacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        // Convert to map
        return {
          'id': cachedProfile.id,
          'firstName': cachedProfile.firstName,
          'lastName': cachedProfile.lastName,
          'email': cachedProfile.email,
          'user': {
            'firstName': cachedProfile.firstName,
            'lastName': cachedProfile.lastName,
            'email': cachedProfile.email
          }
        };
      }
      
      // If no cached profile and no headers, use mock data
      if (headers == null) {
        final mockUser = _createMockProfile();
        return {
          'id': mockUser.id,
          'firstName': mockUser.firstName,
          'lastName': mockUser.lastName,
          'email': mockUser.email,
          'user': {
            'firstName': mockUser.firstName,
            'lastName': mockUser.lastName,
            'email': mockUser.email
          }
        };
      }
      
      // Try to get profile from auth endpoint
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
            .timeout(_timeout);
            
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final userData = data['data'] ?? data;
          
          return {
            'id': userData['id'] ?? 0,
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'email': userData['email'],
            'user': userData
          };
        }
      } catch (e) {
        print("Failed to get user from auth endpoint: $e");
      }
      
      // If all else fails, return mock data
      final mockUser = _createMockProfile();
      return {
        'id': mockUser.id,
        'firstName': mockUser.firstName,
        'lastName': mockUser.lastName,
        'email': mockUser.email,
        'user': {
          'firstName': mockUser.firstName,
          'lastName': mockUser.lastName,
          'email': mockUser.email
        }
      };
    } catch (e) {
      print("Error in _getFallbackUserProfile: $e");
      
      // Return mock data as last resort
      final mockUser = _createMockProfile();
      return {
        'id': mockUser.id,
        'firstName': mockUser.firstName,
        'lastName': mockUser.lastName,
        'email': mockUser.email,
        'user': {
          'firstName': mockUser.firstName,
          'lastName': mockUser.lastName,
          'email': mockUser.email
        }
      };
    }
  }

  Future<Map<String, String>> getUserName() async {
    try {
      final headers = await getHeaders();
      print("Getting user name from $baseUrl/profile/name");
      final response = await http
          .get(Uri.parse('$baseUrl/profile/name'), headers: headers)
          .timeout(_timeout);
          
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nameData = data['data'] as Map<String, dynamic>;
        
        print("Successfully retrieved user name: ${nameData['firstName']} ${nameData['lastName']}");
        
        // Cache the name data
        if (nameData['firstName'] != null) {
          await UserCacheService.cacheFirstName(nameData['firstName']);
        }
        if (nameData['email'] != null) {
          await UserCacheService.cacheEmail(nameData['email']);
        }
        
        return {
          'firstName': nameData['firstName'] ?? '',
          'lastName': nameData['lastName'] ?? '',
          'email': nameData['email'] ?? ''
        };
      } else {
        print("Failed to get user name. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        // Try getting user data from auth/me endpoint as fallback
        try {
          print("Trying fallback to auth/me endpoint");
          final userResponse = await http
              .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
              .timeout(_timeout);
              
          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            final user = userData['data'] ?? userData;
            
            print("Got user data from auth endpoint: ${user['firstName']}");
            
            // Cache the name data
            if (user['firstName'] != null) {
              await UserCacheService.cacheFirstName(user['firstName']);
            }
            if (user['email'] != null) {
              await UserCacheService.cacheEmail(user['email']);
            }
            
            return {
              'firstName': user['firstName'] ?? '',
              'lastName': user['lastName'] ?? '',
              'email': user['email'] ?? ''
            };
          }
        } catch (fallbackError) {
          print("Error in name fallback: $fallbackError");
        }
        
        throw Exception('Failed to get user name: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting user name: $e');
      // Return cached data as fallback
      final firstName = await UserCacheService.getCachedFirstName();
      final email = await UserCacheService.getCachedEmail();
      
      // Avoid returning empty or default values
      if (firstName.isNotEmpty && firstName != "User" && firstName != "Buntu") {
        return {
          'firstName': firstName,
          'lastName': '',
          'email': email ?? ''
        };
      }
      
      // If we don't have good cached data, try one more approach - get directly from localStorage
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedFirstName = prefs.getString('user_firstName');
        final storedEmail = prefs.getString('user_email');
        
        if (storedFirstName != null && storedFirstName.isNotEmpty) {
          print("Found user name in localStorage: $storedFirstName");
          return {
            'firstName': storedFirstName,
            'lastName': prefs.getString('user_lastName') ?? '',
            'email': storedEmail ?? ''
          };
        }
      } catch (storageError) {
        print("Error accessing localStorage: $storageError");
      }
      
      // As a very last resort, return an empty map
      return {
        'firstName': '',
        'lastName': '',
        'email': ''
      };
    }
  }

  // Create a mock profile for development when backend is not available
  UserProfile _createMockProfile() {
    // Use generic data instead of specific mock data
    return UserProfile(
      id: 1,
      firstName: "Guest",
      lastName: "User",
      email: "guest@afrilingo.com",
      country: "Rwanda",
      firstLanguage: "English",
      profilePicture: "https://api.dicebear.com/7.x/avataaars/svg?seed=guest",
      reasonToLearn: "To learn African languages",
      languagesToLearn: [],
      dailyReminders: true,
      dailyGoalMinutes: 30,
      preferredLearningTime: "19:00",
    );
  }
} 