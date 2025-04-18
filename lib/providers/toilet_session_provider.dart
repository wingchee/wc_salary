import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wc_salary/models/toilet_session.dart';

class ToiletSessionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _monthlySalary = 0.0;
  DateTime? _startTime;
  List<ToiletSession> _sessions = [];
  bool _isTracking = false;
  Set<String> _unlockedAchievements = {};

  // Getters
  double get monthlySalary => _monthlySalary;
  DateTime? get startTime => _startTime;
  List<ToiletSession> get sessions => _sessions;
  bool get isTracking => _isTracking;
  Set<String> get unlockedAchievements => _unlockedAchievements;

  // Total calculations
  Duration get totalDuration {
    return _sessions.fold(Duration.zero, (prev, session) => prev + session.duration);
  }

  double get totalEarnings {
    return _sessions.fold(0.0, (prev, session) => prev + session.earnedAmount);
  }

  // Sort sessions by start time (newest first)
  void _sortSessions() {
    _sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Initialize
  Future<void> initialize() async {
    if (_auth.currentUser != null) {
      // If user is authenticated, try to load data from Firebase first
      await _loadSalaryFromFirebase();
      await fetchSessions();
      await _loadAchievementsFromFirebase();
    } else {
      // If not authenticated, just load from local storage
      await _loadSalaryFromLocal();
      await _loadAchievementsFromLocal();
    }
  }

  // Set monthly salary
  Future<void> setMonthlySalary(double salary) async {
    _monthlySalary = salary;

    // Always save to local storage
    await _saveSalaryToLocal(salary);

    // If user is authenticated, also save to Firebase
    if (_auth.currentUser != null) {
      await _saveSalaryToFirebase(salary);
    }

    notifyListeners();
  }

  // Save salary to local storage
  Future<void> _saveSalaryToLocal(double salary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_salary', salary);
  }

  // Save salary to Firebase
  Future<void> _saveSalaryToFirebase(double salary) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'monthlySalary': salary,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving salary to Firebase: $e');
    }
  }

  // Load salary from local storage
  Future<void> _loadSalaryFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlySalary = prefs.getDouble('monthly_salary') ?? 0.0;
  }

  // Load salary from Firebase
  Future<void> _loadSalaryFromFirebase() async {
    if (_auth.currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      if (doc.exists && doc.data()!.containsKey('monthlySalary')) {
        final salaryValue = doc.data()!['monthlySalary'];
        // Handle both double and int types from Firebase
        if (salaryValue is double) {
          _monthlySalary = salaryValue;
        } else if (salaryValue is int) {
          _monthlySalary = salaryValue.toDouble();
        } else {
          // Try to parse as double if it's another type
          _monthlySalary = double.tryParse(salaryValue.toString()) ?? 0.0;
        }

        // Also update local storage to keep it in sync
        await _saveSalaryToLocal(_monthlySalary);
      } else {
        // If not in Firebase yet, try local storage as fallback
        await _loadSalaryFromLocal();

        // If salary is set locally, sync it to Firebase
        if (_monthlySalary > 0) {
          await _saveSalaryToFirebase(_monthlySalary);
        }
      }
    } catch (e) {
      debugPrint('Error loading salary from Firebase: $e');
      // Fallback to local storage if Firebase fails
      await _loadSalaryFromLocal();
    }
  }

  // Load salary (for backward compatibility)
  Future<void> _loadSalary() async {
    if (_auth.currentUser != null) {
      await _loadSalaryFromFirebase();
    } else {
      await _loadSalaryFromLocal();
    }
  }

  // Save achievements to local storage
  Future<void> _saveAchievementsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('achievements', _unlockedAchievements.toList());
  }

  // Load achievements from local storage
  Future<void> _loadAchievementsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final achievements = prefs.getStringList('achievements');
    if (achievements != null) {
      _unlockedAchievements = achievements.toSet();
    }
  }

  // Save achievements to Firebase
  Future<void> _saveAchievementsToFirebase() async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'achievements': _unlockedAchievements.toList(),
        'achievementsUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving achievements to Firebase: $e');
    }
  }

  // Load achievements from Firebase
  Future<void> _loadAchievementsFromFirebase() async {
    if (_auth.currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      if (doc.exists && doc.data()!.containsKey('achievements')) {
        final achievements = doc.data()!['achievements'];
        if (achievements is List) {
          _unlockedAchievements = achievements.map((e) => e.toString()).toSet();

          // Also update local storage to keep it in sync
          await _saveAchievementsToLocal();
        }
      } else {
        // If not in Firebase yet, try local storage as fallback
        await _loadAchievementsFromLocal();

        // If we have local achievements, sync them to Firebase
        if (_unlockedAchievements.isNotEmpty) {
          await _saveAchievementsToFirebase();
        }
      }
    } catch (e) {
      debugPrint('Error loading achievements from Firebase: $e');
      // Fallback to local storage if Firebase fails
      await _loadAchievementsFromLocal();
    }
  }

  // Unlock an achievement
  Future<void> unlockAchievement(String name) async {
    if (!_unlockedAchievements.contains(name)) {
      _unlockedAchievements.add(name);

      // Save to local storage
      await _saveAchievementsToLocal();

      // Save to Firebase if user is logged in
      if (_auth.currentUser != null) {
        await _saveAchievementsToFirebase();
      }

      notifyListeners();
    }
  }

  // Check if an achievement is unlocked
  bool isAchievementUnlocked(String name) {
    return _unlockedAchievements.contains(name);
  }

  // Start toilet session
  void startSession() {
    _startTime = DateTime.now();
    _isTracking = true;
    notifyListeners();
  }

  // End toilet session and calculate earnings
  Future<ToiletSession?> endSession() async {
    if (_startTime == null || !_isTracking) return null;

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);

    // Calculate earnings based on 8 working hours per day, 5 days a week
    // Monthly salary / (8 hours * 5 days * 4.33 weeks) = hourly rate
    final hourlyRate = _monthlySalary / (8 * 5 * 4.33);
    final secondRate = hourlyRate / 3600;
    final millisecondRate = secondRate / 1000;
    final earnedAmount = millisecondRate * duration.inMilliseconds;

    final session = ToiletSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _startTime!,
      endTime: endTime,
      monthlySalary: _monthlySalary,
      earnedAmount: earnedAmount,
      duration: duration,
    );

    // Reset tracking
    _startTime = null;
    _isTracking = false;

    // Save to local list
    _sessions.add(session);
    _sortSessions();

    // Save to Firestore if user is logged in
    if (_auth.currentUser != null) {
      await _saveSessionToFirestore(session);
    }

    notifyListeners();
    return session;
  }

  // Save session to Firestore
  Future<void> _saveSessionToFirestore(ToiletSession session) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('sessions')
          .doc(session.id)
          .set(session.toMap());

      // Also update total stats in the user document
      await _updateUserStats();
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  // Update user statistics in Firebase
  Future<void> _updateUserStats() async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'totalEarnings': totalEarnings,
        'totalTimeSpent': totalDuration.inSeconds,
        'sessionsCount': _sessions.length,
        'statsUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  // Sync local sessions to server after login
  Future<void> syncLocalSessionsToServer() async {
    if (_auth.currentUser == null) return;

    try {
      // Get existing session IDs from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('sessions')
          .get();

      final existingIds = snapshot.docs.map((doc) => doc.id).toSet();

      // Upload any local sessions that don't exist on the server
      int uploadCount = 0;

      for (final session in _sessions) {
        if (!existingIds.contains(session.id)) {
          await _saveSessionToFirestore(session);
          uploadCount++;
        }
      }

      // Also sync the monthly salary and achievements
      if (_monthlySalary > 0) {
        await _saveSalaryToFirebase(_monthlySalary);
      }

      if (_unlockedAchievements.isNotEmpty) {
        await _saveAchievementsToFirebase();
      }

      if (uploadCount > 0) {
        debugPrint('Uploaded $uploadCount local sessions to server');
        await _updateUserStats();
      }
    } catch (e) {
      debugPrint('Error syncing local sessions: $e');
    }
  }

  // Fetch sessions from Firestore
  Future<void> fetchSessions() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('sessions')
          .orderBy('startTime', descending: true)
          .get();

      _sessions = snapshot.docs.map((doc) => ToiletSession.fromMap(doc.data())).toList();

      // Ensure sessions are properly sorted
      _sortSessions();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
    }
  }

  // Add a session manually (for testing or importing purposes)
  Future<void> addSession(ToiletSession session) async {
    _sessions.add(session);
    _sortSessions();

    if (_auth.currentUser != null) {
      await _saveSessionToFirestore(session);
    }

    notifyListeners();
  }

  // Clear local sessions (called on sign out)
  void clearSessions() {
    _sessions = [];
    notifyListeners();
  }
}
