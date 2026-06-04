import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/exercise_content_section.dart';

class PcosScreen extends StatelessWidget {
  const PcosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCOS Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientHeader(
              icon: Icons.medical_information_outlined,
              title: 'PCOS Overview',
              subtitle: 'Comprehensive guide to Polycystic Ovary Syndrome',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Important Note',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange)),
                        SizedBox(height: 4),
                        Text(
                          'PCOS is a serious metabolic condition that requires medical supervision. Please consult a healthcare provider for proper diagnosis and treatment.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ExpandableSection(
              title: 'What is PCOS?',
              content:
                  'Polycystic Ovary Syndrome (PCOS) is a hormonal disorder affecting women of reproductive age. It is characterized by irregular periods, excess androgen levels, and polycystic ovaries. PCOS is more severe than PCOD and affects overall health.',
            ),
            const ExpandableSection(
              title: 'Causes',
              content:
                  'Linked to insulin resistance, inflammation, heredity, and excess androgen production.',
            ),
            const ExpandableSection(
              title: 'Symptoms',
              content:
                  'Irregular/absent periods, severe acne, male-pattern baldness, weight gain especially around the abdomen, darkening of skin, and fertility issues.',
            ),
            const ExpandableSection(
              title: 'Diagnosis Methods',
              content:
                  'Physical examination, blood tests for hormone levels and glucose tolerance, pelvic ultrasound.',
            ),
            const ExpandableSection(
              title: 'Treatment Options',
              content:
                  'Combination birth control pills, metformin for insulin resistance, clomiphene for fertility, hair removal treatments.',
            ),
            const ExpandableSection(
              title: 'Lifestyle Solutions',
              content:
                  'Weight management is crucial - even 5-10% weight loss can improve symptoms. Regular exercise, stress reduction.',
            ),
            const SizedBox(height: 24),
            const ExerciseContentSection(condition: 'pcos'),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ExpandableSection(
              title: "What's the difference between PCOD and PCOS?",
              content:
                  'PCOD is a condition where ovaries produce immature eggs. PCOS is a metabolic disorder with more severe symptoms affecting overall health.',
            ),
            const ExpandableSection(
              title: 'Can PCOS cause diabetes?',
              content:
                  'Yes, women with PCOS have higher risk of developing type 2 diabetes due to insulin resistance.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFF3E5F9), Color(0xFFE1BEE7)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('When to Consult a Doctor',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Seek medical attention if you have irregular periods, signs of excess androgens, difficulty losing weight, or trouble conceiving.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/doctor'),
                      child: const Text('Find a Doctor'),
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
}
