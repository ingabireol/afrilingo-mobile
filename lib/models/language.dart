class Language {
  final int id;
  final String name;
  final String code;
  final String description;
  final String flagImage;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.flagImage,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'] ?? '',
      flagImage: json['flagImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'flagImage': flagImage,
    };
  }
}