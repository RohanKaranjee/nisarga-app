import 'package:flutter/material.dart';
import '../models/cycle_data.dart';
import '../models/daily_log.dart';
import '../services/firestore_service.dart';

/// State Management Provider for Menstrual Cycle data.
///
/// Manages cycle tracking state, daily symptom logs, and provides
/// computed properties like current cycle day and days until next period.
class CycleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  CycleData? _currentCycle;
  List<CycleData> _cycleHistory = [];
  List<DailyLog> _recentLogs = [];
  DailyLog? _todaysLog;
  bool _isLoading = false;

  CycleData? get currentCycle => _currentCycle;
  List<CycleData> get cycleHistory => _cycleHistory;
  List<DailyLog> get recentLogs => _recentLogs;
  DailyLog? get todaysLog => _todaysLog;
  bool get isLoading => _isLoading;

  /// Returns the current day number within the menstrual cycle.
  /// Returns 0 if no cycle data exists.
  int get currentCycleDay {
    if (_currentCycle == null) return 0;
    final daysDiff = DateTime.now().difference(_currentCycle!.startDate).inDays;
    return daysDiff + 1; // Day 1 is the start date
  }

  /// Returns estimated days until the next period based on cycle length.
  /// Defaults to 28-day cycle if no cycle length is recorded.
  int get daysUntilPeriod {
    if (_currentCycle == null) return 0;
    final cycleLen = _currentCycle!.cycleLength ?? 28;
    final remaining = cycleLen - currentCycleDay;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns the total cycle length, defaulting to 28 if unknown.
  int get cycleLength {
    return _currentCycle?.cycleLength ?? 28;
  }

  /// Calculates the average cycle length from history.
  int get averageCycleLength {
    if (_cycleHistory.isEmpty) return 28;
    final total = _cycleHistory.fold(0, (sum, cycle) => sum + (cycle.cycleLength ?? 28));
    return (total / _cycleHistory.length).round();
  }

  /// Calculates the shortest cycle length from history.
  int get shortestCycleLength {
    if (_cycleHistory.isEmpty) return 28;
    return _cycleHistory.map((c) => c.cycleLength ?? 28).reduce((a, b) => a < b ? a : b);
  }

  /// Calculates the longest cycle length from history.
  int get longestCycleLength {
    if (_cycleHistory.isEmpty) return 28;
    return _cycleHistory.map((c) => c.cycleLength ?? 28).reduce((a, b) => a > b ? a : b);
  }

  /// Provides a fertility insight string based on cycle day.
  String get fertilityInsight {
    final day = currentCycleDay;
    if (day == 0) return 'Start tracking your cycle';
    if (day >= 10 && day <= 17) return 'High chance of fertility';
    if (day >= 1 && day <= 5) return 'Menstrual phase';
    if (day >= 6 && day <= 9) return 'Follicular phase';
    if (day >= 18 && day <= 24) return 'Luteal phase';
    return 'Premenstrual phase';
  }

  /// Loads cycle data and today's log from Firestore.
  Future<void> loadCycleData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch the most recent cycle record
      _currentCycle = await _firestoreService.getLatestCycle(userId);
      
      // Fetch full cycle history
      _cycleHistory = await _firestoreService.getAllCycles(userId);
      
      // Fetch recent daily logs (last 30 days)
      _recentLogs = await _firestoreService.getDailyLogs(userId, limit: 30);
      
      // Fetch today's specific log
      _todaysLog = await _firestoreService.getTodayLog(userId);
    } catch (e) {
      debugPrint('Error loading cycle data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves a new daily symptom log to Firestore and updates local state.
  Future<void> saveDailyLog(DailyLog log) async {
    try {
      // Update locally
      _recentLogs.insert(0, log);
      
      // If the log is for today, update todaysLog
      final today = DateTime.now();
      if (log.date.year == today.year && 
          log.date.month == today.month && 
          log.date.day == today.day) {
        _todaysLog = log;
      }
      
      notifyListeners();
      
      // Save to Firestore
      await _firestoreService.saveDailyLog(log);
    } catch (e) {
      debugPrint('Error saving daily log: $e');
    }
  }

  /// Saves a new cycle record and refreshes local state.
  Future<void> saveCycleData(CycleData cycle) async {
    try {
      await _firestoreService.saveCycleData(cycle);
      _currentCycle = cycle;
      
      // Update history list locally without full refetch
      final index = _cycleHistory.indexWhere((c) => c.id == cycle.id);
      if (index >= 0) {
        _cycleHistory[index] = cycle;
      } else {
        _cycleHistory.insert(0, cycle);
        // Ensure it's sorted descending by date
        _cycleHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving cycle data: $e');
    }
  }
}
