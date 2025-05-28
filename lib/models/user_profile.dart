class UserProfile {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? country;
  final String? firstLanguage;
  final String? profilePicture;
  final String? reasonToLearn;
  final List<Language> languagesToLearn;
  final bool dailyReminders;
  final int dailyGoalMinutes;
  final String? preferredLearningTime;

  UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.country,
    this.firstLanguage,
    this.profilePicture,
    this.reasonToLearn,
    this.languagesToLearn = const [],
    this.dailyReminders = false,
    this.dailyGoalMinutes = 0,
    this.preferredLearningTime,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      country: json['country']?.toString(),
      firstLanguage: json['firstLanguage']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      reasonToLearn: json['reasonToLearn']?.toString(),
      languagesToLearn: (json['languagesToLearn'] as List?)?.map((e) => Language.fromJson(e)).toList() ?? [],
      dailyReminders: json['dailyReminders'] == true || json['dailyReminders']?.toString() == 'true',
      dailyGoalMinutes: json['dailyGoalMinutes'] is int ? json['dailyGoalMinutes'] : int.tryParse(json['dailyGoalMinutes']?.toString() ?? '') ?? 0,
      preferredLearningTime: json['preferredLearningTime']?.toString(),
    );
  }
}

class Language {
  final int id;
  final String? name;
  final String? code;
  final String? description;
  final String? flagImage;

  Language({
    required this.id,
    this.name,
    this.code,
    this.description,
    this.flagImage,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      flagImage: json['flagImage']?.toString(),
    );
  }
} 