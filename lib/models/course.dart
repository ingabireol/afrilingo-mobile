import 'language.dart';

class Course {
  final int id;
  final String title;
  final String description;
  final String image;
  final Language language;
  final String difficulty;
  final bool isActive;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.language,
    required this.difficulty,
    this.isActive = true,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
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
          id: json['languageId'] is int ? json['languageId'] : 0,
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
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        title: json['title']?.toString() ?? 'Untitled Course',
        description: json['description']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
      language: courseLanguage,
        difficulty: json['difficulty']?.toString() ?? 'Beginner',
        isActive: json['isActive'] is bool ? json['isActive'] : true,
    );
    } catch (e) {
      print('Error parsing course data: $e');
      throw FormatException('Failed to parse course data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'language': language.toJson(),
      'difficulty': difficulty,
      'isActive': isActive,
    };
  }
}