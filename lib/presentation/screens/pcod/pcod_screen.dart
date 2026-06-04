import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/exercise_content_section.dart';

class PcodScreen extends StatelessWidget {
  const PcodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCOD Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientHeader(
              icon: Icons.monitor_weight_outlined,
              title: 'PCOD Overview',
              subtitle: 'Comprehensive guide to Polycystic Ovarian Disease',
            ),
            const SizedBox(height: 24),
            const ExpandableSection(
              title: 'What is PCOD?',
              content:
                  'Polycystic Ovarian Disease (PCOD) is a condition where the ovaries release a lot of immature or partially-mature eggs which eventually turn into cysts.',
            ),
            const ExpandableSection(
              title: 'Causes',
              content:
                  'The exact cause is unknown, but factors include excess insulin, low-grade inflammation, heredity, and excess androgen production.',
            ),
            const ExpandableSection(
              title: 'Symptoms',
              content:
                  'Irregular periods, heavy bleeding, hair growth on face/body, acne, weight gain, and male-pattern baldness.',
            ),
            const ExpandableSection(
              title: 'Diagnosis Methods',
              content:
                  'Blood tests for hormone levels, pelvic ultrasound to check ovaries, and physical examination.',
            ),
            const ExpandableSection(
              title: 'Treatment Options',
              content:
                  'Lifestyle changes, weight loss, medication for regulating periods, and fertility treatments if trying to conceive.',
            ),
            const ExpandableSection(
              title: 'Lifestyle Solutions',
              content:
                  'Maintain a healthy weight, regular exercise, stress management, and proper sleep schedule.',
            ),
            const ExpandableSection(
              title: 'Diet Suggestions',
              content:
                  'High fiber foods, lean proteins, anti-inflammatory foods. Avoid refined carbs, sugary drinks, and processed meats.',
            ),
            const ExpandableSection(
              title: 'Exercise Recommendations',
              content:
                  'Moderate exercise 30 minutes a day, strength training, yoga, and walking.',
            ),
            const SizedBox(height: 24),
            const ExerciseContentSection(condition: 'pcod'),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ExpandableSection(
              title: 'Can PCOD be cured?',
              content:
                  'There is no permanent cure, but symptoms can be managed effectively through lifestyle changes and medication.',
            ),
            const ExpandableSection(
              title: 'Can I get pregnant with PCOD?',
              content:
                  'Yes, many women with PCOD conceive naturally or with the help of fertility treatments.',
            ),
            const ExpandableSection(
              title: 'Is PCOD hereditary?',
              content:
                  'Genetics do play a role. You are more likely to have PCOD if your mother or sister has it.',
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
                    'If you miss periods, have excess hair growth, or are trying to conceive for over a year.',
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
