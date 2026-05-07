import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cycle_provider.dart';
import '../../core/providers/reminder_provider.dart';

// Screens that are shown in the bottom navigation bar
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'doctor/doctor_screen.dart';
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
        Provider.of<CycleProvider>(context, listen: false).loadCycleData(user.uid);
        Provider.of<ReminderProvider>(context, listen: false).loadReminders(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------- TOP APP BAR ----------------
      appBar: AppBar(
        // Use a gradient for the AppBar background to match the "soft feminine" prototype aesthetic
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nisarga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Cycle Care⁺', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                const PopupMenuItem(value: '/home-remedies', child: Text('Home Remedies')),
                const PopupMenuItem(value: '/articles', child: Text('Health Articles')),
                const PopupMenuItem(value: '/cycle-history', child: Text('Cycle History')),
                const PopupMenuItem(value: '/reminders', child: Text('Reminder Settings')),
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
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Doctor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
