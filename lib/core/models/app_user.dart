class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String contact;
  final String address;
  final String gender;
  final DateTime? dob;
  final String language;
  final String role;
  final String status;
  final DateTime? createdAt;
  final List<String> fcmTokens;
  final Map<String, dynamic> notificationPreferences;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contact,
    this.address = '',
    this.gender = '',
    this.dob,
    this.language = 'English',
    this.role = 'patient',
    this.status = 'active',
    this.createdAt,
    this.fcmTokens = const [],
    this.notificationPreferences = const {},
  });

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contact': contact,
      'address': address,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'language': language,
      'role': role,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'fcmTokens': fcmTokens,
      'notificationPreferences': notificationPreferences,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? map['phone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      dob: _parseDate(map['dob']),
      language: map['language'] ?? 'English',
      role: map['role'] ?? 'patient',
      status: map['status'] ?? 'active',
      createdAt: _parseDate(map['createdAt']),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      notificationPreferences:
          Map<String, dynamic>.from(map['notificationPreferences'] ?? {}),
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
