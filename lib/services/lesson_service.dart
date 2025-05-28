import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      try {
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception('Invalid token format');
        }
        
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
        );
        
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (DateTime.now().isAfter(expirationTime)) {
          await prefs.remove('auth_token');
          throw Exception('Token has expired');
        }
      } catch (e) {
        await prefs.remove('auth_token');
        throw Exception('Invalid authentication token');
      }
      
      return token;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await _getAuthToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Authentication required. Please log in again.');
    }
  }

  // Get lessons by course ID
  Future<List<Lesson>> getLessonsByCourseId(int courseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/course/$courseId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          List<dynamic> jsonData;
          
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') && responseData['data'] is List) {
              jsonData = responseData['data'];
            } else if (responseData.containsKey('lessons') && responseData['lessons'] is List) {
              jsonData = responseData['lessons'];
            } else {
              throw FormatException('Server response does not contain valid lesson data');
            }
          } else if (responseData is List) {
            jsonData = responseData;
          } else {
            throw FormatException('Unexpected response format from server');
          }

          return jsonData.map((json) {
            if (json is! Map<String, dynamic>) {
              throw FormatException('Invalid lesson object format');
            }
            return Lesson.fromJson(json);
          }).toList();
        } catch (e) {
          print('Error parsing lesson data: $e');
          throw FormatException('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in again.');
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching lessons from server: $e');
      if (e.toString().contains('Token has expired') || 
          e.toString().contains('Authentication required')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get lesson content
  Future<LessonContent> getLessonContent(int lessonId) async {
    try {
      final headers = await _getHeaders();
      // Get the lesson with its contents
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          Map<String, dynamic> lessonData;
          
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data')) {
              lessonData = responseData['data'];
            } else {
              lessonData = responseData;
            }
          } else {
            throw FormatException('Unexpected response format from server');
          }

          // Parse the lesson to get its contents
          final lesson = Lesson.fromJson(lessonData);
          
          // Check if the lesson has contents
          if (lesson.contents == null || lesson.contents!.isEmpty) {
            throw Exception('No content found for this lesson');
          }

          // Return the first content (or you can modify this based on your needs)
          return lesson.contents!.first;
        } catch (e) {
          print('Error parsing lesson data: $e');
          throw FormatException('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in again.');
      } else {
        throw Exception('Failed to load lesson content: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching lesson content from server: $e');
      if (e.toString().contains('Token has expired') || 
          e.toString().contains('Authentication required')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get quiz for a lesson
  Future<Quiz> getQuizForLesson(int lessonId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/quizzes/lesson/$lessonId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          return Quiz.fromJson(responseData.first);
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List && data.isNotEmpty) {
            return Quiz.fromJson(data.first);
          } else if (data is Map<String, dynamic>) {
            return Quiz.fromJson(data);
          }
        } else if (responseData is Map<String, dynamic>) {
          return Quiz.fromJson(responseData);
        }
        throw Exception('No quiz found for this lesson');
      } else {
        throw Exception('Failed to load quiz: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Submit quiz answers
  Future<QuizResult> submitQuizAnswers(int quizId, List<QuizAnswer> answers) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/$quizId/submit'),
        headers: headers,
        body: json.encode({
          'answers': answers.map((answer) => answer.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic> resultData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          resultData = responseData['data'];
        } else {
          resultData = responseData;
        }
        
        return QuizResult.fromJson(resultData);
      } else {
        throw Exception('Failed to submit quiz: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
} 