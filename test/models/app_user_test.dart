import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/app_user.dart';

void main() {
  group('AppUser Model Tests', () {
    test('displayName should combine firstName and lastName', () {
      const user = AppUser(
        id: '1',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        contact: '1234567890',
      );

      expect(user.displayName, 'Jane Doe');
    });

    test('displayName should fallback to email if names are empty', () {
      const user = AppUser(
        id: '2',
        firstName: '',
        lastName: '',
        email: 'jane@example.com',
        contact: '1234567890',
      );

      expect(user.displayName, 'jane@example.com');
    });

    test('toMap() should serialize correctly', () {
      final dob = DateTime(1990, 1, 1);
      final createdAt = DateTime(2026, 1, 1);

      final user = AppUser(
        id: 'user123',
        firstName: 'Alice',
        lastName: 'Smith',
        email: 'alice@example.com',
        contact: '9876543210',
        address: '123 Main St',
        gender: 'Female',
        dob: dob,
        language: 'English',
        role: 'patient',
        status: 'active',
        createdAt: createdAt,
        fcmTokens: ['token1', 'token2'],
        notificationPreferences: {'email': true, 'push': false},
      );

      final map = user.toMap();

      expect(map['id'], 'user123');
      expect(map['firstName'], 'Alice');
      expect(map['lastName'], 'Smith');
      expect(map['email'], 'alice@example.com');
      expect(map['contact'], '9876543210');
      expect(map['address'], '123 Main St');
      expect(map['gender'], 'Female');
      expect(map['dob'], dob.toIso8601String());
      expect(map['role'], 'patient');
      expect(map['fcmTokens'], ['token1', 'token2']);
      expect(map['notificationPreferences'], {'email': true, 'push': false});
    });

    test('fromMap() should deserialize correctly', () {
      final map = {
        'firstName': 'Bob',
        'lastName': 'Jones',
        'email': 'bob@example.com',
        'contact': '5551234567',
        'address': '456 Side St',
        'gender': 'Male',
        'dob': '1985-05-15T00:00:00.000',
        'language': 'Spanish',
        'role': 'doctor',
        'status': 'pending',
        'createdAt': '2026-06-01T12:00:00.000',
        'fcmTokens': ['token3'],
        'notificationPreferences': {'sms': true},
      };

      final user = AppUser.fromMap('user456', map);

      expect(user.id, 'user456');
      expect(user.firstName, 'Bob');
      expect(user.lastName, 'Jones');
      expect(user.role, 'doctor');
      expect(user.status, 'pending');
      expect(user.language, 'Spanish');
      expect(user.fcmTokens, ['token3']);
      expect(user.notificationPreferences, {'sms': true});
      expect(user.dob, DateTime(1985, 5, 15));
    });
  });
}
