import 'language.dart';

class Course {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final Language language;
  final String difficulty;
  final bool isActive;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.language,
    required this.difficulty,
    this.isActive = true,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle different field names that might come from the API
    final languageData = json['language'];
    Language courseLanguage;
    
    if (languageData is Map<String, dynamic>) {
      courseLanguage = Language.fromJson(languageData);
    } else if (json.containsKey('languageId')) {
      // If we only have languageId, create a minimal Language object
      courseLanguage = Language(
        id: json['languageId'],
        name: 'Unknown',
        code: 'unknown',
        description: '',
        flagImage: '',
      );
    } else {
      // Fallback for mock data or unexpected format
      courseLanguage = Language(
        id: 1,
        name: 'Unknown',
        code: 'unknown',
        description: '',
        flagImage: '',
      );
    }
    
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      language: courseLanguage,
      difficulty: json['level'] ?? json['difficulty'] ?? 'BEGINNER',
      isActive: json['active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': imageUrl,
      'level': difficulty,
      'active': isActive,
      'language': {
        'id': language.id,
      },
    };
  }
}