import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/article.dart';
import '../models/chat_message.dart';
import '../models/cloudinary_settings.dart';
import '../models/cycle_data.dart';
import '../models/daily_log.dart';
import '../models/doctor.dart';
import '../models/exercise_content.dart';
import '../models/feedback_entry.dart';
import '../models/home_remedy.dart';
import '../models/medicine.dart';
import '../models/product.dart';
import '../models/prescription.dart';
import '../models/reminder.dart';

/// Service class responsible for all Cloud Firestore database operations.
///
/// This class handles saving, updating, retrieving, and deleting data.
/// It uses a hierarchical sub-collection structure based on the `userId`
/// to ensure data privacy and organization (e.g., users/{userId}/daily_logs).
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves or updates the basic user profile information.
  /// Uses `SetOptions(merge: true)` to update existing fields without overwriting the whole document.
  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<AppUser?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return AppUser.fromMap(doc.id, data);
    });
  }

  Stream<List<AppUser>> watchUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
      users.sort((a, b) => a.displayName.compareTo(b.displayName));
      return users;
    });
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).set({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserLanguage(String uid, String language) async {
    await _db.collection('users').doc(uid).set({
      'language': language,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateNotificationPreferences(
      String uid, Map<String, dynamic> preferences) async {
    await _db.collection('users').doc(uid).set({
      'notificationPreferences': preferences,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Saves a user's daily symptom and mood log.
  /// Stored in: users/{userId}/daily_logs/{logId}
  Future<void> saveDailyLog(DailyLog log) async {
    await _db
        .collection('users')
        .doc(log.userId)
        .collection('daily_logs')
        .doc(log.id) // using YYYY-MM-DD as ID ensures only 1 log per day
        .set(log.toMap());
  }

  /// Saves menstrual cycle tracking data (start date, end date, length).
  /// Stored in: users/{userId}/cycles/{cycleId}
  Future<void> saveCycleData(CycleData cycle) async {
    await _db
        .collection('users')
        .doc(cycle.userId)
        .collection('cycles')
        .doc(cycle.id)
        .set(cycle.toMap());
  }

  /// Creates a new smart reminder (medicine, water, doctor appt).
  /// Stored in: users/{userId}/reminders/{reminderId}
  Future<void> saveReminder(Reminder reminder) async {
    await _db
        .collection('users')
        .doc(reminder.userId)
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  /// Retrieves a list of all reminders for a specific user.
  /// Maps the raw Firestore JSON documents back into [Reminder] model objects.
  Future<List<Reminder>> getReminders(String userId) async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('reminders').get();

    return snapshot.docs.map((doc) => Reminder.fromMap(doc.data())).toList();
  }

  /// Updates an existing reminder (e.g., toggling it on/off).
  Future<void> updateReminder(Reminder reminder) async {
    await _db
        .collection('users')
        .doc(reminder.userId)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  /// Deletes a specific reminder from the database.
  Future<void> deleteReminder(String userId, String reminderId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }

  /// Retrieves the most recent daily logs for a user, ordered by date descending.
  Future<List<DailyLog>> getDailyLogs(String userId, {int limit = 30}) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => DailyLog.fromMap(doc.data())).toList();
  }

  /// Retrieves today's daily log for a user, if one exists.
  Future<DailyLog?> getTodayLog(String userId) async {
    final today = DateTime.now();
    final todayId =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .doc(todayId)
        .get();

    if (doc.exists && doc.data() != null) {
      return DailyLog.fromMap(doc.data()!);
    }
    return null;
  }

  /// Retrieves the most recent cycle data for a user.
  Future<CycleData?> getLatestCycle(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return CycleData.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  /// Retrieves the entire cycle history for a user, ordered by date descending.
  Future<List<CycleData>> getAllCycles(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .orderBy('startDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => CycleData.fromMap(doc.data())).toList();
  }

  Stream<List<Reminder>> watchReminders(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) {
      final reminders =
          snapshot.docs.map((doc) => Reminder.fromMap(doc.data())).toList();
      reminders.sort((a, b) => a.time.compareTo(b.time));
      return reminders;
    });
  }

  Stream<List<DailyLog>> watchDailyLogs(String userId, {int limit = 30}) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final logs =
          snapshot.docs.map((doc) => DailyLog.fromMap(doc.data())).toList();
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    });
  }

  Stream<List<CycleData>> watchCycles(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .snapshots()
        .map((snapshot) {
      final cycles =
          snapshot.docs.map((doc) => CycleData.fromMap(doc.data())).toList();
      cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
      return cycles;
    });
  }

  Stream<List<Doctor>> watchDoctors({bool approvedOnly = true}) {
    final query = approvedOnly
        ? _db
            .collection('doctors')
            .where('active', isEqualTo: true)
            .where('status', isEqualTo: 'approved')
        : _db.collection('doctors');
    return query.snapshots().map((snapshot) {
      final doctors = snapshot.docs.map((doc) {
        return Doctor.fromMap({...doc.data(), 'id': doc.id});
      }).where((doctor) {
        if (!doctor.active) return false;
        return !approvedOnly || doctor.status == 'approved';
      }).toList();
      doctors.sort((a, b) => a.name.compareTo(b.name));
      return doctors;
    });
  }

  Stream<Doctor?> watchDoctor(String doctorId) {
    return _db.collection('doctors').doc(doctorId).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return Doctor.fromMap({...data, 'id': doc.id});
    });
  }

  Stream<Doctor?> watchDoctorForUser(String userId) {
    return _db
        .collection('doctors')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Doctor.fromMap({...doc.data(), 'id': doc.id});
    });
  }

  Future<void> saveDoctor(Doctor doctor) async {
    final docRef = doctor.id.isEmpty
        ? _db.collection('doctors').doc()
        : _db.collection('doctors').doc(doctor.id);
    final data = doctor.toMap();
    data['id'] = docRef.id;
    data['updatedAt'] = DateTime.now().toIso8601String();
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> updateDoctorStatus(
    String doctorId,
    String status, {
    String? doctorUserId,
  }) async {
    await _db.collection('doctors').doc(doctorId).set({
      'status': status,
      'active': status != 'disabled',
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    if (doctorUserId != null && doctorUserId.isNotEmpty) {
      await updateUserStatus(doctorUserId, status);
      await createNotification(AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: doctorUserId,
        title: 'Doctor account $status',
        body: _doctorStatusMessage(status),
        type: 'doctor_status',
        route: '/doctor-panel',
        createdAt: DateTime.now(),
      ));
    }
  }

  String _doctorStatusMessage(String status) {
    switch (status) {
      case 'approved':
        return 'Your doctor profile is approved and visible to patients.';
      case 'rejected':
        return 'Your doctor profile was rejected by admin.';
      case 'disabled':
        return 'Your doctor profile has been disabled.';
      default:
        return 'Your doctor profile status changed to $status.';
    }
  }

  Stream<List<Appointment>> watchAppointmentsForPatient(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(_appointmentsFromSnapshot);
  }

  Stream<List<Appointment>> watchAppointmentsForDoctorUser(
      String doctorUserId) {
    return _db
        .collection('appointments')
        .where('doctorUserId', isEqualTo: doctorUserId)
        .snapshots()
        .map(_appointmentsFromSnapshot);
  }

  Stream<List<Appointment>> watchAllAppointments() {
    return _db
        .collection('appointments')
        .snapshots()
        .map(_appointmentsFromSnapshot);
  }

  Future<void> createAppointment(Appointment appointment) async {
    final docRef = appointment.id.isEmpty
        ? _db.collection('appointments').doc()
        : _db.collection('appointments').doc(appointment.id);
    final data = appointment.toMap();
    data['id'] = docRef.id;
    await docRef.set(data);
    if (appointment.doctorUserId.isNotEmpty) {
      await _grantDoctorPatientAccess(
        doctorUserId: appointment.doctorUserId,
        patientId: appointment.patientId,
        appointmentId: docRef.id,
      );
    }
    if (appointment.doctorUserId.isNotEmpty) {
      await createNotification(AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: appointment.doctorUserId,
        title: 'New appointment request',
        body:
            '${appointment.patientName} requested ${appointment.day} at ${appointment.time}.',
        type: 'appointment',
        route: '/doctor-panel',
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> _grantDoctorPatientAccess({
    required String doctorUserId,
    required String patientId,
    required String appointmentId,
  }) async {
    await _db
        .collection('doctor_patient_access')
        .doc(doctorUserId)
        .collection('patients')
        .doc(patientId)
        .set({
      'doctorUserId': doctorUserId,
      'patientId': patientId,
      'appointmentIds': FieldValue.arrayUnion([appointmentId]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _db
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap(), SetOptions(merge: true));
    if (appointment.doctorUserId.isNotEmpty) {
      await _grantDoctorPatientAccess(
        doctorUserId: appointment.doctorUserId,
        patientId: appointment.patientId,
        appointmentId: appointment.id,
      );
    }
    await createNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: appointment.patientId,
      title: 'Appointment ${appointment.status}',
      body:
          '${appointment.doctorName} updated your ${appointment.day} ${appointment.time} appointment.',
      type: 'appointment',
      route: '/appointments',
      createdAt: DateTime.now(),
    ));
  }

  List<Appointment> _appointmentsFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final appointments = snapshot.docs.map((doc) {
      return Appointment.fromMap({...doc.data(), 'id': doc.id});
    }).toList();
    appointments.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return appointments;
  }

  String directChatId(String patientId, String doctorId) {
    return '${patientId}_$doctorId';
  }

  Stream<List<CycleData>> watchPatientCycles(String patientId) {
    return watchCycles(patientId);
  }

  Stream<List<DailyLog>> watchPatientDailyLogs(String patientId,
      {int limit = 30}) {
    return watchDailyLogs(patientId, limit: limit);
  }

  Stream<List<Prescription>> watchPrescriptionsForPatient(String patientId) {
    return _db
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(_prescriptionsFromSnapshot);
  }

  Stream<List<Prescription>> watchPrescriptionsForDoctorUser(
      String doctorUserId) {
    return _db
        .collection('prescriptions')
        .where('doctorUserId', isEqualTo: doctorUserId)
        .snapshots()
        .map(_prescriptionsFromSnapshot);
  }

  Future<void> savePrescription(Prescription prescription) async {
    final docRef = prescription.id.isEmpty
        ? _db.collection('prescriptions').doc()
        : _db.collection('prescriptions').doc(prescription.id);
    final data = prescription.toMap();
    data['id'] = docRef.id;
    data['updatedAt'] = DateTime.now().toIso8601String();
    await docRef.set(data, SetOptions(merge: true));
    await createNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: prescription.patientId,
      title: 'New prescription',
      body: '${prescription.doctorName} added a prescription for you.',
      type: 'prescription',
      route: '/prescriptions',
      createdAt: DateTime.now(),
    ));
  }

  List<Prescription> _prescriptionsFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final prescriptions = snapshot.docs.map((doc) {
      return Prescription.fromMap({...doc.data(), 'id': doc.id});
    }).toList();
    prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return prescriptions;
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        return ChatMessage.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return messages;
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String recipientId,
    required String text,
    required String route,
  }) async {
    final messageRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    final now = DateTime.now();
    final message = ChatMessage(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      senderRole: senderRole,
      text: text,
      sentAt: now,
    );

    final participants =
        recipientId.isEmpty ? [senderId] : [senderId, recipientId];
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.set({
      'id': chatId,
      'participants': FieldValue.arrayUnion(participants),
      'lastMessage': text,
      'lastMessageAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    }, SetOptions(merge: true));
    await messageRef.set(message.toMap());

    if (recipientId.isNotEmpty) {
      await createNotification(AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: recipientId,
        title: 'New message',
        body: text,
        type: 'chat',
        route: route,
        createdAt: now,
      ));
    }
  }

  Stream<List<Article>> watchArticles({bool activeOnly = true}) {
    final query = activeOnly
        ? _db.collection('articles').where('active', isEqualTo: true)
        : _db.collection('articles');
    return query.snapshots().map((snapshot) {
      final articles = snapshot.docs.map((doc) {
        return Article.fromMap({...doc.data(), 'id': doc.id});
      }).where((article) {
        return !activeOnly || article.active;
      }).toList();
      articles.sort((a, b) => b.date.compareTo(a.date));
      return articles;
    });
  }

  Stream<List<Medicine>> watchMedicines({bool activeOnly = true}) {
    final query = activeOnly
        ? _db.collection('medicines').where('active', isEqualTo: true)
        : _db.collection('medicines');
    return query.snapshots().map((snapshot) {
      final medicines = snapshot.docs.map((doc) {
        return Medicine.fromMap({...doc.data(), 'id': doc.id});
      }).where((medicine) {
        return !activeOnly || medicine.active;
      }).toList();
      medicines.sort((a, b) => a.name.compareTo(b.name));
      return medicines;
    });
  }

  Stream<List<Product>> watchProducts({bool activeOnly = true}) {
    final query = activeOnly
        ? _db.collection('products').where('active', isEqualTo: true)
        : _db.collection('products');
    return query.snapshots().map((snapshot) {
      final products = snapshot.docs.map((doc) {
        return Product.fromMap({...doc.data(), 'id': doc.id});
      }).where((product) {
        return !activeOnly || product.active;
      }).toList();
      products.sort((a, b) => a.name.compareTo(b.name));
      return products;
    });
  }

  Stream<List<HomeRemedy>> watchHomeRemedies({bool activeOnly = true}) {
    final query = activeOnly
        ? _db.collection('home_remedies').where('active', isEqualTo: true)
        : _db.collection('home_remedies');
    return query.snapshots().map((snapshot) {
      final remedies = snapshot.docs.map((doc) {
        return HomeRemedy.fromMap({...doc.data(), 'id': doc.id});
      }).where((remedy) {
        return !activeOnly || remedy.active;
      }).toList();
      remedies.sort((a, b) => a.title.compareTo(b.title));
      return remedies;
    });
  }

  Stream<List<ExerciseContent>> watchExercises(String condition,
      {bool activeOnly = true}) {
    final query = activeOnly
        ? _db
            .collection('exercises')
            .where('condition', isEqualTo: condition)
            .where('active', isEqualTo: true)
        : _db.collection('exercises').where('condition', isEqualTo: condition);
    return query.snapshots().map((snapshot) {
      final exercises = snapshot.docs.map((doc) {
        return ExerciseContent.fromMap({...doc.data(), 'id': doc.id});
      }).where((exercise) {
        return !activeOnly || exercise.active;
      }).toList();
      exercises.sort((a, b) => a.title.compareTo(b.title));
      return exercises;
    });
  }

  Stream<List<ExerciseContent>> watchAllExercises() {
    return _db.collection('exercises').snapshots().map((snapshot) {
      final exercises = snapshot.docs.map((doc) {
        return ExerciseContent.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
      exercises.sort((a, b) => a.condition.compareTo(b.condition));
      return exercises;
    });
  }

  Future<void> saveArticle(Article article) async {
    await _saveGlobalContent('articles', article.id, article.toMap());
  }

  Future<void> saveMedicine(Medicine medicine) async {
    await _saveGlobalContent('medicines', medicine.id, medicine.toMap());
  }

  Future<void> saveProduct(Product product) async {
    await _saveGlobalContent('products', product.id, product.toMap());
  }

  Future<void> saveHomeRemedy(HomeRemedy remedy) async {
    await _saveGlobalContent('home_remedies', remedy.id, remedy.toMap());
  }

  Future<void> saveExercise(ExerciseContent exercise) async {
    await _saveGlobalContent('exercises', exercise.id, exercise.toMap());
  }

  Future<void> deleteGlobalContent(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<CloudinarySettings?> watchCloudinarySettings() {
    return _db.collection('settings').doc('cloudinary').snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return CloudinarySettings.fromMap(data);
    });
  }

  Future<CloudinarySettings?> getCloudinarySettings() async {
    final doc = await _db.collection('settings').doc('cloudinary').get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return CloudinarySettings.fromMap(data);
  }

  Future<void> saveCloudinarySettings(CloudinarySettings settings) async {
    await _db.collection('settings').doc('cloudinary').set({
      ...settings.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Stream<List<FeedbackEntry>> watchFeedbackEntries() {
    return _db.collection('feedback').snapshots().map((snapshot) {
      final entries = snapshot.docs.map((doc) {
        return FeedbackEntry.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    });
  }

  Future<void> submitFeedback(FeedbackEntry entry) async {
    final docRef = entry.id.isEmpty
        ? _db.collection('feedback').doc()
        : _db.collection('feedback').doc(entry.id);
    final data = entry.toMap();
    data['id'] = docRef.id;
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    await _db.collection('feedback').doc(feedbackId).set({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> _saveGlobalContent(
      String collection, String id, Map<String, dynamic> data) async {
    final docRef = id.isEmpty
        ? _db.collection(collection).doc()
        : _db.collection(collection).doc(id);
    data['id'] = docRef.id;
    data['updatedAt'] = DateTime.now().toIso8601String();
    await docRef.set(data, SetOptions(merge: true));
  }

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        return AppNotification.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  Future<void> createNotification(AppNotification notification) async {
    await _db
        .collection('users')
        .doc(notification.userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> markNotificationRead(
      String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({'read': true}, SetOptions(merge: true));
  }
}
