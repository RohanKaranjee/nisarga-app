import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/core/models/appointment.dart';
import 'package:nisarga_app/core/models/cloudinary_settings.dart';
import 'package:nisarga_app/core/models/exercise_content.dart';
import 'package:nisarga_app/core/models/feedback_entry.dart';
import 'package:nisarga_app/core/models/prescription.dart';

void main() {
  test('Appointment serializes and deserializes correctly', () {
    final now = DateTime(2026, 6, 1, 10, 30);
    final appointment = Appointment(
      id: 'appointment-1',
      patientId: 'patient-1',
      patientName: 'Patient One',
      doctorId: 'doctor-1',
      doctorUserId: 'doctor-user-1',
      doctorName: 'Doctor One',
      day: 'Monday',
      time: '10:30 AM',
      status: 'requested',
      notes: 'Cramps',
      createdAt: now,
      updatedAt: now,
    );

    final restored = Appointment.fromMap(appointment.toMap());

    expect(restored.id, 'appointment-1');
    expect(restored.doctorName, 'Doctor One');
    expect(restored.day, 'Monday');
    expect(restored.time, '10:30 AM');
    expect(restored.status, 'requested');
  });

  test('Prescription serializes and deserializes correctly', () {
    final now = DateTime(2026, 6, 1, 11);
    final prescription = Prescription(
      id: 'prescription-1',
      patientId: 'patient-1',
      doctorId: 'doctor-1',
      doctorUserId: 'doctor-user-1',
      doctorName: 'Doctor One',
      appointmentId: 'appointment-1',
      medicines: const ['Medicine A', 'Medicine B'],
      notes: 'Take after meals',
      createdAt: now,
      updatedAt: now,
    );

    final restored = Prescription.fromMap(prescription.toMap());

    expect(restored.id, 'prescription-1');
    expect(restored.medicines.length, 2);
    expect(restored.notes, 'Take after meals');
  });

  test('Exercise content serializes and deserializes correctly', () {
    final exercise = ExerciseContent(
      id: 'exercise-1',
      condition: 'pcod',
      title: 'Exercise One',
      description: 'Exercise description',
      imageUrl: '',
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );

    final restored = ExerciseContent.fromMap(exercise.toMap());

    expect(restored.condition, 'pcod');
    expect(restored.title, 'Exercise One');
    expect(restored.active, true);
  });

  test('Feedback entry serializes and deserializes correctly', () {
    final now = DateTime(2026, 6, 1, 12);
    final entry = FeedbackEntry(
      id: 'feedback-1',
      userId: 'user-1',
      name: 'User One',
      email: 'user-one@nisarga.test',
      message: 'Feedback message',
      createdAt: now,
      updatedAt: now,
    );

    final restored = FeedbackEntry.fromMap(entry.toMap());

    expect(restored.userId, 'user-1');
    expect(restored.message, 'Feedback message');
    expect(restored.status, 'new');
  });

  test('Cloudinary settings serializes and deserializes correctly', () {
    final settings = CloudinarySettings(
      cloudName: 'cloud-name',
      uploadPreset: 'unsigned-preset',
      folder: 'nisarga',
      updatedAt: DateTime(2026, 6, 1),
    );

    final restored = CloudinarySettings.fromMap(settings.toMap());

    expect(restored.cloudName, 'cloud-name');
    expect(restored.uploadPreset, 'unsigned-preset');
    expect(restored.folder, 'nisarga');
    expect(restored.isConfigured, true);
  });
}
