import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';

class PadSuggestionsScreen extends StatefulWidget {
  const PadSuggestionsScreen({super.key});

  @override
  State<PadSuggestionsScreen> createState() => _PadSuggestionsScreenState();
}

class _PadSuggestionsScreenState extends State<PadSuggestionsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ["All", "Regular Pads", "Organic Pads", "Tampons", "Menstrual Cups"];

  final List<Map<String, dynamic>> _products = [
    {
      "name": "Organic Cotton Ultra Soft Pads",
      "category": "Organic Pads",
      "rating": 4.8,
      "reviews": 234,
      "price": 299,
      "description": "100% organic cotton, chemical-free, biodegradable",
      "features": ["Ultra absorbent", "Rash-free", "Eco-friendly"],
      "icon": Icons.eco
    },
    {
      "name": "Regular Maxi Flow Pads",
      "category": "Regular Pads",
      "rating": 4.5,
      "reviews": 189,
      "price": 199,
      "description": "Maximum protection for heavy flow days",
      "features": ["12-hour protection", "Leak-proof", "Odor control"],
      "icon": Icons.water_drop
    },
    {
      "name": "Medical Grade Menstrual Cup",
      "category": "Menstrual Cups",
      "rating": 4.9,
      "reviews": 312,
      "price": 599,
      "description": "Reusable, eco-friendly, lasts up to 10 years",
      "features": ["Medical-grade silicone", "12-hour wear", "Zero waste"],
      "icon": Icons.local_drink
    },
  ];

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://example.com/buy-now'); // Replace with actual e-commerce URL
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'All' 
        ? _products 
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pad Suggestions')),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GradientHeader(
              icon: Icons.shopping_bag_outlined,
              title: 'Pad Suggestions',
              subtitle: 'Find the right menstrual products for you',
            ),
            const SizedBox(height: 16),
            
            // Category Filter
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Products List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(product['icon'], color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(product['description'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' ${product['rating']} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('(${product['reviews']})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const Spacer(),
                                Text('₹${product['price']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: (product['features'] as List<String>).map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(f, style: const TextStyle(fontSize: 10)),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _launchUrl,
                                    child: const Text('Buy Now'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Add to Cart'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            // Comparison Guide
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Comparison Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  _ComparisonRow(title: 'Regular Pads', desc: 'Disposable, easy to use, various sizes available'),
                  SizedBox(height: 12),
                  _ComparisonRow(title: 'Organic Pads', desc: 'Chemical-free, eco-friendly, gentle on skin'),
                  SizedBox(height: 12),
                  _ComparisonRow(title: 'Tampons', desc: 'Internal protection, ideal for active lifestyle'),
                  SizedBox(height: 12),
                  _ComparisonRow(title: 'Menstrual Cups', desc: 'Reusable, eco-friendly, cost-effective long-term'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          ),
      ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String title;
  final String desc;
  const _ComparisonRow({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
