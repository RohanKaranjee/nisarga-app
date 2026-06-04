import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/medicine.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gradient_header.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      body: StreamBuilder<List<Medicine>>(
        stream: FirestoreService().watchMedicines(),
        builder: (context, snapshot) {
          final medicines = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const GradientHeader(
                  icon: Icons.medication_liquid_outlined,
                  title: 'Medicines',
                  subtitle: 'Doctor-reviewed medicine information',
                ),
                const SizedBox(height: 16),
                _disclaimer(),
                const SizedBox(height: 20),
                if (medicines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No medicines published yet.'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medicines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _MedicineCard(medicine: medicines[index]),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/doctor'),
                    child: const Text('Consult a Doctor'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This information is educational only. Always consult a healthcare provider before starting or changing medication.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(medicine.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_alert, color: AppColors.primary),
                onPressed: () => context.push('/reminders'),
              ),
            ],
          ),
          _detail('Usage', medicine.usage),
          _detail('General Dosage', medicine.dosage),
          _detail('Possible Side Effects', medicine.sideEffects),
          if (medicine.notes.isNotEmpty) _detail('Notes', medicine.notes),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
