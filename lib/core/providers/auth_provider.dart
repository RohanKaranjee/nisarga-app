import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// State Management Provider for Authentication.
/// 
/// Manages user session, profile data from Firestore, and auth operations.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// The currently authenticated user. Null if not logged in.
  User? _user;
  
  /// User profile data from Firestore (firstName, lastName, contact, etc.)
  Map<String, dynamic>? _userProfile;
  
  bool _isLoading = true;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  
  /// Convenience getter for first name
  String get firstName => _userProfile?['firstName'] ?? user?.displayName?.split(' ').first ?? 'User';

  AuthProvider() {
    _initAuthListener();
  }

  /// Sets up a listener on Firebase Auth state changes.
  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      _isLoading = false;
      
      // Load user profile from Firestore when user logs in
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      
      notifyListeners();
    });
  }

  /// Load user profile data from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile = doc.data();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Sign up with email and save profile data to Firestore
  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? firstName,
    String? lastName,
    String? contact,
    String? address,
    DateTime? dob,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUpWithEmail(email, password);
      
      // Update Firebase Auth display name
      if (firstName != null) {
        await credential.user?.updateDisplayName('$firstName ${lastName ?? ''}');
      }
      
      // Save full profile to Firestore
      if (credential.user != null) {
        final profileData = {
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'email': email,
          'contact': contact ?? '',
          'address': address ?? '',
          'dob': dob?.toIso8601String() ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(credential.user!.uid).set(profileData);
        _userProfile = profileData;
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _userProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
