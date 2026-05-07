import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/cycle_data.dart';
import '../../widgets/daily_log_sheet.dart';

/// The Home Dashboard Screen.
/// 
/// This is the primary view users see when they open the app. It provides a summary
/// of their current menstrual cycle, shortcuts to log daily symptoms, a grid of 
/// informational content, active reminders, and featured doctors/articles.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Returns a time-based greeting string.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Personalized greeting
          _buildGreeting(context),
          const SizedBox(height: 16),

          // 1. Large gradient card showing current cycle day and predictions
          _buildCycleOverviewCard(context),
          const SizedBox(height: 16),
          
          // 2. Small summary of today's logged symptoms (flow, cramps, mood)
          _buildTodaySummary(context),
          const SizedBox(height: 16),
          
          // 3. Button to trigger the bottom sheet for logging new symptoms
          _buildLogTodayButton(context),
          const SizedBox(height: 24),
          
          const Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // 4. Grid of quick links (PCOD, PCOS, Remedies, Pads)
          _buildDashboardGrid(context),
          const SizedBox(height: 24),
          
          const Text('Smart Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // 5. Card summarizing upcoming notifications
          _buildSmartRemindersCard(context),
          const SizedBox(height: 24),
          
          // 6. Horizontally scrolling list of featured doctors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Doctors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.push('/doctors'), // Navigate to the Doctor list
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFeaturedDoctors(context),
          const SizedBox(height: 24),
          
          // 7. Featured article card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Health Articles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.push('/articles'),
                child: const Text('See More'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFeaturedArticles(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds a personalized greeting row with the user's name and time-based message.
  Widget _buildGreeting(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final name = authProvider.firstName;
        final greeting = _getGreeting();

        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $name! 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$greeting ☀️',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the top hero card containing the user's REAL cycle day and prediction.
  Widget _buildCycleOverviewCard(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final cycleDay = cycleProvider.currentCycleDay;
        final daysUntil = cycleProvider.daysUntilPeriod;
        final cycleLen = cycleProvider.cycleLength;
        final insight = cycleProvider.fertilityInsight;

        return InkWell(
          onTap: () => _selectCycleStartDate(context, cycleProvider),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient, // Uses the global pink/lavender gradient
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (cycleDay > 0)
                  Text(
                    'Day $cycleDay',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                else
                  const Column(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                    ],
                  ),
              Text(
                insight,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text('Period in', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        cycleDay > 0 ? '$daysUntil Days' : '— Days',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white30), // Vertical Divider
                  Column(
                    children: [
                      const Text('Cycle Length', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        '$cycleLen Days',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  /// Builds the prominent button that opens the `DailyLogSheet` modal.
  Widget _buildLogTodayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Display the bottom sheet for logging symptoms
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows the sheet to take up more than half the screen if needed
            backgroundColor: Colors.transparent, // Background handled by the widget itself
            builder: (context) => const DailyLogSheet(),
          );
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Log Today\'s Symptoms'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Builds a row of three small cards summarizing today's REAL logged data.
  Widget _buildTodaySummary(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final log = cycleProvider.todaysLog;

        if (log == null) {
          // Show a friendly empty state when no data exists for today
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'No symptoms logged today — tap below to log!',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Show real logged data
        return Row(
          children: [
            _summaryCard('Flow', _capitalize(log.flow), Icons.water_drop, Colors.red[300]!),
            const SizedBox(width: 8),
            _summaryCard('Cramps', _capitalize(log.cramps), Icons.bolt, Colors.orange[300]!),
            const SizedBox(width: 8),
            _summaryCard('Mood', _capitalize(log.mood), Icons.mood, Colors.blue[300]!),
          ],
        );
      },
    );
  }

  /// Helper to capitalize the first letter of a string.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Helper method to build individual small summary cards.
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  /// Builds a 2x2 grid menu for secondary informational screens.
  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true, // Essential for GridView inside a SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Disables internal scrolling
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _dashboardCard(context, 'PCOD Info', Icons.info_outline, '/pcod', AppColors.primary),
        _dashboardCard(context, 'PCOS Info', Icons.medical_information_outlined, '/pcos', Colors.teal),
        _dashboardCard(context, 'Home Remedies', Icons.spa_outlined, '/home-remedies', Colors.green),
        _dashboardCard(context, 'Health Articles', Icons.article_outlined, '/articles', Colors.deepPurple),
      ],
    );
  }

  /// Helper method to create a clickable tile for the dashboard grid.
  Widget _dashboardCard(BuildContext context, String title, IconData icon, String route, Color color) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Builds the smart reminders card using REAL data from ReminderProvider.
  Widget _buildSmartRemindersCard(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final activeCount = reminderProvider.activeReminders.length;
        final nextReminder = reminderProvider.activeReminders.isNotEmpty
            ? reminderProvider.activeReminders.first.title
            : null;

        final theme = Theme.of(context);
        return InkWell(
          onTap: () => context.push('/reminders'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeCount > 0 ? '$activeCount Active Reminder${activeCount > 1 ? 's' : ''}' : 'No Active Reminders',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        nextReminder != null ? 'Next: $nextReminder' : 'Tap to set up reminders',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedDoctors(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _doctorCard(context, 'Dr. Sarah Johnson', 'Gynecologist', '4.8', '12 yrs', 'assets/images/doctors/doctor_1.png', '1'),
          const SizedBox(width: 16),
          _doctorCard(context, 'Dr. Priya Sharma', 'PCOS Specialist', '4.9', '15 yrs', 'assets/images/doctors/doctor_2.png', '2'),
          const SizedBox(width: 16),
          _doctorCard(context, 'Dr. Kavita Desai', 'Fertility', '4.7', '10 yrs', 'assets/images/doctors/doctor_3.png', '3'),
        ],
      ),
    );
  }

  Widget _doctorCard(BuildContext context, String name, String spec, String rating, String exp, String imagePath, String id) {
    return InkWell(
      onTap: () => context.push('/doctor/$id'), 
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (e, s) {}, 
                ),
              ),
              child: const Icon(Icons.person, color: Colors.transparent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(spec, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' $rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(' • $exp', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedArticles(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _articleCard(
            context,
            'Understanding Menstrual Health: A Complete Guide',
            'Learn everything about menstrual cycles...',
            'assets/images/articles/article_menstrual.png',
          ),
          const SizedBox(width: 16),
          _articleCard(
            context,
            'Managing PCOS Symptoms Naturally',
            'Diet and lifestyle changes to help manage PCOS.',
            'assets/images/articles/article_yoga.png',
          ),
          const SizedBox(width: 16),
          _articleCard(
            context,
            'Nutrition for a Healthy Cycle',
            'What to eat during different phases of your cycle.',
            'assets/images/articles/article_nutrition.png',
          ),
        ],
      ),
    );
  }

  Widget _articleCard(BuildContext context, String title, String excerpt, String imagePath) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        context.push('/article-detail', extra: {
          'title': title,
          'author': 'Nisarga Team',
          'readTime': '5 min read',
          'category': 'Health',
          'imagePath': imagePath,
        });
      },
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: isDark ? const Color(0xFF3B284A) : const Color(0xFFF3E5F9),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      excerpt,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCycleStartDate(BuildContext context, CycleProvider cycleProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 60)), // Allow up to 60 days in past
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newCycle = CycleData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startDate: picked,
        cycleLength: 28, // Default
      );
      
      // We check if widget is still mounted before showing snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving cycle data...')),
        );
      }
      
      await cycleProvider.saveCycleData(newCycle);
    }
  }

  Widget _buildShopPadsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _padProductCard(context, 'Organic Cotton Pads', '₹299', '4.8', Icons.eco, Colors.green),
              const SizedBox(width: 12),
              _padProductCard(context, 'Menstrual Cup', '₹599', '4.9', Icons.local_drink, Colors.teal),
              const SizedBox(width: 12),
              _padProductCard(context, 'Maxi Flow Pads', '₹199', '4.5', Icons.water_drop, Colors.blue),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/pads'),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('View All Products'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _padProductCard(BuildContext context, String name, String price, String rating, IconData icon, Color color) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push('/pads'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(price, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber, size: 14),
                Text(' $rating', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
