class ExerciseContent {
  final String id;
  final String condition;
  final String title;
  final String description;
  final String imageUrl;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExerciseContent({
    required this.id,
    required this.condition,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'condition': condition,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'active': active,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ExerciseContent.fromMap(Map<String, dynamic> map) {
    return ExerciseContent(
      id: map['id'] ?? '',
      condition: map['condition'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      active: map['active'] ?? true,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    final dynamic timestamp = value;
    try {
      return timestamp.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
