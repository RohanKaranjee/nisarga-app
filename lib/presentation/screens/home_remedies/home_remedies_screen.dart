import 'package:flutter/material.dart';
import '../../../core/models/home_remedy.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gradient_header.dart';

class HomeRemediesScreen extends StatefulWidget {
  const HomeRemediesScreen({super.key});

  @override
  State<HomeRemediesScreen> createState() => _HomeRemediesScreenState();
}

class _HomeRemediesScreenState extends State<HomeRemediesScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Remedies')),
      body: StreamBuilder<List<HomeRemedy>>(
        stream: FirestoreService().watchHomeRemedies(),
        builder: (context, snapshot) {
          final remedies = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const GradientHeader(
                  icon: Icons.spa_outlined,
                  title: 'Home Remedies',
                  subtitle: 'Natural support for menstrual health',
                ),
                const SizedBox(height: 16),
                _note(),
                const SizedBox(height: 20),
                if (remedies.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No home remedies published yet.'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: remedies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final remedy = remedies[index];
                      return _RemedyTile(
                        remedy: remedy,
                        expanded: _expandedIndex == index,
                        onChanged: (expanded) {
                          setState(
                              () => _expandedIndex = expanded ? index : null);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _note() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'These remedies are complementary and should not replace medical treatment.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemedyTile extends StatelessWidget {
  final HomeRemedy remedy;
  final bool expanded;
  final ValueChanged<bool> onChanged;

  const _RemedyTile({
    required this.remedy,
    required this.expanded,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          onExpansionChanged: onChanged,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(remedy.category,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(remedy.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(remedy.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (remedy.ingredients.isNotEmpty) ...[
                    const Text('Ingredients',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final ingredient in remedy.ingredients)
                      _bullet(ingredient),
                    const SizedBox(height: 12),
                  ],
                  if (remedy.preparation.isNotEmpty)
                    _section('Preparation', remedy.preparation),
                  if (remedy.benefits.isNotEmpty)
                    _section('Benefits', remedy.benefits),
                  if (remedy.precautions.isNotEmpty)
                    _section('Precautions', remedy.precautions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
