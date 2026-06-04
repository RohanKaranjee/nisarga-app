import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/app_notification_provider.dart';
import '../../core/providers/cycle_provider.dart';
import '../../core/providers/reminder_provider.dart';
import '../../core/services/notification_service.dart';

// Screens that are shown in the bottom navigation bar
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'doctor/doctor_screen.dart';
import 'doctor/doctor_panel_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'profile/profile_screen.dart';

/// The Main Shell or Scaffold of the application after a user logs in.
///
/// This screen provides the shared App Bar (Top Navigation) and the
/// Bottom Navigation Bar. It uses an [IndexedStack] to switch between
/// the 4 core tabs (Home, Search, Doctor, Profile) without losing their state.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks which tab is currently active (0 = Home)
  int _currentIndex = 0;

  // The 4 main screens corresponding to the bottom navigation bar items
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const DoctorScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the main dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        Provider.of<CycleProvider>(context, listen: false)
            .loadCycleData(user.uid);
        Provider.of<ReminderProvider>(context, listen: false)
            .loadReminders(user.uid);
        Provider.of<AppNotificationProvider>(context, listen: false)
            .loadNotifications(user.uid);
        NotificationService().registerDeviceToken(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoading) {
      return const _AccountLoadingScreen(message: 'Loading your account...');
    }

    final needsEmailVerification =
        (authProvider.user?.email ?? '').isNotEmpty &&
            !authProvider.isEmailVerified;
    if (needsEmailVerification) {
      return _EmailVerificationScreen(authProvider: authProvider);
    }

    if (authProvider.isProfileLoading) {
      return const _AccountLoadingScreen(message: 'Loading your profile...');
    }

    if (!authProvider.hasProfile || authProvider.profileError != null) {
      return _ProfileErrorScreen(authProvider: authProvider);
    }

    if (!authProvider.isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Disabled')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your account is currently disabled. Please contact support.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (authProvider.isAdmin) {
      return const AdminPanelScreen();
    }

    if (authProvider.isDoctor) {
      return const DoctorPanelScreen();
    }

    return Scaffold(
      // ---------------- TOP APP BAR ----------------
      appBar: AppBar(
        // Use a gradient for the AppBar background to match the "soft feminine" prototype aesthetic
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nisarga',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            Text('Cycle Care+',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1.1)),
          ],
        ),
        // A three-dot menu containing quick links to secondary content
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Push the selected route using GoRouter
              context.push(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: '/pcod', child: Text('PCOD Info')),
                const PopupMenuItem(value: '/pcos', child: Text('PCOS Info')),
                const PopupMenuItem(
                    value: '/home-remedies', child: Text('Home Remedies')),
                const PopupMenuItem(
                    value: '/articles', child: Text('Health Articles')),
                const PopupMenuItem(
                    value: '/cycle-history', child: Text('Cycle History')),
                const PopupMenuItem(
                    value: '/appointments', child: Text('Appointments')),
                const PopupMenuItem(
                    value: '/prescriptions', child: Text('Prescriptions')),
                const PopupMenuItem(
                    value: '/notifications', child: Text('Notifications')),
                const PopupMenuItem(
                    value: '/reminders', child: Text('Reminder Settings')),
              ];
            },
          ),
        ],
      ),

      // ---------------- MAIN BODY ----------------
      // SafeArea prevents content from hiding behind system navigation bar
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),

      // ---------------- BOTTOM NAVIGATION ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Update the state to switch the visible screen
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'Doctor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AccountLoadingScreen extends StatelessWidget {
  final String message;

  const _AccountLoadingScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  final AuthProvider authProvider;

  const _ProfileErrorScreen({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Setup Needed')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.manage_accounts_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile not ready',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.profileError ??
                      'This account does not have an app profile yet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationScreen extends StatelessWidget {
  final AuthProvider authProvider;

  const _EmailVerificationScreen({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 72, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Verify your email address',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification link to ${authProvider.user?.email ?? 'your email'}. Open the link, then tap Check Verification.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : authProvider.refreshEmailVerification,
                    child: const Text('Check Verification'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : authProvider.resendEmailVerification,
                  child: const Text('Resend Email'),
                ),
                TextButton(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
