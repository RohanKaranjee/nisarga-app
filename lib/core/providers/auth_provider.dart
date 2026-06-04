import 'dart:async';

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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;

  bool _isLoading = true;
  bool _isProfileLoading = false;
  String? _profileError;

  // Phone Auth State
  String? _verificationId;
  bool _isOtpSent = false;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;
  bool get isProfileLoading => _isProfileLoading;
  String? get profileError => _profileError;
  String get role => _userProfile?['role']?.toString() ?? '';
  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';
  String get accountStatus => _userProfile?['status']?.toString() ?? 'active';
  bool get isActive => accountStatus != 'disabled';
  bool get isEmailVerified => _user?.emailVerified ?? false;

  String? get verificationId => _verificationId;
  bool get isOtpSent => _isOtpSent;

  /// Convenience getter for first name
  String get firstName =>
      _userProfile?['firstName'] ??
      user?.displayName?.split(' ').first ??
      'User';

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
        _listenToUserProfile(user);
      } else {
        await _profileSubscription?.cancel();
        _profileSubscription = null;
        _userProfile = null;
        _isProfileLoading = false;
        _profileError = null;
      }

      notifyListeners();
    });
  }

  void _listenToUserProfile(User user) {
    _profileSubscription?.cancel();
    _isProfileLoading = true;
    _profileError = null;
    if (_userProfile?['id'] != user.uid) {
      _userProfile = null;
    }
    _profileSubscription =
        _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (_user?.uid != user.uid) return;
      if (doc.exists && doc.data() != null) {
        _userProfile = doc.data();
        _profileError = null;
        _isProfileLoading = false;
        notifyListeners();
        return;
      }

      _userProfile = null;
      _profileError =
          'No app profile was found for this account. Please contact admin.';
      _isProfileLoading = false;
      notifyListeners();
    }, onError: (Object error) {
      if (_user?.uid != user.uid) return;
      _userProfile = null;
      _profileError = error.toString();
      _isProfileLoading = false;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<Map<String, dynamic>> _createDefaultProfile(User user) async {
    final names = (user.displayName ?? '').trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.skip(1).join(' ') : '';
    final profileData = {
      'id': user.uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'contact': user.phoneNumber ?? '',
      'gender': '',
      'address': '',
      'language': 'English',
      'role': 'patient',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(profileData, SetOptions(merge: true));
    _userProfile = profileData;
    _profileError = null;
    return profileData;
  }

  Future<Map<String, dynamic>> _loadUserProfileOnce(
    User user, {
    bool createIfMissing = false,
  }) async {
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        _userProfile = data;
        return data;
      }

      if (createIfMissing) {
        return _createDefaultProfile(user);
      }

      throw Exception(
        'No app profile was found for this account. Please contact admin.',
      );
    } catch (e) {
      _userProfile = null;
      _profileError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
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
    String? gender,
    String role = 'patient',
    String? specialization,
    String? clinic,
    String? location,
    String? qualification,
    int? experience,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUpWithEmail(email, password);
      final user = credential.user;

      // Update Firebase Auth display name
      if (user != null && firstName != null) {
        await user.updateDisplayName('$firstName ${lastName ?? ''}');
      }

      // Save full profile to Firestore
      if (user != null) {
        final isDoctorAccount = role == 'doctor';
        final profileData = {
          'id': user.uid,
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'email': email,
          'contact': contact ?? '',
          'address': address ?? '',
          'gender': gender ?? '',
          'dob': dob?.toIso8601String() ?? '',
          'language': 'English',
          'role': role,
          'status': isDoctorAccount ? 'pending' : 'active',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(profileData);

        if (isDoctorAccount) {
          final doctorRef = _firestore.collection('doctors').doc();
          await doctorRef.set({
            'id': doctorRef.id,
            'userId': user.uid,
            'name': '$firstName ${lastName ?? ''}'.trim(),
            'specialization': specialization ?? '',
            'experience': experience ?? 0,
            'rating': 0,
            'reviews': 0,
            'location': location ?? '',
            'photo': '',
            'photoUrl': '',
            'about': '',
            'clinic': clinic ?? '',
            'fee': '',
            'status': 'pending',
            'availability': [],
            'qualifications': [
              if ((qualification ?? '').trim().isNotEmpty)
                qualification!.trim(),
            ],
            'articles': [],
            'active': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await _authService.sendEmailVerification(user);
        _userProfile = profileData;
        _profileError = null;
        _isProfileLoading = false;
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    var didSignIn = false;
    try {
      final credential = await _authService.signInWithEmail(email, password);
      await credential.user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        didSignIn = true;
        await _loadUserProfileOnce(_user!);
        _listenToUserProfile(_user!);
      }
    } catch (_) {
      if (didSignIn) {
        await _authService.signOut();
        await _profileSubscription?.cancel();
        _profileSubscription = null;
        _user = null;
        _userProfile = null;
        _profileError = null;
        _isProfileLoading = false;
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshEmailVerification() async {
    _setLoading(true);
    try {
      _user = await _authService.reloadCurrentUser();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendEmailVerification() async {
    final currentUser = _user;
    if (currentUser == null) return;
    _setLoading(true);
    try {
      await _authService.sendEmailVerification(currentUser);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) return;
    await _authService.sendPasswordResetEmail(email.trim());
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential?.user;
      if (user != null) {
        await _loadUserProfileOnce(user, createIfMissing: true);
        _listenToUserProfile(user);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      await _profileSubscription?.cancel();
      _profileSubscription = null;
      _userProfile = null;
      _profileError = null;
      _isProfileLoading = false;
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
    if (_verificationId == null) {
      throw Exception("Verification ID is null. Request a new OTP.");
    }
    _setLoading(true);
    try {
      final credential = await _authService.signInWithPhoneCredential(
          _verificationId!, smsCode);

      // Check if user has a profile in Firestore
      if (credential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        if (!doc.exists) {
          _userProfile = null;
          _profileError = null;
          _isProfileLoading = false;
          return true;
        } else {
          // User exists, load profile
          _userProfile = doc.data();
          _profileError = null;
          _isProfileLoading = false;
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
          'id': _user!.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': _user!.email ?? '',
          'phone': _user!.phoneNumber ?? '',
          'contact': contact ?? _user!.phoneNumber ?? '',
          'address': address ?? '',
          'dob': dob?.toIso8601String() ?? '',
          'gender': _userProfile?['gender'] ?? '',
          'language': _userProfile?['language'] ?? 'English',
          'role': _userProfile?['role'] ?? 'patient',
          'status': _userProfile?['status'] ?? 'active',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(_user!.uid).set(profileData);
        _userProfile = profileData;
        _profileError = null;
        _isProfileLoading = false;
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

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
