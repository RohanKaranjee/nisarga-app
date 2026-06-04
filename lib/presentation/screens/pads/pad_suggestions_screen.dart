import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/product.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gradient_header.dart';

class PadSuggestionsScreen extends StatefulWidget {
  const PadSuggestionsScreen({super.key});

  @override
  State<PadSuggestionsScreen> createState() => _PadSuggestionsScreenState();
}

class _PadSuggestionsScreenState extends State<PadSuggestionsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pad Suggestions')),
      body: StreamBuilder<List<Product>>(
        stream: FirestoreService().watchProducts(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          final categories = [
            'All',
            ...{
              for (final product in products)
                if (product.category.isNotEmpty) product.category
            }
          ];
          final filtered = _selectedCategory == 'All'
              ? products
              : products
                  .where((product) => product.category == _selectedCategory)
                  .toList();

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const GradientHeader(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Pad Suggestions',
                    subtitle: 'Find menstrual products that fit your needs',
                  ),
                  const SizedBox(height: 16),
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
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No products published yet.'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _ProductCard(product: filtered[index]),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  Future<void> _launchUrl(BuildContext context) async {
    if (product.buyUrl.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Buy link not set.')));
      return;
    }
    final uri = Uri.parse(product.buyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.primaryLight.withOpacity(0.2),
              child: product.imageUrl.isEmpty
                  ? const Icon(Icons.shopping_bag,
                      color: AppColors.primary, size: 30)
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag,
                          color: AppColors.primary),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(product.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${product.rating.toStringAsFixed(1)} '),
                    Text('(${product.reviews})',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Text(product.price > 0 ? 'Rs ${product.price.round()}' : '',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                if (product.features.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: product.features
                        .map((feature) => Chip(label: Text(feature)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchUrl(context),
                    child: const Text('Buy Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
