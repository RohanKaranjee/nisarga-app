import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/daily_log.dart';

void main() {
  group('DailyLog Model Tests', () {
    final DateTime testDate = DateTime(2026, 6, 4);

    test('toMap() should serialize correctly', () {
      final log = DailyLog(
        id: '2026-06-04',
        userId: 'user123',
        date: testDate,
        flow: 'medium',
        spotting: true,
        cramps: 'mild',
        mood: 'happy',
        energy: 'high',
        notes: 'Feeling good today',
      );

      final map = log.toMap();

      expect(map['id'], '2026-06-04');
      expect(map['userId'], 'user123');
      expect(map['date'], testDate.toIso8601String());
      expect(map['flow'], 'medium');
      expect(map['spotting'], true);
      expect(map['cramps'], 'mild');
      expect(map['mood'], 'happy');
      expect(map['energy'], 'high');
      expect(map['notes'], 'Feeling good today');
    });

    test('fromMap() should deserialize correctly', () {
      final map = {
        'id': '2026-06-05',
        'userId': 'user456',
        'date': '2026-06-05T00:00:00.000',
        'flow': 'heavy',
        'spotting': false,
        'cramps': 'severe',
        'mood': 'sad',
        'energy': 'low',
        'notes': 'Need rest',
      };

      final log = DailyLog.fromMap(map);

      expect(log.id, '2026-06-05');
      expect(log.userId, 'user456');
      expect(log.date, DateTime(2026, 6, 5));
      expect(log.flow, 'heavy');
      expect(log.spotting, false);
      expect(log.cramps, 'severe');
      expect(log.mood, 'sad');
      expect(log.energy, 'low');
      expect(log.notes, 'Need rest');
    });

    test('fromMap() should handle missing optional fields with defaults', () {
      final map = {
        'id': '2026-06-06',
        'userId': 'user789',
        'date': '2026-06-06T00:00:00.000',
      };

      final log = DailyLog.fromMap(map);

      expect(log.id, '2026-06-06');
      expect(log.flow, 'none');
      expect(log.spotting, false);
      expect(log.cramps, 'none');
      expect(log.mood, 'okay');
      expect(log.energy, 'moderate');
      expect(log.notes, '');
    });
  });
}
