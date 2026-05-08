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

  // Phone Auth State
  String? _verificationId;
  bool _isOtpSent = false;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  
  String? get verificationId => _verificationId;
  bool get isOtpSent => _isOtpSent;
  
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
      _verificationId = null;
      _isOtpSent = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sends an OTP to the given phone number.
  Future<void> sendOtp(String phoneNumber) async {
    _setLoading(true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle auto-retrieval on Android if needed.
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          debugPrint('Verification Failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Verifies the OTP and signs in the user. 
  /// Returns `true` if the user is completely new and needs to set up their profile.
  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) throw Exception("Verification ID is null. Request a new OTP.");
    _setLoading(true);
    try {
      final credential = await _authService.signInWithPhoneCredential(_verificationId!, smsCode);
      
      // Check if user has a profile in Firestore
      if (credential.user != null) {
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (!doc.exists) {
          // User is new, needs profile completion
          return true; 
        } else {
          // User exists, load profile
          _userProfile = doc.data();
        }
      }
      return false; // User is returning
    } finally {
      _setLoading(false);
    }
  }

  /// Complete profile for new users (Phone or Google Login)
  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    String? contact,
    String? address,
    DateTime? dob,
  }) async {
    _setLoading(true);
    try {
      if (_user != null) {
        await _user!.updateDisplayName('$firstName $lastName');
        
        final profileData = {
          'firstName': firstName,
          'lastName': lastName,
          'email': _user!.email ?? '',
          'phone': _user!.phoneNumber ?? '',
          'contact': contact ?? _user!.phoneNumber ?? '',
          'address': address ?? '',
          'dob': dob?.toIso8601String() ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(_user!.uid).set(profileData);
        _userProfile = profileData;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
