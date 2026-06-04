import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// State Management Provider for Authentication.
///
/// Manages user session, profile data from Firestore, and auth operations.
class AuthProvider extends ChangeNotifier {
  static const Set<String> _bootstrapAdminEmails = {
    'akshatahadapad19@gmail.com',
  };

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
    final isBootstrapAdmin = _isBootstrapAdminEmail(user.email);
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
      'role': isBootstrapAdmin ? 'admin' : 'patient',
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
        final normalizedData = await _normalizeBootstrapAdminProfile(
          user,
          Map<String, dynamic>.from(data),
        );
        _userProfile = normalizedData;
        return normalizedData;
      }

      if (createIfMissing || _isBootstrapAdminEmail(user.email)) {
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
        final normalizedRole = _roleForEmail(email, requestedRole: role);
        final isDoctorAccount = normalizedRole == 'doctor';
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
          'role': normalizedRole,
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
    } finally {
      _setLoading(false);
    }
  }

  /// Complete profile for new users from provider-based sign-in.
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
          'role': _roleForEmail(
            _user!.email ?? '',
            requestedRole: _userProfile?['role']?.toString() ?? 'patient',
          ),
          'status': _isBootstrapAdminEmail(_user!.email)
              ? 'active'
              : _userProfile?['status'] ?? 'active',
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

  bool _isBootstrapAdminEmail(String? email) {
    return _bootstrapAdminEmails.contains((email ?? '').trim().toLowerCase());
  }

  String _roleForEmail(String email, {required String requestedRole}) {
    return _isBootstrapAdminEmail(email) ? 'admin' : requestedRole;
  }

  Future<Map<String, dynamic>> _normalizeBootstrapAdminProfile(
    User user,
    Map<String, dynamic> data,
  ) async {
    if (!_isBootstrapAdminEmail(user.email)) return data;
    if (data['role'] == 'admin' && data['status'] == 'active') return data;

    final normalizedData = {
      ...data,
      'id': user.uid,
      'email': user.email ?? data['email'] ?? '',
      'role': 'admin',
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(normalizedData, SetOptions(merge: true));
    normalizedData['updatedAt'] = DateTime.now().toIso8601String();
    return normalizedData;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
