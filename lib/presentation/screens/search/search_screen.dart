import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/article.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/home_remedy.dart';
import '../../../core/models/medicine.dart';
import '../../../core/models/product.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Doctors',
    'Articles',
    'Remedies',
    'Medicines',
    'Products'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search doctors, articles, remedies...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final selected = _selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            selectedColor:
                                AppColors.primaryLight.withValues(alpha: 0.3),
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultView()
                  : _RealtimeResults(
                      service: _service,
                      query: _searchQuery,
                      category: _selectedCategory,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    const links = [
      _QuickLink('PCOD Diet', '/pcod', Icons.restaurant_menu),
      _QuickLink('Period Pain', '/home-remedies', Icons.healing),
      _QuickLink('Track Cycle', '/cycle-history', Icons.calendar_month),
      _QuickLink('Find Doctor', '/doctor', Icons.medical_services),
      _QuickLink('Appointments', '/appointments', Icons.event_available),
      _QuickLink('Prescriptions', '/prescriptions', Icons.receipt_long),
      _QuickLink('Notifications', '/notifications', Icons.notifications),
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return InkWell(
          onTap: () => context.push(link.route),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(link.icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(link.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RealtimeResults extends StatelessWidget {
  final FirestoreService service;
  final String query;
  final String category;

  const _RealtimeResults({
    required this.service,
    required this.query,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Doctor>>(
      stream: service.watchDoctors(),
      builder: (context, doctors) {
        return StreamBuilder<List<Article>>(
          stream: service.watchArticles(),
          builder: (context, articles) {
            return StreamBuilder<List<HomeRemedy>>(
              stream: service.watchHomeRemedies(),
              builder: (context, remedies) {
                return StreamBuilder<List<Medicine>>(
                  stream: service.watchMedicines(),
                  builder: (context, medicines) {
                    return StreamBuilder<List<Product>>(
                      stream: service.watchProducts(),
                      builder: (context, products) {
                        final loading = [
                          doctors,
                          articles,
                          remedies,
                          medicines,
                          products
                        ].any((snapshot) =>
                            snapshot.connectionState ==
                            ConnectionState.waiting);
                        if (loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final error = doctors.error ??
                            articles.error ??
                            remedies.error ??
                            medicines.error ??
                            products.error;
                        if (error != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Unable to load search results: $error',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final results = _buildResults(
                          doctors.data ?? [],
                          articles.data ?? [],
                          remedies.data ?? [],
                          medicines.data ?? [],
                          products.data ?? [],
                        );
                        return _ResultList(results: results);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<_SearchResult> _buildResults(
    List<Doctor> doctors,
    List<Article> articles,
    List<HomeRemedy> remedies,
    List<Medicine> medicines,
    List<Product> products,
  ) {
    final all = [
      ...doctors.map((doctor) => _SearchResult(
            title: doctor.name,
            type: 'Doctors',
            route: '/doctor/${doctor.id}',
            icon: Icons.medical_services,
          )),
      ...articles.map((article) => _SearchResult(
            title: article.title,
            type: 'Articles',
            route: '/article-detail',
            icon: Icons.article,
            extra: {
              'title': article.title,
              'author': article.author,
              'readTime': article.readTime,
              'category': article.category,
              'imagePath': article.imageUrl,
              'content': article.content,
            },
          )),
      ...remedies.map((remedy) => _SearchResult(
            title: remedy.title,
            type: 'Remedies',
            route: '/home-remedies',
            icon: Icons.spa,
          )),
      ...medicines.map((medicine) => _SearchResult(
            title: medicine.name,
            type: 'Medicines',
            route: '/medicines',
            icon: Icons.medication,
          )),
      ...products.map((product) => _SearchResult(
            title: product.name,
            type: 'Products',
            route: '/pads',
            icon: Icons.shopping_bag,
          )),
    ];

    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);

    return all.where((item) {
      if (category != 'All' && item.type != category) return false;
      final title = item.title.toLowerCase();
      return words.any(title.contains);
    }).toList();
  }
}

class _ResultList extends StatelessWidget {
  final List<_SearchResult> results;
  const _ResultList({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No results found.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          title: Text(item.title),
          subtitle: Text(item.type),
          onTap: () => context.push(item.route, extra: item.extra),
        );
      },
    );
  }
}

class _SearchResult {
  final String title;
  final String type;
  final String route;
  final IconData icon;
  final Object? extra;

  const _SearchResult({
    required this.title,
    required this.type,
    required this.route,
    required this.icon,
    this.extra,
  });
}

class _QuickLink {
  final String title;
  final String route;
  final IconData icon;

  const _QuickLink(this.title, this.route, this.icon);
}
