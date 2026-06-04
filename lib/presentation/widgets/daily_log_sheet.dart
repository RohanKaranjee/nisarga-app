import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/theme/app_colors.dart';

/// A Bottom Sheet widget for logging daily symptoms.
///
/// This widget is displayed over the `HomeScreen` and allows the user to
/// track their bleeding flow, cramps, mood, energy levels, and custom notes.
/// The state is handled locally here until the user hits "Save",
/// at which point it's sent to the [CycleProvider] and Firestore.
class DailyLogSheet extends StatefulWidget {
  const DailyLogSheet({super.key});

  @override
  State<DailyLogSheet> createState() => _DailyLogSheetState();
}

class _DailyLogSheetState extends State<DailyLogSheet> {
  // Local state variables for the form
  String _flow = 'none';
  String _cramps = 'none';
  String _mood = 'okay';
  final _notesController = TextEditingController();

  int _currentStep = 0;
  final List<String> _remediesList = [
    'Hot water',
    'Banana',
    'Turmeric milk',
    'Black chocolate',
    'Ginger tea',
    'Fenugreek seeds + hot water'
  ];

  // Pre-defined options for the ChoiceChips
  final List<String> _flows = ['none', 'light', 'medium', 'heavy'];
  final List<String> _crampLevels = ['none', 'mild', 'moderate', 'severe'];
  final List<String> _moods = [
    'happy',
    'good',
    'okay',
    'sad',
    'anxious',
    'irritable'
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Triggers when the user clicks "Save Log".
  /// Packages the form data into a [DailyLog] model and passes it to the Provider.
  void _saveLog() async {
    if (_isSaving) return;

    // Get the real Firebase user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Generate an ID based on current date 'YYYY-MM-DD'
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Create the data model with the REAL user ID
      final log = DailyLog(
        id: dateStr,
        userId: uid,
        date: now,
        flow: _flow,
        spotting: false,
        cramps: _cramps,
        mood: _mood,
        energy: 'moderate',
        notes: _notesController.text,
      );

      // Save using provider
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      await cycleProvider.saveDailyLog(log);

      // Refresh all data so the home screen updates immediately
      await cycleProvider.loadCycleData(uid);

      // Close the bottom sheet
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily log saved successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save log: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // Padding handles the notch, safe area, and keyboard pushing the UI up
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Ensures the sheet only takes up as much height as needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gray Handle bar at the top of the sheet
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log Today',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            if (_currentStep == 0) ...[
              // ---------------- FLOW SECTION ----------------
              const SizedBox(height: 10),
              Text('Bleeding Flow',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _flows
                    .map((f) => ChoiceChip(
                          label: Text(f.capitalize()),
                          selected: _flow == f,
                          onSelected: (selected) {
                            if (selected) setState(() => _flow = f);
                          },
                          selectedColor:
                              AppColors.primaryLight.withValues(alpha: 0.5),
                        ))
                    .toList(),
              ),

              // ---------------- CRAMPS SECTION ----------------
              const SizedBox(height: 10),
              Text('Cramps',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _crampLevels
                    .map((c) => ChoiceChip(
                          label: Text(c.capitalize()),
                          selected: _cramps == c,
                          onSelected: (selected) {
                            if (selected) setState(() => _cramps = c);
                          },
                          selectedColor:
                              AppColors.primaryLight.withValues(alpha: 0.5),
                        ))
                    .toList(),
              ),

              // ---------------- MOOD SECTION ----------------
              const SizedBox(height: 20),
              Text('Mood',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moods
                    .map((m) => ChoiceChip(
                          label: Text(m.capitalize()),
                          selected: _mood == m,
                          onSelected: (selected) {
                            if (selected) setState(() => _mood = m);
                          },
                          selectedColor:
                              AppColors.primaryLight.withValues(alpha: 0.5),
                        ))
                    .toList(),
              ),

              // ---------------- NOTES SECTION ----------------
              const SizedBox(height: 20),
              Text('Notes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any other symptoms or notes?',
                ),
              ),

              const SizedBox(height: 20),
              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // ---------------- REMEDIES SECTION ----------------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                  const Text('Home Remedies',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              ..._remediesList.map((remedy) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Icon(Icons.circle,
                              size: 8, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            remedy,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLog,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Log'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Extension method to easily capitalize the first letter of strings used in UI.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
