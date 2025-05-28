class Quiz {
  final int id;
  final String title;
  final String description;
  final int minPassingScore;
  final int lessonId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.minPassingScore,
    required this.lessonId,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      minPassingScore: json['minPassingScore'] is int ? json['minPassingScore'] : int.tryParse(json['minPassingScore']?.toString() ?? '') ?? 0,
      lessonId: json['lesson'] is Map<String, dynamic>
          ? (json['lesson']['id'] is int ? json['lesson']['id'] : int.tryParse(json['lesson']['id']?.toString() ?? '') ?? 0)
          : (json['lessonId'] is int ? json['lessonId'] : int.tryParse(json['lessonId']?.toString() ?? '') ?? 0),
      questions: (json['questions'] as List?)?.map((q) => Question.fromJson(q)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minPassingScore': minPassingScore,
      'lesson': {'id': lessonId},
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List?)?.map((o) => o?.toString() ?? '').where((o) => o.isNotEmpty).toList() ?? [],
      correctAnswer: json['correctAnswer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class QuizAnswer {
  final int questionId;
  final String answer;

  QuizAnswer({
    required this.questionId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }
}

class QuizResult {
  final int score;
  final bool passed;
  final List<QuestionResult> results;

  QuizResult({
    required this.score,
    required this.passed,
    required this.results,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      passed: json['passed'] is bool ? json['passed'] : (json['passed']?.toString() == 'true'),
      results: (json['results'] as List?)?.map((r) => QuestionResult.fromJson(r)).toList() ?? [],
    );
  }
}

class QuestionResult {
  final int questionId;
  final bool correct;
  final String correctAnswer;
  final String? userAnswer;

  QuestionResult({
    required this.questionId,
    required this.correct,
    required this.correctAnswer,
    this.userAnswer,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] is int ? json['questionId'] : int.tryParse(json['questionId']?.toString() ?? '') ?? 0,
      correct: json['correct'] is bool ? json['correct'] : (json['correct']?.toString() == 'true'),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString(),
    );
  }
} 