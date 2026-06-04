class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorUserId;
  final String doctorName;
  final String appointmentId;
  final List<String> medicines;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorUserId,
    required this.doctorName,
    this.appointmentId = '',
    required this.medicines,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorUserId': doctorUserId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'medicines': medicines,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorUserId: map['doctorUserId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      medicines: List<String>.from(map['medicines'] ?? []),
      notes: map['notes'] ?? '',
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']) ?? DateTime.now(),
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
