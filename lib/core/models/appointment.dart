class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorUserId;
  final String doctorName;
  final String day;
  final String time;
  final DateTime? appointmentDate;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorUserId,
    required this.doctorName,
    required this.day,
    required this.time,
    this.appointmentDate,
    this.status = 'requested',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorUserId': doctorUserId,
      'doctorName': doctorName,
      'day': day,
      'time': time,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorUserId: map['doctorUserId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      day: map['day'] ?? '',
      time: map['time'] ?? '',
      appointmentDate: _parseDate(map['appointmentDate']),
      status: map['status'] ?? 'requested',
      notes: map['notes'] ?? '',
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Appointment copyWith({
    String? status,
    String? day,
    String? time,
    DateTime? appointmentDate,
    String? notes,
  }) {
    return Appointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorUserId: doctorUserId,
      doctorName: doctorName,
      day: day ?? this.day,
      time: time ?? this.time,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
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
