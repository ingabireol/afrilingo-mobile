class Lesson {
  final int id;
  final String title;
  final String description;
  final String type;
  final int orderIndex;
  final bool isRequired;
  final int courseId;
  final List<LessonContent>? contents;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.orderIndex,
    required this.isRequired,
    required this.courseId,
    this.contents,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    try {
      List<LessonContent>? lessonContents;
      
      // Handle different possible content structures
      if (json['contents'] != null) {
        if (json['contents'] is List) {
          lessonContents = (json['contents'] as List)
              .map((content) => LessonContent.fromJson(content))
              .toList();
        } else if (json['contents'] is Map<String, dynamic>) {
          // If contents is a single object
          lessonContents = [LessonContent.fromJson(json['contents'])];
        }
      }

      return Lesson(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        title: json['title']?.toString() ?? 'Untitled Lesson',
        description: json['description']?.toString() ?? '',
        type: json['type']?.toString() ?? 'TEXT',
        orderIndex: json['orderIndex'] is int ? json['orderIndex'] : 0,
        isRequired: json['isRequired'] is bool ? json['isRequired'] : true,
        courseId: json['course'] is Map<String, dynamic> 
            ? (json['course']['id'] is int ? json['course']['id'] : int.parse(json['course']['id'].toString()))
            : (json['courseId'] is int ? json['courseId'] : int.parse(json['courseId'].toString())),
        contents: lessonContents,
      );
    } catch (e) {
      print('Error parsing lesson data: $e');
      throw FormatException('Failed to parse lesson data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'orderIndex': orderIndex,
      'isRequired': isRequired,
      'course': {'id': courseId},
      if (contents != null) 'contents': contents!.map((c) => c.toJson()).toList(),
    };
  }
}

class LessonContent {
  final int id;
  final String contentType;
  final String contentData;
  final String? mediaUrl;
  final int lessonId;
  final int? orderIndex;

  LessonContent({
    required this.id,
    required this.contentType,
    required this.contentData,
    this.mediaUrl,
    required this.lessonId,
    this.orderIndex,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different ID formats
      int parseId(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) {
          try {
            return int.parse(value);
          } catch (e) {
            return 0;
          }
        }
        return 0;
      }

      return LessonContent(
        id: parseId(json['id']),
        contentType: json['contentType']?.toString() ?? 'TEXT',
        contentData: json['contentData']?.toString() ?? '',
        mediaUrl: json['mediaUrl']?.toString(),
        lessonId: json['lesson'] is Map<String, dynamic> 
            ? parseId(json['lesson']['id'])
            : parseId(json['lessonId']),
        orderIndex: json['orderIndex'] is int ? json['orderIndex'] : null,
      );
    } catch (e) {
      print('Error parsing lesson content data: $e');
      throw FormatException('Failed to parse lesson content data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'contentData': contentData,
      'mediaUrl': mediaUrl,
      'lesson': {'id': lessonId},
      if (orderIndex != null) 'orderIndex': orderIndex,
    };
  }
} 