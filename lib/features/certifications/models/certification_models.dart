class CertificationSession {
  final int id;
  final String sessionId;
  final String languageCode;
  final String testLevel;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int finalScore;
  final bool cameraVerified;
  final bool environmentVerified;
  final int suspiciousActivityCount;

  CertificationSession({
    required this.id,
    required this.sessionId,
    required this.languageCode,
    required this.testLevel,
    required this.startTime,
    this.endTime,
    required this.completed,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.finalScore,
    required this.cameraVerified,
    required this.environmentVerified,
    required this.suspiciousActivityCount,
  });

  factory CertificationSession.fromJson(Map<String, dynamic> json) {
    return CertificationSession(
      id: json['id'],
      sessionId: json['sessionId'],
      languageCode: json['languageCode'],
      testLevel: json['testLevel'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      completed: json['completed'],
      passed: json['passed'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      finalScore: json['finalScore'],
      cameraVerified: json['cameraVerified'],
      environmentVerified: json['environmentVerified'],
      suspiciousActivityCount: json['suspiciousActivityCount'],
    );
  }
}

class Certificate {
  final int id;
  final String certificateId;
  final String languageTested;
  final String proficiencyLevel;
  final int finalScore;
  final DateTime completedAt;
  final DateTime issuedAt;
  final String? certificateUrl;
  final bool verified;

  Certificate({
    required this.id,
    required this.certificateId,
    required this.languageTested,
    required this.proficiencyLevel,
    required this.finalScore,
    required this.completedAt,
    required this.issuedAt,
    this.certificateUrl,
    required this.verified,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      certificateId: json['certificateId'],
      languageTested: json['languageTested'],
      proficiencyLevel: json['proficiencyLevel'],
      finalScore: json['finalScore'],
      completedAt: DateTime.parse(json['completedAt']),
      issuedAt: DateTime.parse(json['issuedAt']),
      certificateUrl: json['certificateUrl'],
      verified: json['verified'],
    );
  }
}

class ProctorEvent {
  final String eventType;
  final String description;
  final DateTime timestamp;
  final double confidenceScore;
  final bool flagged;

  ProctorEvent({
    required this.eventType,
    required this.description,
    required this.timestamp,
    required this.confidenceScore,
    required this.flagged,
  });

  factory ProctorEvent.fromJson(Map<String, dynamic> json) {
    return ProctorEvent(
      eventType: json['eventType'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      confidenceScore: json['confidenceScore'],
      flagged: json['flagged'],
    );
  }
}