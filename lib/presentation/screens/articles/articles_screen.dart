import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/article.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gradient_header.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Articles')),
      body: StreamBuilder<List<Article>>(
        stream: FirestoreService().watchArticles(),
        builder: (context, snapshot) {
          final articles = snapshot.data ?? [];
          final categories = [
            'All',
            ...{
              for (final article in articles)
                if (article.category.isNotEmpty) article.category
            }
          ];
          final filtered = _selectedCategory == 'All'
              ? articles
              : articles
                  .where((article) => article.category == _selectedCategory)
                  .toList();

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientHeader(
                  icon: Icons.article_outlined,
                  title: 'Health Articles',
                  subtitle: 'Expert advice and educational content',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No articles published yet.'),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _ArticleCard(article: filtered[index]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/article-detail', extra: {
          'title': article.title,
          'author': article.author,
          'readTime': article.readTime,
          'category': article.category,
          'imagePath': article.imageUrl,
          'content': article.content,
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: article.imageUrl.isEmpty
                    ? const Icon(Icons.article, color: AppColors.primary)
                    : Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.article, color: AppColors.primary),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(article.excerpt,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('${article.author} - ${article.readTime}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
