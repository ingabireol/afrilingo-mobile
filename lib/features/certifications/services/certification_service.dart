import 'dart:convert';
import 'dart:typed_data';
import 'package:afrilingo/features/certifications/models/certification_models.dart';
import 'package:afrilingo/features/quiz/models/quiz.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificationService {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/certification';

  Future<Map<String, String>> _getHeaders() async {
    // Get auth token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Initiate certification session
  Future<CertificationSession> initiateCertification(String languageCode, String testLevel) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/initiate'),
      headers: headers,
      body: json.encode({
        'languageCode': languageCode,
        'testLevel': testLevel,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return CertificationSession.fromJson(data);
    } else {
      throw Exception('Failed to initiate certification: ${response.body}');
    }
  }

  // Verify test environment
  Future<void> verifyEnvironment(int sessionId, bool cameraVerified, bool environmentVerified) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/$sessionId/verify-environment?cameraVerified=$cameraVerified&environmentVerified=$environmentVerified'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify environment: ${response.body}');
    }
  }

  // Get certification questions
  Future<List<Question>> getCertificationQuestions(int sessionId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/sessions/$sessionId/questions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((q) => Question.fromJson(q)).toList();
    } else {
      throw Exception('Failed to get questions: ${response.body}');
    }
  }

  // Submit answer
  Future<void> submitAnswer(int sessionId, int questionId, int selectedOptionId, int timeSpentMs) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/$sessionId/answers'),
      headers: headers,
      body: json.encode({
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'timeSpentMs': timeSpentMs,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit answer: ${response.body}');
    }
  }

  // Complete certification
  Future<Certificate?> completeCertification(int sessionId) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/$sessionId/complete'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data != null ? Certificate.fromJson(data) : null;
    } else {
      throw Exception('Failed to complete certification: ${response.body}');
    }
  }

  // Record proctor event
  Future<void> recordProctorEvent(int sessionId, String eventType, String description, double confidenceScore) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/$sessionId/proctor-events'),
      headers: headers,
      body: json.encode({
        'eventType': eventType,
        'description': description,
        'confidenceScore': confidenceScore,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to record proctor event: ${response.body}');
    }
  }

  // Get user certificates
  Future<List<Certificate>> getUserCertificates() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/certificates'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((c) => Certificate.fromJson(c)).toList();
    } else {
      throw Exception('Failed to get certificates: ${response.body}');
    }
  }

  // Verify certificate
  Future<Certificate> verifyCertificate(String certificateId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/certificates/$certificateId/verify'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Certificate.fromJson(data);
    } else {
      throw Exception('Certificate not found or invalid');
    }
  }
}