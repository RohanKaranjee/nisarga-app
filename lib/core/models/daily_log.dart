/// Data Model representing a daily health and symptom log.
///
/// Contains information about bleeding flow, cramps, mood, energy levels,
/// and any custom notes the user wants to add for a specific day.
class DailyLog {
  /// Unique identifier, usually in the format 'YYYY-MM-DD'
  final String id;

  /// The ID of the user who owns this log
  final String userId;

  /// The date this log corresponds to
  final DateTime date;

  /// Bleeding flow intensity: 'light', 'medium', 'heavy', 'none'
  final String flow;

  /// Whether spotting occurred
  final bool spotting;

  /// Cramp intensity: 'none', 'mild', 'moderate', 'severe'
  final String cramps;

  /// User's mood: 'happy', 'good', 'okay', 'sad', 'anxious', 'irritable'
  final String mood;

  /// Energy levels: 'low', 'moderate', 'high'
  final String energy;

  /// Any custom text notes
  final String notes;

  DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    this.flow = 'none',
    this.spotting = false,
    this.cramps = 'none',
    this.mood = 'okay',
    this.energy = 'moderate',
    this.notes = '',
  });

  /// Converts this DailyLog object into a Map (JSON) so it can be
  /// saved to a NoSQL database like Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date
          .toIso8601String(), // Serialize DateTime to standard string format
      'flow': flow,
      'spotting': spotting,
      'cramps': cramps,
      'mood': mood,
      'energy': energy,
      'notes': notes,
    };
  }

  /// Factory constructor to create a DailyLog object from a Map (JSON)
  /// retrieved from the database.
  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']), // Deserialize string back to DateTime
      flow: map['flow'] ?? 'none',
      spotting: map['spotting'] ?? false,
      cramps: map['cramps'] ?? 'none',
      mood: map['mood'] ?? 'okay',
      energy: map['energy'] ?? 'moderate',
      notes: map['notes'] ?? '',
    );
  }
}
