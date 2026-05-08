import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Doctors', 'Articles', 'Remedies', 'Medicines', 'Products'
  ];

  final List<Map<String, dynamic>> _quickLinks = [
    {"title": "PCOD Diet", "route": "/pcod", "icon": Icons.restaurant_menu},
    {"title": "Period Pain", "route": "/home-remedies", "icon": Icons.healing},
    {"title": "Track Cycle", "route": "/cycle-history", "icon": Icons.calendar_month},
    {"title": "Find Doctor", "route": "/doctor", "icon": Icons.medical_services},
  ];

  final List<Map<String, dynamic>> _allContent = [
    {"title": "Understanding Menstrual Health", "type": "Articles", "route": "/articles"},
    {"title": "PCOD vs PCOS Difference", "type": "Articles", "route": "/articles"},
    {"title": "Diet for PCOS Management", "type": "Articles", "route": "/articles"},
    {"title": "Dr. Sarah Johnson (Gynecologist)", "type": "Doctors", "route": "/doctor/1"},
    {"title": "Dr. Priya Sharma (PCOS Specialist)", "type": "Doctors", "route": "/doctor/2"},
    {"title": "Dr. Kavita Desai (Fertility)", "type": "Doctors", "route": "/doctor/3"},
    {"title": "Ginger Tea for Cramps", "type": "Remedies", "route": "/home-remedies"},
    {"title": "Cinnamon Water", "type": "Remedies", "route": "/home-remedies"},
    {"title": "Flaxseeds for Hormones", "type": "Remedies", "route": "/home-remedies"},
    {"title": "Metformin", "type": "Medicines", "route": "/medicines"},
    {"title": "Birth Control Pills", "type": "Medicines", "route": "/medicines"},
    {"title": "Organic Cotton Pads", "type": "Products", "route": "/pads"},
    {"title": "Menstrual Cup", "type": "Products", "route": "/pads"},
    {"title": "Overnight Pads", "type": "Products", "route": "/pads"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters: split query by space and check if title contains all words
    List<Map<String, dynamic>> filteredContent = _searchQuery.isEmpty 
        ? [] 
        : _allContent.where((c) {
            final titleLower = c['title'].toString().toLowerCase();
            final queryWords = _searchQuery.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
            if (queryWords.isEmpty) return false;
            // Match if ANY word is in the title, making search more forgiving
            return queryWords.any((word) => titleLower.contains(word));
          }).toList();

    if (_selectedCategory != 'All' && _searchQuery.isNotEmpty) {
      filteredContent = filteredContent.where((c) => c['type'] == _selectedCategory).toList();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search doctors, articles, remedies...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ) 
                          : null,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  // Category Filter Chips below search bar
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                selectedColor: AppColors.primaryLight.withOpacity(0.3),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultView()
                  : _buildSearchResults(filteredContent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: _quickLinks.length,
            itemBuilder: (context, index) {
              final link = _quickLinks[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => context.push(link['route']),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(link['icon'], color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(link['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRecentSearchItem('PCOS Diet'),
          _buildRecentSearchItem('Cramps'),
          _buildRecentSearchItem('Gynecologist'),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String query) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(query),
      trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
      onTap: () {
        _searchController.text = query;
        setState(() {
          _searchQuery = query;
          _selectedCategory = 'All'; // reset filter on new search
        });
      },
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No results found.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Found ${results.length} result${results.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  child: Icon(
                    _getIconForType(item['type']), 
                    color: AppColors.primary
                  ),
                ),
                title: Text(item['title']),
                subtitle: Text(item['type']),
                onTap: () => context.push(item['route']),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Doctors': return Icons.medical_services;
      case 'Articles': return Icons.article;
      case 'Remedies': return Icons.spa;
      case 'Medicines': return Icons.medication;
      case 'Products': return Icons.shopping_bag;
      default: return Icons.search;
    }
  }
}
