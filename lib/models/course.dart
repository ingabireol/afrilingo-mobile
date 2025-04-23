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
    Language courseLanguage;
    
    if (json.containsKey('language') && json['language'] != null) {
      final languageData = json['language'];
      if (languageData is Map<String, dynamic>) {
        courseLanguage = Language.fromJson(languageData);
      } else {
        // Handle case where language might be an ID or other format
        courseLanguage = Language(
          id: 0,
          name: 'Unknown',
          code: 'unknown',
          description: '',
          flagImage: '',
        );
      }
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
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',  // Prioritize imageUrl over image
      language: courseLanguage,
      difficulty: json['difficulty'] ?? json['level'] ?? 'BEGINNER',  // Prioritize difficulty over level
      isActive: json['isActive'] ?? json['active'] ?? true,  // Prioritize isActive over active
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'languageId': language.id,  // Send languageId instead of full language object
      'difficulty': difficulty,
      'isActive': isActive,
    };
  }
}