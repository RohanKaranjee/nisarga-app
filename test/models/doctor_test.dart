import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/doctor.dart';

void main() {
  group('Doctor Model Tests', () {
    test('toMap() should serialize correctly', () {
      final doctor = Doctor(
        id: 'doc1',
        userId: 'user1',
        name: 'Dr. John Doe',
        specialization: 'Cardiologist',
        experience: 10,
        rating: 4.8,
        reviews: 120,
        location: 'New York',
        photo: 'photo_url',
        about: 'Experienced cardiologist',
        clinic: 'Heart Care Clinic',
        fee: '150',
        status: 'approved',
        availability: [
          {'day': 'Monday', 'time': '10:00 AM - 12:00 PM'},
          {'day': 'Wednesday', 'time': '02:00 PM - 04:00 PM'}
        ],
        qualifications: ['MBBS', 'MD'],
        articles: ['article1', 'article2'],
        active: true,
      );

      final map = doctor.toMap();

      expect(map['id'], 'doc1');
      expect(map['name'], 'Dr. John Doe');
      expect(map['experience'], 10);
      expect(map['rating'], 4.8);
      expect(map['availability'], isA<List>());
      expect((map['availability'] as List).length, 2);
      expect(map['availability'][0]['day'], 'Monday');
      expect(map['qualifications'], ['MBBS', 'MD']);
    });

    test('fromMap() should deserialize correctly', () {
      final map = {
        'id': 'doc2',
        'userId': 'user2',
        'name': 'Dr. Jane Smith',
        'specialization': 'Dermatologist',
        'experience': 8,
        'rating': 4.5,
        'reviews': 80,
        'location': 'Los Angeles',
        'photo': 'photo2',
        'photoUrl': 'url2',
        'about': 'Skin specialist',
        'clinic': 'Skin Clinic',
        'fee': '100',
        'status': 'pending',
        'availability': [
          {'day': 'Tuesday', 'time': '09:00 AM - 01:00 PM'}
        ],
        'qualifications': ['MBBS', 'DDVL'],
        'articles': [],
        'active': false,
      };

      final doctor = Doctor.fromMap(map);

      expect(doctor.id, 'doc2');
      expect(doctor.name, 'Dr. Jane Smith');
      expect(doctor.experience, 8);
      expect(doctor.rating, 4.5);
      expect(doctor.availability.length, 1);
      expect(doctor.availability[0]['day'], 'Tuesday');
      expect(doctor.qualifications, ['MBBS', 'DDVL']);
      expect(doctor.active, false);
    });

    test('fromMap() should handle empty or missing lists gracefully', () {
      final map = {
        'id': 'doc3',
        'name': 'Dr. Missing Data',
        'specialization': 'General',
        'experience': 0,
        'rating': 0.0,
        'reviews': 0,
        'location': 'Unknown',
        'photo': '',
        'about': '',
        'clinic': '',
      };

      final doctor = Doctor.fromMap(map);

      expect(doctor.id, 'doc3');
      expect(doctor.availability, isEmpty);
      expect(doctor.qualifications, isEmpty);
      expect(doctor.articles, isEmpty);
      expect(doctor.active, true); // default is true
    });
  });
}
