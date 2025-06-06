import 'dart:convert';

class Language {
  final int id;
  final String name;
  final String code;
  final String? nativeName;
  final String? flagEmoji;
  final String? description;
  final String? difficulty;

  Language({
    required this.id,
    required this.name,
    required this.code,
    this.nativeName,
    this.flagEmoji,
    this.description,
    this.difficulty,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      nativeName: json['nativeName'],
      flagEmoji: json['flagEmoji'],
      description: json['description'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'nativeName': nativeName,
      'flagEmoji': flagEmoji,
      'description': description,
      'difficulty': difficulty,
    };
  }

  @override
  String toString() {
    return name;
  }
}

List<Language> parseLanguages(String responseBody) {
  final parsed = json.decode(responseBody);

  final data = parsed['data'] ?? parsed;

  if (data is List) {
    return data.map<Language>((json) => Language.fromJson(json)).toList();
  } else if (data is Map &&
      data.containsKey('content') &&
      data['content'] is List) {
    return data['content']
        .map<Language>((json) => Language.fromJson(json))
        .toList();
  }

  return [];
}
