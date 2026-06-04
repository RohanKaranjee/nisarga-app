import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/appointment.dart';

void main() {
  group('Appointment Model Tests', () {
    final now = DateTime(2026, 6, 4, 12, 0, 0);

    test('toMap() should serialize correctly', () {
      final appointment = Appointment(
        id: 'app1',
        patientId: 'patient123',
        patientName: 'Jane Doe',
        doctorId: 'doc123',
        doctorUserId: 'docUser123',
        doctorName: 'Dr. Smith',
        day: 'Monday',
        time: '10:00 AM',
        appointmentDate: DateTime(2026, 6, 8),
        status: 'confirmed',
        notes: 'Follow-up visit',
        createdAt: now,
        updatedAt: now,
      );

      final map = appointment.toMap();

      expect(map['id'], 'app1');
      expect(map['patientId'], 'patient123');
      expect(map['doctorId'], 'doc123');
      expect(map['day'], 'Monday');
      expect(map['appointmentDate'], DateTime(2026, 6, 8).toIso8601String());
      expect(map['status'], 'confirmed');
      expect(map['createdAt'], now.toIso8601String());
    });

    test('fromMap() should deserialize correctly', () {
      final map = {
        'id': 'app2',
        'patientId': 'patient456',
        'patientName': 'John Doe',
        'doctorId': 'doc456',
        'doctorUserId': 'docUser456',
        'doctorName': 'Dr. Jones',
        'day': 'Tuesday',
        'time': '11:00 AM',
        'status': 'requested',
        'notes': 'First visit',
        'createdAt': '2026-06-04T10:00:00.000',
        'updatedAt': '2026-06-04T10:00:00.000',
      };

      final appointment = Appointment.fromMap(map);

      expect(appointment.id, 'app2');
      expect(appointment.patientName, 'John Doe');
      expect(appointment.doctorName, 'Dr. Jones');
      expect(appointment.appointmentDate, isNull);
      expect(appointment.status, 'requested');
      expect(appointment.createdAt, DateTime(2026, 6, 4, 10, 0, 0));
    });

    test('copyWith() should update specified fields and updatedAt', () {
      final appointment = Appointment(
        id: 'app3',
        patientId: 'p1',
        patientName: 'Pat',
        doctorId: 'd1',
        doctorUserId: 'du1',
        doctorName: 'Doc',
        day: 'Wednesday',
        time: '12:00 PM',
        status: 'requested',
        createdAt: now,
        updatedAt: now,
      );

      final updated = appointment.copyWith(
        status: 'confirmed',
        time: '01:00 PM',
      );

      expect(updated.id, 'app3');
      expect(updated.status, 'confirmed'); // Updated
      expect(updated.time, '01:00 PM'); // Updated
      expect(updated.day, 'Wednesday'); // Unchanged
      expect(updated.createdAt, now); // Unchanged
      expect(updated.updatedAt.isAfter(now), isTrue); // Should be updated to DateTime.now()
    });
  });
}
