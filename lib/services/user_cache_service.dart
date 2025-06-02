import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// A simple class to store the core identity information of a user
class UserIdentity {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final int streak;

  UserIdentity(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      this.profilePicture,
      this.streak = 0});

  factory UserIdentity.fromJson(Map<String, dynamic> json) {
    // Ensure we have clean firstName and lastName values
    final firstName = json['firstName']?.toString() ?? '';
    // Ensure lastName doesn't contain extra names that should be in firstName
    final lastName = json['lastName']?.toString() ?? '';

    return UserIdentity(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: firstName,
      lastName: lastName,
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture'],
      streak: json['streak'] is int
          ? json['streak']
          : int.tryParse(json['streak']?.toString() ?? '') ?? 0,
    );
  }

  /// Formats the user's full name properly
  String get fullName {
    final trimmedFirst = firstName.trim();
    final trimmedLast = lastName.trim();

    if (trimmedFirst.isEmpty && trimmedLast.isEmpty) {
      return '';
    } else if (trimmedFirst.isEmpty) {
      return trimmedLast;
    } else if (trimmedLast.isEmpty) {
      return trimmedFirst;
    } else {
      return '$trimmedFirst $trimmedLast';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePicture': profilePicture,
      'streak': streak,
    };
  }
}

/// A service that handles caching user information for faster access
class UserCacheService {
  static const String _profileKey = 'cached_user_profile';
  static const String _userIdentityKey = 'user_identity';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _emailKey = 'user_email';
  static const String _profilePictureKey = 'user_profile_picture';
  static const String _streakKey = 'user_streak';
  static const String _userIdKey = 'user_id';
  static const Duration _cacheExpiration = Duration(hours: 12);
  static const String _lastUpdatedKey = 'last_profile_update';

  // Current user identity in memory
  static UserIdentity? _currentUserIdentity;

  /// Get the current user identity (from memory or cache)
  static Future<UserIdentity?> getCurrentUserIdentity() async {
    // Return from memory if available
    if (_currentUserIdentity != null) {
      return _currentUserIdentity;
    }

    // Try to load from cache
    final prefs = await SharedPreferences.getInstance();
    final identityJson = prefs.getString(_userIdentityKey);
    if (identityJson != null) {
      try {
        final identity = UserIdentity.fromJson(json.decode(identityJson));
        _currentUserIdentity = identity;
        return identity;
      } catch (e) {
        print("Error parsing cached user identity: $e");
      }
    }

    // If no identity is cached, try to build one from individual fields
    final id = prefs.getInt(_userIdKey) ?? 0;
    final firstName = prefs.getString(_firstNameKey) ?? '';
    final lastName = prefs.getString(_lastNameKey) ?? '';
    final email = prefs.getString(_emailKey) ?? '';
    final profilePicture = prefs.getString(_profilePictureKey);
    final streak = prefs.getInt(_streakKey) ?? 0;

    if (firstName.isNotEmpty || email.isNotEmpty) {
      final identity = UserIdentity(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          profilePicture: profilePicture,
          streak: streak);
      _currentUserIdentity = identity;

      // Save this constructed identity for future use
      await cacheUserIdentity(identity);

      return identity;
    }

    return null;
  }

  /// Cache the user identity as a single coherent unit
  static Future<void> cacheUserIdentity(UserIdentity identity) async {
    // Update in-memory copy
    _currentUserIdentity = identity;

    final prefs = await SharedPreferences.getInstance();

    // Save as a complete JSON object
    await prefs.setString(_userIdentityKey, json.encode(identity.toJson()));

    // Also save individual fields for backward compatibility
    await prefs.setInt(_userIdKey, identity.id);
    await prefs.setString(_firstNameKey, identity.firstName);
    await prefs.setString(_lastNameKey, identity.lastName);
    await prefs.setString(_emailKey, identity.email);
    if (identity.profilePicture != null) {
      await prefs.setString(_profilePictureKey, identity.profilePicture!);
    }
    await prefs.setInt(_streakKey, identity.streak);

    // Update last updated timestamp
    await prefs.setInt(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Update a specific field in the user identity
  static Future<void> updateUserIdentityField(
      String field, dynamic value) async {
    final identity = await getCurrentUserIdentity();
    if (identity == null) {
      print("Cannot update field $field - no user identity found");
      return;
    }

    // Create updated identity based on the field
    UserIdentity updatedIdentity;

    switch (field) {
      case 'firstName':
        updatedIdentity = UserIdentity(
            id: identity.id,
            firstName: value as String,
            lastName: identity.lastName,
            email: identity.email,
            profilePicture: identity.profilePicture,
            streak: identity.streak);
        break;
      case 'lastName':
        updatedIdentity = UserIdentity(
            id: identity.id,
            firstName: identity.firstName,
            lastName: value as String,
            email: identity.email,
            profilePicture: identity.profilePicture,
            streak: identity.streak);
        break;
      case 'email':
        updatedIdentity = UserIdentity(
            id: identity.id,
            firstName: identity.firstName,
            lastName: identity.lastName,
            email: value as String,
            profilePicture: identity.profilePicture,
            streak: identity.streak);
        break;
      case 'profilePicture':
        updatedIdentity = UserIdentity(
            id: identity.id,
            firstName: identity.firstName,
            lastName: identity.lastName,
            email: identity.email,
            profilePicture: value as String?,
            streak: identity.streak);
        break;
      case 'streak':
        updatedIdentity = UserIdentity(
            id: identity.id,
            firstName: identity.firstName,
            lastName: identity.lastName,
            email: identity.email,
            profilePicture: identity.profilePicture,
            streak: value as int);
        break;
      case 'id':
        updatedIdentity = UserIdentity(
            id: value as int,
            firstName: identity.firstName,
            lastName: identity.lastName,
            email: identity.email,
            profilePicture: identity.profilePicture,
            streak: identity.streak);
        break;
      default:
        print("Unknown field: $field");
        return;
    }

    // Cache the updated identity
    await cacheUserIdentity(updatedIdentity);
  }

  /// Clears all user identity data (for logout)
  static Future<void> clearUserIdentity() async {
    _currentUserIdentity = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdentityKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_profilePictureKey);
    await prefs.remove(_streakKey);
  }

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

    // Also update the user identity
    final identity = UserIdentity(
        id: profile.id,
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        email: profile.email ?? '',
        profilePicture: profile.profilePicture,
        streak: await getCachedStreak());
    await cacheUserIdentity(identity);

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
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null && identity.firstName.isNotEmpty) {
      return identity.firstName;
    }

