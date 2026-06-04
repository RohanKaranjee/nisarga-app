class Reminder {
  final String id;
  final String userId;
  final String
      type; // 'period', 'ovulation', 'medicine', 'doctor', 'pad', 'water'
  final String title;
  final String time; // e.g., '09:00 AM'
  final bool enabled;
  final String notes;

  Reminder({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.time,
    this.enabled = true,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'time': time,
      'enabled': enabled,
      'notes': notes,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      enabled: map['enabled'] ?? true,
      notes: map['notes'] ?? '',
    );
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? time,
    bool? enabled,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      notes: notes ?? this.notes,
    );
  }
}
