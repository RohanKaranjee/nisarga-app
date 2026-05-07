import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Screens
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

// Main Navigation & Onboarding
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';

// Informational Content Screens
import '../../presentation/screens/pcod/pcod_screen.dart';
import '../../presentation/screens/pcos/pcos_screen.dart';
import '../../presentation/screens/home_remedies/home_remedies_screen.dart';
import '../../presentation/screens/articles/articles_screen.dart';
import '../../presentation/screens/articles/article_detail_screen.dart';

// Feature Screens
import '../../presentation/screens/cycle_history/cycle_history_screen.dart';
import '../../presentation/screens/reminders/reminders_screen.dart';
import '../../presentation/screens/doctor/doctor_detail_screen.dart';
import '../../presentation/screens/doctor/doctor_screen.dart';
import '../../presentation/screens/doctor/chat_demo_screen.dart';

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

      // If user is logged in and trying to access auth screens, redirect to home
      if (isLoggedIn && (currentPath == '/onboarding' || currentPath == '/login' || currentPath == '/register')) {
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
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      
      // ---------------- Main App Dashboard ----------------
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
      
      // ---------------- Informational Screens ----------------
      GoRoute(path: '/pcod', builder: (context, state) => const PcodScreen()),
      GoRoute(path: '/pcos', builder: (context, state) => const PcosScreen()),
      GoRoute(path: '/home-remedies', builder: (context, state) => const HomeRemediesScreen()),
      GoRoute(path: '/articles', builder: (context, state) => const ArticlesScreen()),
      GoRoute(
        path: '/article-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return ArticleDetailScreen(
            title: extra['title']!,
            author: extra['author'] ?? 'Nisarga Team',
            readTime: extra['readTime'] ?? '5 min read',
            category: extra['category'] ?? 'Health',
            imagePath: extra['imagePath'] ?? 'assets/images/articles/article_menstrual.png',
          );
        },
      ),
      
      // ---------------- Functional Features ----------------
      GoRoute(path: '/cycle-history', builder: (context, state) => const CycleHistoryScreen()),
      GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
      
      // ---------------- Dynamic Routes ----------------
      GoRoute(path: '/doctors', builder: (context, state) => const DoctorScreen()),
      
      // Doctor detail screen that accepts an ID parameter
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorDetailScreen(doctorId: id);
        },
      ),
      
      // Chat demo screen
      GoRoute(
        path: '/doctor/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatDemoScreen(doctorId: id);
        },
      ),
    ],
  );
}
