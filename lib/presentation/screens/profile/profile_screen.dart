import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/providers/reminder_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final profile = authProvider.userProfile;
    final displayName = profile != null
        ? '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim()
        : (user?.displayName ?? user?.email?.split('@')[0] ?? 'Welcome');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, size: 60, color: AppColors.primary) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Consumer<CycleProvider>(
                          builder: (context, cycleProvider, _) => _ProfileStat(
                            label: 'Cycles Logged',
                            value: cycleProvider.currentCycle != null ? '1' : '0',
                          ),
                        ),
                        Consumer<ReminderProvider>(
                          builder: (context, reminderProvider, _) => _ProfileStat(
                            label: 'Active Reminders',
                            value: '${reminderProvider.activeReminders.length}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () => _showPersonalInfo(context, authProvider),
                      ),
                      _SettingsTile(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Health Profile',
                        onTap: () => _showHealthProfile(context),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () => context.push('/reminders'),
                      ),
                      _SettingsTile(
                        icon: Icons.alarm_outlined,
                        title: 'Reminder Settings',
                        onTap: () => context.push('/reminders'),
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (val) => themeProvider.toggleTheme(),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => _showHelpSupport(context),
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _showPrivacyPolicy(context),
                      ),
                      _SettingsTile(
                        icon: Icons.logout,
                        title: 'Log Out',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await auth.signOut();
                          if (context.mounted) context.go('/login');
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    const Text('Nisarga v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonalInfo(BuildContext context, AuthProvider authProvider) {
    final profile = authProvider.userProfile;
    final user = authProvider.user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('Personal Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _infoRow(Icons.person, 'First Name', profile?['firstName'] ?? 'Not set'),
              _infoRow(Icons.person_outline, 'Last Name', profile?['lastName'] ?? 'Not set'),
              _infoRow(Icons.email, 'Email', user?.email ?? 'Not set'),
              _infoRow(Icons.phone, 'Contact', profile?['contact'] ?? 'Not set'),
              _infoRow(Icons.location_on, 'Address', profile?['address'] ?? 'Not set'),
              _infoRow(Icons.cake, 'Date of Birth', profile?['dob'] != null && profile!['dob'].toString().isNotEmpty
                  ? profile['dob'].toString().substring(0, 10)
                  : 'Not set'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showHealthProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Health Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _infoRow(Icons.calendar_today, 'Average Cycle Length', '28 days'),
              _infoRow(Icons.water_drop, 'Average Period Duration', '5 days'),
              _infoRow(Icons.mood, 'Common Symptoms', 'Cramps, Bloating'),
              _infoRow(Icons.monitor_heart, 'Health Conditions', 'None reported'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Help & Support', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                title: const Text('Email Us'),
                subtitle: const Text('support@nisarga.app'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.question_answer_outlined, color: AppColors.primary),
                title: const Text('FAQs'),
                subtitle: const Text('Frequently asked questions'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQs coming soon!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined, color: AppColors.primary),
                title: const Text('Report a Bug'),
                subtitle: const Text('Help us improve the app'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bug report feature coming soon!')));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Last updated: May 2026\n', style: TextStyle(color: Colors.grey)),
                  const Text(
                    '1. Information We Collect\n\n'
                    'Nisarga collects the following personal information when you create an account:\n'
                    '• Name, email address, and contact number\n'
                    '• Date of birth and address\n'
                    '• Menstrual cycle data and daily symptom logs\n'
                    '• Reminder preferences\n\n'
                    '2. How We Use Your Data\n\n'
                    'Your data is used exclusively to:\n'
                    '• Provide personalized cycle predictions and health insights\n'
                    '• Send you reminders and notifications\n'
                    '• Improve app functionality and user experience\n\n'
                    '3. Data Storage\n\n'
                    'All data is stored securely on Google Firebase servers with encryption at rest and in transit. We do not sell or share your personal health data with any third parties.\n\n'
                    '4. Your Rights\n\n'
                    '• You can view, edit, or delete your personal data at any time\n'
                    '• You can request complete account deletion by contacting us\n'
                    '• You can opt-out of notifications at any time\n\n'
                    '5. Contact Us\n\n'
                    'For privacy concerns, contact: support@nisarga.app',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(children: children),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