    // Fall back to the old method
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstNameKey) ?? '';
  }

  /// Gets cached user email
  static Future<String?> getCachedEmail() async {
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null && identity.email.isNotEmpty) {
      return identity.email;
    }

    // Fall back to the old method
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Gets cached user full name or default value
  static Future<String> getCachedFullName({String defaultValue = ''}) async {
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      final fullName = '${identity.firstName} ${identity.lastName}'.trim();
      return fullName.isNotEmpty ? fullName : defaultValue;
    }

    // Fall back to the old method
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey) ?? '';
    final lastName = prefs.getString(_lastNameKey) ?? '';

    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : defaultValue;
  }

  /// Gets cached profile picture URL
  static Future<String?> getCachedProfilePicture() async {
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null && identity.profilePicture != null) {
      return identity.profilePicture;
    }

    // Fall back to the old method
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
    await clearUserIdentity();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_lastUpdatedKey);
  }

  /// Cache first name separately for quick access
  static Future<void> cacheFirstName(String firstName) async {
    if (firstName.isEmpty) return;

    // Update user identity if it exists
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      await updateUserIdentityField('firstName', firstName);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
  }

  /// Cache email separately for quick access
  static Future<void> cacheEmail(String? email) async {
    if (email == null || email.isEmpty) return;

    // Update user identity if it exists
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      await updateUserIdentityField('email', email);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// Cache profile picture URL separately for quick access
  static Future<void> cacheProfilePicture(String? profilePicture) async {
    if (profilePicture == null || profilePicture.isEmpty) return;

    // Update user identity if it exists
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      await updateUserIdentityField('profilePicture', profilePicture);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, profilePicture);
  }

  /// Cache streak value separately for quick access
  static Future<void> cacheStreak(int streak) async {
    // Update user identity if it exists
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      await updateUserIdentityField('streak', streak);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);

    // Also update user_streak for consistency
    await prefs.setInt('user_streak', streak);
    print('Cached streak value: $streak (in both _streakKey and user_streak)');
  }

  /// Gets cached streak value or 0 if not found
  static Future<int> getCachedStreak() async {
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      return identity.streak;
    }

    // Fall back to the old method
    final prefs = await SharedPreferences.getInstance();

    // Check both possible keys
    final streakFromMain = prefs.getInt(_streakKey) ?? 0;
    final streakFromDirect = prefs.getInt('user_streak') ?? 0;

    // Use the higher value of the two
    final finalStreak =
        streakFromMain > streakFromDirect ? streakFromMain : streakFromDirect;

    // Sync them for future consistency
    if (streakFromMain != streakFromDirect) {
      await prefs.setInt(_streakKey, finalStreak);
      await prefs.setInt('user_streak', finalStreak);
      print(
          'Synced different streak values: $_streakKey=$streakFromMain, user_streak=$streakFromDirect → $finalStreak');
    }

    return finalStreak;
  }

  /// Cache user ID for authentication and identification
  static Future<void> cacheUserId(int userId) async {
    if (userId <= 0) return;

    // Update user identity if it exists
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      await updateUserIdentityField('id', userId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  /// Gets cached user ID or 0 if not found
  static Future<int> getCachedUserId() async {
    // First try to get from user identity
    final identity = await getCurrentUserIdentity();
    if (identity != null) {
      return identity.id;
    }

    // Fall back to the old method
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey) ?? 0;
  }
}
