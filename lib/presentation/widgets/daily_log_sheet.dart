import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/theme/app_colors.dart';

/// A Bottom Sheet widget for logging daily symptoms.
/// 
/// This widget is displayed over the `HomeScreen` and allows the user to
/// track their bleeding flow, spotting, cramps, mood, energy levels, and custom notes.
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
  bool _spotting = false;
  String _cramps = 'none';
  String _mood = 'okay';
  final _notesController = TextEditingController();

  int _currentStep = 0;
  final List<String> _selectedRemedies = [];
  final List<String> _remediesList = [
    'Hot water',
    'Banana',
    'Turmeric Milk',
    'Black chocolate',
    'Ginger Tea',
    'Fenugreek Seeds & Hot water'
  ];


  // Pre-defined options for the ChoiceChips
  final List<String> _flows = ['none', 'light', 'medium', 'heavy'];
  final List<String> _crampLevels = ['none', 'mild', 'moderate', 'severe'];
  final List<String> _moods = ['happy', 'good', 'okay', 'sad', 'anxious', 'irritable'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Triggers when the user clicks "Save Log".
  /// Packages the form data into a [DailyLog] model and passes it to the Provider.
  void _saveLog() async {
    // Get the real Firebase user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;
    
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first!')),
      );
      return;
    }

    // Generate an ID based on current date 'YYYY-MM-DD'
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    String finalNotes = _notesController.text;
    if (_selectedRemedies.isNotEmpty) {
      finalNotes += finalNotes.isEmpty ? 'Remedies: ' : '\nRemedies: ';
      finalNotes += _selectedRemedies.join(', ');
    }

    // Create the data model with the REAL user ID
    final log = DailyLog(
      id: dateStr,
      userId: uid,
      date: now,
      flow: _flow,
      spotting: _spotting,
      cramps: _cramps,
      mood: _mood,
      energy: 'moderate',
      notes: finalNotes,
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
          content: Text('✅ Daily log saved successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // Padding handles the notch, safe area, and keyboard pushing the UI up
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
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
          mainAxisSize: MainAxisSize.min, // Ensures the sheet only takes up as much height as needed
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
              const Text('Bleeding Flow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _flows.map((f) => ChoiceChip(
                  label: Text(f.capitalize()),
                  selected: _flow == f,
                  onSelected: (selected) {
                    if (selected) setState(() => _flow = f);
                  },
                  selectedColor: AppColors.primaryLight.withOpacity(0.5),
                )).toList(),
              ),

              // ---------------- SPOTTING SECTION ----------------
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Spotting', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _spotting,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _spotting = val ?? false);
                },
              ),

              // ---------------- CRAMPS SECTION ----------------
              const SizedBox(height: 10),
              const Text('Cramps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _crampLevels.map((c) => ChoiceChip(
                  label: Text(c.capitalize()),
                  selected: _cramps == c,
                  onSelected: (selected) {
                    if (selected) setState(() => _cramps = c);
                  },
                  selectedColor: AppColors.primaryLight.withOpacity(0.5),
                )).toList(),
              ),

              // ---------------- MOOD SECTION ----------------
              const SizedBox(height: 20),
              const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moods.map((m) => ChoiceChip(
                  label: Text(m.capitalize()),
                  selected: _mood == m,
                  onSelected: (selected) {
                    if (selected) setState(() => _mood = m);
                  },
                  selectedColor: AppColors.primaryLight.withOpacity(0.5),
                )).toList(),
              ),


              // ---------------- NOTES SECTION ----------------
              const SizedBox(height: 20),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  const Text('Select Remedies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              ..._remediesList.map((remedy) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(remedy),
                  value: _selectedRemedies.contains(remedy),
                  activeColor: AppColors.primary,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedRemedies.add(remedy);
                      } else {
                        _selectedRemedies.remove(remedy);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLog,
                  child: const Text('Save Log'),
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
