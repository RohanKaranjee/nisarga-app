import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cycle_data.dart';
import '../models/daily_log.dart';
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
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .get();
        
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
    final todayId = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
}
