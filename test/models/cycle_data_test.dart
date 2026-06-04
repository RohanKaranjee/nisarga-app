import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/cycle_data.dart';

void main() {
  group('CycleData Model Tests', () {
    final DateTime startDate = DateTime(2026, 5, 1);
    final DateTime endDate = DateTime(2026, 5, 5);

    test('toMap() should serialize correctly', () {
      final cycle = CycleData(
        id: 'cycle1',
        userId: 'user123',
        startDate: startDate,
        endDate: endDate,
        cycleLength: 28,
        notes: 'Normal cycle',
      );

      final map = cycle.toMap();

      expect(map['id'], 'cycle1');
      expect(map['userId'], 'user123');
      expect(map['startDate'], startDate.toIso8601String());
      expect(map['endDate'], endDate.toIso8601String());
      expect(map['cycleLength'], 28);
      expect(map['notes'], 'Normal cycle');
    });

    test('fromMap() should deserialize correctly', () {
      final map = {
        'id': 'cycle2',
        'userId': 'user456',
        'startDate': '2026-06-01T00:00:00.000',
        'endDate': '2026-06-06T00:00:00.000',
        'cycleLength': 30,
        'notes': 'Slightly longer',
      };

      final cycle = CycleData.fromMap(map);

      expect(cycle.id, 'cycle2');
      expect(cycle.userId, 'user456');
      expect(cycle.startDate, DateTime(2026, 6, 1));
      expect(cycle.endDate, DateTime(2026, 6, 6));
      expect(cycle.cycleLength, 30);
      expect(cycle.notes, 'Slightly longer');
    });

    test('fromMap() should handle null optional fields', () {
      final map = {
        'id': 'cycle3',
        'userId': 'user789',
        'startDate': '2026-07-01T00:00:00.000',
      };

      final cycle = CycleData.fromMap(map);

      expect(cycle.id, 'cycle3');
      expect(cycle.endDate, isNull);
      expect(cycle.cycleLength, isNull);
      expect(cycle.notes, isNull);
    });
  });
}
