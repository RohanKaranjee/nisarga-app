import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A screen that shows the full content of a health article.
class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String readTime;
  final String category;
  final String imagePath;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.readTime,
    required this.category,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image at the top
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDark ? const Color(0xFF3B284A) : const Color(0xFFF3E5F9),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.article, size: 60, color: Colors.white54)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 12),

                  // Author & read time
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 20),
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(readTime, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor.withOpacity(0.3)),
                  const SizedBox(height: 24),

                  // Article body content
                  _buildArticleContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    // Generate relevant content based on the article title
    final Map<String, List<Map<String, String>>> articleContents = {
      'Understanding Menstrual Health': [
        {'heading': 'What is Menstrual Health?', 'body': 'Menstrual health refers to the physical, emotional, and social well-being related to the menstrual cycle. Understanding your cycle is the first step to better health management.'},
        {'heading': 'The Four Phases', 'body': '1. Menstrual Phase (Days 1-5): The shedding of the uterine lining.\n\n2. Follicular Phase (Days 1-13): Hormones stimulate egg development.\n\n3. Ovulation (Day 14): The egg is released from the ovary.\n\n4. Luteal Phase (Days 15-28): The body prepares for potential pregnancy.'},
        {'heading': 'When to See a Doctor', 'body': 'Consult a healthcare provider if you experience extremely heavy bleeding, severe pain that interferes with daily activities, irregular cycles, or bleeding between periods.'},
        {'heading': 'Tips for Better Menstrual Health', 'body': '• Track your cycle regularly using apps like Nisarga\n• Maintain a balanced diet rich in iron and vitamins\n• Exercise regularly — even light walking helps\n• Stay hydrated throughout your cycle\n• Get adequate sleep, especially during your period'},
      ],
      'Managing PCOS': [
        {'heading': 'What is PCOS?', 'body': 'Polycystic Ovary Syndrome (PCOS) affects 1 in 10 women of reproductive age. It is a hormonal disorder that causes enlarged ovaries with small cysts on the outer edges.'},
        {'heading': 'Common Symptoms', 'body': '• Irregular or missed periods\n• Excess hair growth (hirsutism)\n• Acne and oily skin\n• Weight gain, especially around the abdomen\n• Thinning hair on the scalp\n• Difficulty getting pregnant'},
        {'heading': 'Natural Management Strategies', 'body': '1. Anti-inflammatory Diet: Focus on whole foods, fruits, vegetables, and lean proteins. Avoid processed foods and excess sugar.\n\n2. Regular Exercise: 150 minutes of moderate exercise per week can help manage symptoms.\n\n3. Stress Management: Yoga, meditation, and deep breathing can help regulate hormones.\n\n4. Adequate Sleep: Aim for 7-9 hours per night.'},
        {'heading': 'Medical Treatments', 'body': 'Consult your gynecologist about hormonal birth control, anti-androgen medications, or metformin if lifestyle changes alone are not sufficient.'},
      ],
      'Nutrition': [
        {'heading': 'Eating for Your Cycle', 'body': 'Your nutritional needs change throughout your menstrual cycle. Eating the right foods during each phase can help reduce symptoms and boost your energy.'},
        {'heading': 'During Your Period (Days 1-5)', 'body': '• Iron-rich foods: spinach, lentils, red meat\n• Vitamin C: oranges, strawberries (helps iron absorption)\n• Omega-3 fatty acids: salmon, walnuts\n• Warm, comforting foods: soups, herbal teas\n• Dark chocolate (in moderation) for magnesium'},
        {'heading': 'Follicular Phase (Days 6-14)', 'body': '• Light, fresh foods: salads, fermented foods\n• Lean proteins for energy\n• Flaxseeds for estrogen metabolism\n• Plenty of water'},
        {'heading': 'Luteal Phase (Days 15-28)', 'body': '• Complex carbohydrates: brown rice, sweet potatoes\n• Magnesium-rich foods: nuts, seeds, dark leafy greens\n• B-vitamin foods: whole grains, eggs\n• Avoid excess caffeine and salt to reduce bloating'},
      ],
    };

    // Find matching content
    String matchKey = 'Understanding Menstrual Health';
    for (final key in articleContents.keys) {
      if (title.contains(key)) {
        matchKey = key;
        break;
      }
    }
    final content = articleContents[matchKey]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section['heading']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                section['body']!,
                style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
