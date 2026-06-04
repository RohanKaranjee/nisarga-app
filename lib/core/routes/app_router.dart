import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Screens
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/complete_profile_screen.dart';

// Main Navigation & Onboarding
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';

// Informational Content Screens
import '../../presentation/screens/pcod/pcod_screen.dart';
import '../../presentation/screens/pcos/pcos_screen.dart';
import '../../presentation/screens/home_remedies/home_remedies_screen.dart';
import '../../presentation/screens/articles/articles_screen.dart';
import '../../presentation/screens/articles/article_detail_screen.dart';
import '../../presentation/screens/medicines/medicines_screen.dart';
import '../../presentation/screens/pads/pad_suggestions_screen.dart';

// Feature Screens
import '../../presentation/screens/cycle_history/cycle_history_screen.dart';
import '../../presentation/screens/reminders/reminders_screen.dart';
import '../../presentation/screens/appointments/appointments_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/prescriptions/prescriptions_screen.dart';
import '../../presentation/screens/doctor/doctor_detail_screen.dart';
import '../../presentation/screens/doctor/doctor_screen.dart';
import '../../presentation/screens/doctor/chat_screen.dart';
import '../../presentation/screens/doctor/doctor_panel_screen.dart';
import '../../presentation/screens/admin/admin_panel_screen.dart';

/// Global key for the root navigator to allow navigation without context if needed.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized Routing Configuration using the `go_router` package.
///
/// Defines all the available routes/screens in the application.
/// Uses a redirect to check auth state — if user is already logged in,
/// skip onboarding and login screens and go directly to home.
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final currentPath = state.matchedLocation;

      // If user is logged in, verify if they have completed their profile.
      if (isLoggedIn) {
        // We only check this if they are trying to access a core app page or just logged in.
        // If they are on the complete-profile page, let them stay.
        if (currentPath == '/complete-profile') return null;

        // Check if user has a profile document in Firestore
        // (Note: In a large app, you might want to cache this check or use the Provider directly,
        // but checking here ensures strict routing).
        // Since doing a Firestore read on every route change is expensive, we typically
        // just let the AuthProvider handle the /complete-profile routing after login.
        // However, to enforce it, we could check here. For now, we will trust the
        // sign-in flow to route to /complete-profile.
      }

      // If user is logged in and trying to access auth screens, redirect to home
      if (isLoggedIn &&
          (currentPath == '/onboarding' ||
              currentPath == '/login' ||
              currentPath == '/register')) {
        return '/';
      }

      // If going to onboarding, check if they've already seen it
      if (currentPath == '/onboarding' && !isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        if (hasSeenOnboarding) {
          return '/login';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // ---------------- Onboarding & Auth ----------------
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(
                initialRole: state.uri.queryParameters['role'] ?? 'patient',
              )),
      GoRoute(
          path: '/complete-profile',
          builder: (context, state) => const CompleteProfileScreen()),

      // ---------------- Main App Dashboard ----------------
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),

      // ---------------- Informational Screens ----------------
      GoRoute(path: '/pcod', builder: (context, state) => const PcodScreen()),
      GoRoute(path: '/pcos', builder: (context, state) => const PcosScreen()),
      GoRoute(
          path: '/home-remedies',
          builder: (context, state) => const HomeRemediesScreen()),
      GoRoute(
          path: '/articles',
          builder: (context, state) => const ArticlesScreen()),
      GoRoute(
          path: '/medicines',
          builder: (context, state) => const MedicinesScreen()),
      GoRoute(
          path: '/pads',
          builder: (context, state) => const PadSuggestionsScreen()),
      GoRoute(
        path: '/article-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ArticleDetailScreen(
            title: extra['title'] ?? 'Article',
            author: extra['author'] ?? '',
            readTime: extra['readTime'] ?? '',
            category: extra['category'] ?? '',
            imagePath: extra['imagePath'] ?? '',
            content: extra['content'] ?? '',
          );
        },
      ),

      // ---------------- Functional Features ----------------
      GoRoute(
          path: '/cycle-history',
          builder: (context, state) => const CycleHistoryScreen()),
      GoRoute(
          path: '/reminders',
          builder: (context, state) => const RemindersScreen()),
      GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsScreen()),
      GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen()),
      GoRoute(
          path: '/prescriptions',
          builder: (context, state) => const PrescriptionsScreen()),
      GoRoute(
          path: '/doctor-panel',
          builder: (context, state) => const DoctorPanelScreen()),
      GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminPanelScreen()),

      // ---------------- Dynamic Routes ----------------
      GoRoute(
          path: '/doctor', builder: (context, state) => const DoctorScreen()),
      GoRoute(
          path: '/doctors', builder: (context, state) => const DoctorScreen()),

      // Doctor detail screen that accepts an ID parameter
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorDetailScreen(doctorId: id);
        },
      ),

      // Realtime doctor-patient chat screen
      GoRoute(
        path: '/doctor/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final patientId = state.uri.queryParameters['patientId'];
          return ChatScreen(doctorId: id, patientId: patientId);
        },
      ),
    ],
  );
}
