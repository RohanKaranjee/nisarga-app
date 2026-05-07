class CycleData {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final String? notes;

  CycleData({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'notes': notes,
    };
  }

  factory CycleData.fromMap(Map<String, dynamic> map) {
    return CycleData(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      cycleLength: map['cycleLength'],
      notes: map['notes'],
    );
  }
}
