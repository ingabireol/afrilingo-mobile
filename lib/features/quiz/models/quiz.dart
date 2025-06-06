class Quiz {
  final int id;
  final String title;
  final String description;
  final int minPassingScore;
  final int? lessonId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.minPassingScore,
    this.lessonId,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // Extract lessonId from different possible formats
    int? extractedLessonId;
    if (json['lesson'] is Map<String, dynamic>) {
      if (json['lesson']['id'] != null) {
        extractedLessonId = json['lesson']['id'] is int
            ? json['lesson']['id']
            : int.tryParse(json['lesson']['id'].toString());
      }
    } else if (json['lessonId'] != null) {
      extractedLessonId = json['lessonId'] is int
          ? json['lessonId']
          : int.tryParse(json['lessonId'].toString());
    }

    return Quiz(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      minPassingScore: json['minPassingScore'] is int
          ? json['minPassingScore']
          : int.tryParse(json['minPassingScore']?.toString() ?? '') ?? 0,
      lessonId: extractedLessonId,
      questions: (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minPassingScore': minPassingScore,
      'lesson': lessonId != null ? {'id': lessonId} : null,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final int id;
  final String question;
  final List<QuizOption> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<QuizOption> parsedOptions = [];

    if (json['options'] != null) {
      if (json['options'] is List) {
        final optionsList = json['options'] as List;

        parsedOptions = optionsList.map((opt) {
          // Handle case where option is a string
          if (opt is String) {
            return QuizOption(
                id: 0,
                optionText: opt,
                optionMedia: null,
                isCorrect: opt == json['correctAnswer']);
          }
          // Handle case where option is an object
          else if (opt is Map<String, dynamic>) {
            return QuizOption.fromJson(opt);
          }
          return QuizOption(
              id: 0,
              optionText: opt.toString(),
              optionMedia: null,
              isCorrect: false);
        }).toList();
      }
    }

    return Question(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      question: json['questionText']?.toString() ??
          json['question']?.toString() ??
          '',
      options: parsedOptions,
      correctAnswer: json['correctAnswer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'correctAnswer': correctAnswer,
    };
  }
}

class QuizOption {
  final int id;
  final String optionText;
  final String? optionMedia;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.optionText,
    this.optionMedia,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      optionText: json['optionText']?.toString() ?? '',
      optionMedia: json['optionMedia']?.toString(),
      isCorrect: json['isCorrect'] is bool
          ? json['isCorrect']
          : json['correct'] is bool
              ? json['correct']
              : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionText': optionText,
      'optionMedia': optionMedia,
      'isCorrect': isCorrect,
    };
  }
}

class QuizAnswer {
  final int questionId;
  final String answer;
  final int selectedOptionId;

  QuizAnswer({
    required this.questionId,
    required this.answer,
    required this.selectedOptionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'selectedOptionId': selectedOptionId,
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
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      passed: json['passed'] is bool
          ? json['passed']
          : (json['passed']?.toString() == 'true'),
      results: (json['results'] as List?)
              ?.map((r) => QuestionResult.fromJson(r))
              .toList() ??
          [],
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
      questionId: json['questionId'] is int
          ? json['questionId']
          : int.tryParse(json['questionId']?.toString() ?? '') ?? 0,
      correct: json['correct'] is bool
          ? json['correct']
          : (json['correct']?.toString() == 'true'),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString(),
    );
  }
}
