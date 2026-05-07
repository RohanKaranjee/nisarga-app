import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/models/reminder.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/theme/app_colors.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  void _showAddReminderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddReminderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          final reminders = provider.reminders;
          final activeCount = provider.activeReminders.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientHeader(
                  icon: Icons.notifications_active_outlined,
                  title: 'Smart Reminders',
                  subtitle: 'Never miss an important health event',
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text('$activeCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const Text('Active', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text('${reminders.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddReminderDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Reminder'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Your Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                if (reminders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No reminders set yet. Click Add New Reminder to create one.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return _buildReminderCard(reminder, provider);
                    },
                  ),

                const SizedBox(height: 32),
                const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        value: true,
                        activeColor: AppColors.primary,
                        onChanged: (val) {},
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Sound'),
                        value: true,
                        activeColor: AppColors.primary,
                        onChanged: (val) {},
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Vibration'),
                        value: true,
                        activeColor: AppColors.primary,
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, ReminderProvider provider) {
    IconData getIcon(String type) {
      switch (type.toLowerCase()) {
        case 'medicine': return Icons.medication;
        case 'water': return Icons.water_drop;
        case 'doctor': return Icons.medical_services;
        default: return Icons.calendar_month;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          if (reminder.enabled)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reminder.enabled ? AppColors.primaryLight.withOpacity(0.2) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(getIcon(reminder.type), color: reminder.enabled ? AppColors.primary : Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: reminder.enabled ? Colors.black : Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: reminder.enabled ? AppColors.primary : Colors.grey),
                    const SizedBox(width: 4),
                    Text(reminder.time, style: TextStyle(color: reminder.enabled ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.enabled,
            activeColor: AppColors.primary,
            onChanged: (val) => provider.toggleReminder(reminder, val),
          ),
        ],
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  String _type = 'Medicine';
  final _titleController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();

  final List<String> _types = ['Medicine', 'Water', 'Doctor', 'Period', 'Pad'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isEmpty) return;
    
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current',
      type: _type,
      title: _titleController.text,
      time: _time.format(context),
    );
    
    Provider.of<ReminderProvider>(context, listen: false).addReminder(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
        left: 20, right: 20, top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            const Text('Add Reminder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            const Text('Reminder Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _type,
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _type = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'e.g. Take Metformin', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _time);
                if (time != null) setState(() => _time = time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_time.format(context)),
                    const Icon(Icons.schedule),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Reminder'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
