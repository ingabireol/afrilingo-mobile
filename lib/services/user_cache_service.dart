import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// A service that handles caching user information for faster access
class UserCacheService {
  static const String _profileKey = 'cached_user_profile';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _emailKey = 'user_email';
  static const String _profilePictureKey = 'user_profile_picture';
  static const Duration _cacheExpiration = Duration(hours: 12);
  static const String _lastUpdatedKey = 'last_profile_update';

  /// Saves user profile to cache
  static Future<void> cacheUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cache full profile as JSON
    final profileJson = json.encode({
      'id': profile.id,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'email': profile.email,
      'country': profile.country,
      'firstLanguage': profile.firstLanguage,
      'profilePicture': profile.profilePicture,
      'reasonToLearn': profile.reasonToLearn,
      'dailyReminders': profile.dailyReminders,
      'dailyGoalMinutes': profile.dailyGoalMinutes,
      'preferredLearningTime': profile.preferredLearningTime,
      // We skip languagesToLearn as it's complex to serialize fully
    });
    
    // Also cache common fields separately for quick access
    await prefs.setString(_profileKey, profileJson);
    
    if (profile.firstName != null && profile.firstName!.isNotEmpty) {
      await prefs.setString(_firstNameKey, profile.firstName!);
    }
    
    if (profile.lastName != null && profile.lastName!.isNotEmpty) {
      await prefs.setString(_lastNameKey, profile.lastName!);
    }
    
    if (profile.email != null && profile.email!.isNotEmpty) {
      await prefs.setString(_emailKey, profile.email!);
    }
    
    if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
      await prefs.setString(_profilePictureKey, profile.profilePicture!);
    }
    
    await prefs.setInt(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Gets cached user first name or empty string
  static Future<String> getCachedFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey) ?? '';
    
    // If we have a first name, return it
    if (firstName.isNotEmpty) {
      return firstName;
    }
    
    // Check if we have a last name to use instead
    final lastName = prefs.getString(_lastNameKey) ?? '';
    if (lastName.isNotEmpty) {
      return lastName;
    }
    
    // Use part before @ in email if available
    final email = prefs.getString(_emailKey) ?? '';
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@')[0];
    }
    
    // Return empty string rather than a default value
    return '';
  }

  /// Gets cached user email
  static Future<String?> getCachedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Gets cached user full name or default value
  static Future<String> getCachedFullName({String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey) ?? '';
    final lastName = prefs.getString(_lastNameKey) ?? '';
    
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : defaultValue;
  }

  /// Gets cached profile picture URL
  static Future<String?> getCachedProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePictureKey);
  }

  /// Gets full cached user profile
  static Future<UserProfile?> getCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    
    if (profileJson == null) return null;
    
    try {
      final Map<String, dynamic> profileMap = json.decode(profileJson);
      return UserProfile(
        id: profileMap['id'] ?? 0,
        firstName: profileMap['firstName'],
        lastName: profileMap['lastName'],
        email: profileMap['email'],
        country: profileMap['country'],
        firstLanguage: profileMap['firstLanguage'],
        profilePicture: profileMap['profilePicture'],
        reasonToLearn: profileMap['reasonToLearn'],
        dailyReminders: profileMap['dailyReminders'] ?? false,
        dailyGoalMinutes: profileMap['dailyGoalMinutes'] ?? 0,
        preferredLearningTime: profileMap['preferredLearningTime'],
        languagesToLearn: [], // Note: We don't cache complex objects
      );
    } catch (e) {
      return null;
    }
  }

  /// Checks if cache is valid (not expired)
  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getInt(_lastUpdatedKey);
    
    if (lastUpdated == null) return false;
    
    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
    final now = DateTime.now();
    return now.difference(lastUpdateTime) < _cacheExpiration;
  }

  /// Clears all cached user data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_profilePictureKey);
    await prefs.remove(_lastUpdatedKey);
  }

  /// Cache first name separately for quick access
  static Future<void> cacheFirstName(String firstName) async {
    if (firstName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
  }

  /// Cache email separately for quick access
  static Future<void> cacheEmail(String? email) async {
    if (email == null || email.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// Cache profile picture URL separately for quick access
  static Future<void> cacheProfilePicture(String? profilePicture) async {
    if (profilePicture == null || profilePicture.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, profilePicture);
  }
} 