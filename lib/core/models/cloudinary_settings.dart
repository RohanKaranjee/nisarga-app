class CloudinarySettings {
  final String cloudName;
  final String uploadPreset;
  final String folder;
  final DateTime? updatedAt;

  const CloudinarySettings({
    required this.cloudName,
    required this.uploadPreset,
    this.folder = 'nisarga',
    this.updatedAt,
  });

  bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'cloudName': cloudName.trim(),
      'uploadPreset': uploadPreset.trim(),
      'folder': folder.trim().isEmpty ? 'nisarga' : folder.trim(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CloudinarySettings.fromMap(Map<String, dynamic> map) {
    return CloudinarySettings(
      cloudName: map['cloudName'] ?? '',
      uploadPreset: map['uploadPreset'] ?? '',
      folder: map['folder'] ?? 'nisarga',
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
