import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  final List<Map<String, String>> medicines = const [
    {
      "name": "Metformin",
      "usage": "Insulin resistance, blood sugar control",
      "dosage": "500mg - 2000mg daily (as prescribed)",
      "sideEffects": "Nausea, diarrhea, stomach upset",
      "notes": "Take with meals to reduce stomach upset."
    },
    {
      "name": "Birth Control Pills",
      "usage": "Regulate menstrual cycle, reduce androgen levels",
      "dosage": "One pill daily at the same time",
      "sideEffects": "Nausea, weight changes, mood changes",
      "notes": "Must be taken consistently."
    },
    {
      "name": "Clomiphene (Clomid)",
      "usage": "Fertility treatment, induce ovulation",
      "dosage": "50mg daily for 5 days (as prescribed)",
      "sideEffects": "Hot flashes, bloating, mood swings",
      "notes": "Used under medical supervision."
    },
    {
      "name": "Spironolactone",
      "usage": "Reduce excess hair growth and acne",
      "dosage": "25mg - 200mg daily (as prescribed)",
      "sideEffects": "Irregular periods, breast tenderness",
      "notes": "Anti-androgen medication."
    },
    {
      "name": "Letrozole",
      "usage": "Fertility treatment, ovulation induction",
      "dosage": "2.5mg - 5mg daily (as prescribed)",
      "sideEffects": "Headache, dizziness, fatigue",
      "notes": "Alternative to clomiphene."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GradientHeader(
              icon: Icons.medication_liquid_outlined,
              title: 'Medicines',
              subtitle: 'Common medications for PCOD/PCOS management',
            ),
            const SizedBox(height: 16),
            Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Medical Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        SizedBox(height: 4),
                        Text(
                          'This information is for educational purposes only. Always consult your healthcare provider before starting or changing any medication.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final med = medicines[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(med['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.add_alert, color: AppColors.primary),
                            onPressed: () {
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder set for ${med["name"]}')));
                              context.push('/reminders');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Usage', med['usage']!),
                      _buildDetailRow('General Dosage', med['dosage']!),
                      _buildDetailRow('Possible Side Effects', med['sideEffects']!),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Important Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(med['notes']!, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF3E5F9), Color(0xFFE1BEE7)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Need Medical Advice?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Consult with experienced doctors for personalized treatment plans and medication guidance.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/doctor'),
                      child: const Text('Consult a Doctor'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
