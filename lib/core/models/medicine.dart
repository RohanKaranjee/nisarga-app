class Medicine {
  final String id;
  final String name;
  final String usage;
  final String dosage;
  final String sideEffects;
  final String notes;
  final bool active;

  Medicine({
    required this.id,
    required this.name,
    required this.usage,
    required this.dosage,
    required this.sideEffects,
    required this.notes,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'usage': usage,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'notes': notes,
      'active': active,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      usage: map['usage'] ?? '',
      dosage: map['dosage'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      notes: map['notes'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
