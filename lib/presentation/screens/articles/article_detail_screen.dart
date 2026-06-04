import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String readTime;
  final String category;
  final String imagePath;
  final String content;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.readTime,
    required this.category,
    required this.imagePath,
    this.content = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDark
                        ? const Color(0xFF3B284A)
                        : const Color(0xFFF3E5F9),
                    child: imagePath.isEmpty
                        ? const Center(
                            child: Icon(Icons.article,
                                size: 60, color: Colors.white54),
                          )
                        : Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(Icons.article,
                                  size: 60, color: Colors.white54),
                            ),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        author,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        readTime,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor.withOpacity(0.3)),
                  const SizedBox(height: 24),
                  content.trim().isNotEmpty
                      ? Text(
                          content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.black87,
                          ),
                        )
                      : const Text(
                          'Article content has not been added yet.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.grey,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
