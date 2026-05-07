import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, String>> articles = const [
    {
      "title": "Understanding Menstrual Health: A Complete Guide",
      "author": "Dr. Sarah Johnson",
      "readTime": "8 min read",
      "category": "Education",
      "excerpt": "Learn everything about menstrual cycles, what's normal, and when to seek medical help.",
      "date": "Feb 20, 2026",
      "image": "assets/images/articles/article_menstrual.png"
    },
    {
      "title": "PCOD vs PCOS: Know the Difference",
      "author": "Dr. Priya Sharma",
      "readTime": "6 min read",
      "category": "PCOD/PCOS",
      "excerpt": "While often confused, PCOD and PCOS are different conditions. Understanding these differences is crucial.",
      "date": "Feb 18, 2026",
      "image": "assets/images/articles/article_pcos.png"
    },
    {
      "title": "Diet and Exercise for PCOS Management",
      "author": "Nutritionist Anjali Reddy",
      "readTime": "10 min read",
      "category": "Lifestyle",
      "excerpt": "Discover evidence-based dietary strategies and exercise routines that can help manage PCOS symptoms.",
      "date": "Feb 15, 2026",
      "image": "assets/images/articles/article_diet.png"
    },
    {
      "title": "Natural Ways to Reduce Menstrual Cramps",
      "author": "Dr. Meera Patel",
      "readTime": "5 min read",
      "category": "Pain Management",
      "excerpt": "Explore natural remedies, exercises, and lifestyle changes that can help reduce period pain without medication.",
      "date": "Feb 12, 2026",
      "image": "assets/images/articles/article_cramps.png"
    },
    {
      "title": "Fertility and PCOS: What You Need to Know",
      "author": "Dr. Kavita Desai",
      "readTime": "12 min read",
      "category": "Fertility",
      "excerpt": "PCOS can affect fertility, but many women with PCOS conceive naturally. Learn about options and treatments.",
      "date": "Feb 10, 2026",
      "image": "assets/images/articles/article_fertility.png"
    },
    {
      "title": "Hormonal Balance: A Guide for Women",
      "author": "Dr. Ananya Iyer",
      "readTime": "9 min read",
      "category": "Hormones",
      "excerpt": "How to identify hormonal imbalances and the natural lifestyle changes that can help restore harmony.",
      "date": "Feb 05, 2026",
      "image": "assets/images/articles/article_menstrual.png" // reuse placeholder
    },
    {
      "title": "Mental Health During Your Period",
      "author": "Dr. Ritu Singh",
      "readTime": "7 min read",
      "category": "Mental Health",
      "excerpt": "Understanding PMS, PMDD, and how hormonal fluctuations affect your mood and mental well-being.",
      "date": "Feb 01, 2026",
      "image": "assets/images/articles/article_cramps.png" // reuse placeholder
    },
    {
      "title": "Best Menstrual Products Compared",
      "author": "Health Editor",
      "readTime": "11 min read",
      "category": "Products",
      "excerpt": "Pads, tampons, cups, or discs? An honest comparison of modern menstrual products to help you choose.",
      "date": "Jan 28, 2026",
      "image": "assets/images/articles/article_diet.png" // reuse placeholder
    }
  ];

  final List<String> categories = const [
    "All", "Education", "PCOD/PCOS", "Lifestyle", "Pain Management", 
    "Fertility", "Hormones", "Mental Health", "Products"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final featuredArticle = articles.first;
    
    // Filter logic
    final displayArticles = _selectedCategory == 'All' 
        ? articles.skip(1).toList() // Skip featured if 'All'
        : articles.where((a) => a['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Articles')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientHeader(
              icon: Icons.article_outlined,
              title: 'Health Articles',
              subtitle: 'Expert advice and educational content',
            ),
            const SizedBox(height: 24),
            
            // Category Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : theme.textTheme.bodyMedium?.color
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Featured Article (only show if 'All' is selected, otherwise we just show list)
            if (_selectedCategory == 'All') ...[
              InkWell(
                onTap: () {
                  context.push('/article-detail', extra: {
                    'title': featuredArticle['title']!,
                    'author': featuredArticle['author']!,
                    'readTime': featuredArticle['readTime']!,
                    'category': featuredArticle['category']!,
                    'imagePath': featuredArticle['image']!,
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
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
                      // Background Image placeholder
                      Container(
                        height: 250,
                        width: double.infinity,
                        color: isDark ? const Color(0xFF3B284A) : const Color(0xFFF3E5F9), // Fallback colors
                        child: Image.asset(
                          featuredArticle['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));
                          },
                        ),
                      ),
                      // Gradient overlay for text readability
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Content
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              featuredArticle['title']!,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              featuredArticle['excerpt']!,
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(featuredArticle['author']!, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                const SizedBox(width: 16),
                                const Icon(Icons.schedule, size: 16, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(featuredArticle['readTime']!, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              ),
              const SizedBox(height: 24),
              const Text('Latest Articles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
            ],
            
            // List of Articles
            displayArticles.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No articles found for this category.'),
                  ))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayArticles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final article = displayArticles[index];
                      return InkWell(
                        onTap: () {
                          context.push('/article-detail', extra: {
                            'title': article['title']!,
                            'author': article['author']!,
                            'readTime': article['readTime']!,
                            'category': article['category']!,
                            'imagePath': article['image']!,
                          });
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Article Image Placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                child: Image.asset(
                                  article['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.article, color: AppColors.primary, size: 40);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(article['category']!, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(article['title']!, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(
                                    article['excerpt']!, 
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)), 
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          article['author']!, 
                                          style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)), 
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                      Icon(Icons.schedule, size: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                                      const SizedBox(width: 2),
                                      Text(
                                        article['readTime']!, 
                                        style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5))
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
