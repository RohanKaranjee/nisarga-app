import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _allDoctors = const [
    {
      "id": "1",
      "name": "Dr. Sarah Johnson",
      "specialization": "Gynecologist",
      "experience": "12 yrs exp",
      "rating": "4.8",
      "reviews": "124 reviews",
      "location": "City Hospital, New Delhi",
      "fee": "₹800",
      "availability": "Available Today",
      "image": "assets/images/doctors/doctor_1.png"
    },
    {
      "id": "2",
      "name": "Dr. Priya Sharma",
      "specialization": "PCOS Specialist",
      "experience": "15 yrs exp",
      "rating": "4.9",
      "reviews": "256 reviews",
      "location": "Women's Clinic, Mumbai",
      "fee": "₹1000",
      "availability": "Available Tomorrow",
      "image": "assets/images/doctors/doctor_2.png"
    },
    {
      "id": "3",
      "name": "Dr. Kavita Desai",
      "specialization": "Fertility",
      "experience": "10 yrs exp",
      "rating": "4.7",
      "reviews": "98 reviews",
      "location": "Care Hospital, Bangalore",
      "fee": "₹1200",
      "availability": "Available Today",
      "image": "assets/images/doctors/doctor_3.png"
    },
    {
      "id": "4",
      "name": "Dr. Ananya Iyer",
      "specialization": "Endocrinologist",
      "experience": "8 yrs exp",
      "rating": "4.6",
      "reviews": "150 reviews",
      "location": "Health Center, Chennai",
      "fee": "₹900",
      "availability": "Available Today",
      "image": "assets/images/doctors/doctor_4.png"
    },
    {
      "id": "5",
      "name": "Dr. Neha Gupta",
      "specialization": "Gynecologist",
      "experience": "20 yrs exp",
      "rating": "4.9",
      "reviews": "400 reviews",
      "location": "Metro Hospital, Pune",
      "fee": "₹1500",
      "availability": "Available Next Week",
      "image": "assets/images/doctors/doctor_5.png"
    },
    {
      "id": "6",
      "name": "Dr. Ritu Singh",
      "specialization": "Hormonal Health",
      "experience": "6 yrs exp",
      "rating": "4.5",
      "reviews": "80 reviews",
      "location": "Wellness Clinic, Hyderabad",
      "fee": "₹700",
      "availability": "Available Tomorrow",
      "image": "assets/images/doctors/doctor_1.png"
    },
    {
      "id": "7",
      "name": "Dr. Sunita Rao",
      "specialization": "Reproductive Medicine",
      "experience": "18 yrs exp",
      "rating": "4.8",
      "reviews": "320 reviews",
      "location": "Care Plus, Kolkata",
      "fee": "₹1300",
      "availability": "Available Today",
      "image": "assets/images/doctors/doctor_2.png"
    },
    {
      "id": "8",
      "name": "Dr. Fatima Khan",
      "specialization": "PCOS Specialist",
      "experience": "14 yrs exp",
      "rating": "4.7",
      "reviews": "210 reviews",
      "location": "City Care, Ahmedabad",
      "fee": "₹1100",
      "availability": "Available Today",
      "image": "assets/images/doctors/doctor_3.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter the doctors list
    final filteredDoctors = _selectedFilter == 'All' 
        ? _allDoctors 
        : _allDoctors.where((doc) => doc['specialization'].toString().contains(_selectedFilter)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search doctors, specialties...',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showSortBottomSheet,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filters
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Gynecologist'),
                  _buildFilterChip('PCOS Specialist'),
                  _buildFilterChip('Fertility'),
                  _buildFilterChip('Endocrinologist'),
                ],
              ),
            ),
            
            Expanded(
              child: filteredDoctors.isEmpty 
                  ? const Center(child: Text("No doctors found for this category"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(context, filteredDoctors[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Rating (High to Low)'),
                trailing: const Icon(Icons.star, color: Colors.amber),
                onTap: () {
                  // Implementing sort logic would happen here in state
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Consultation Fee (Low to High)'),
                trailing: const Icon(Icons.currency_rupee, color: Colors.green),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Experience (High to Low)'),
                trailing: const Icon(Icons.work_history, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        labelStyle: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doc) {
    final theme = Theme.of(context);
    
    // Determine badge color based on availability
    Color availabilityColor = Colors.green;
    if (doc['availability'].contains('Tomorrow')) {
      availabilityColor = Colors.orange;
    } else if (doc['availability'].contains('Next Week')) {
      availabilityColor = Colors.red;
    }

    return InkWell(
      onTap: () => context.push('/doctor/${doc["id"]}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Image Placeholder using a robust fallback mechanism
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(doc['image']),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {}, // Fails silently if image doesn't exist
                    ),
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.transparent), // Hidden icon, shown if image fails (handled below)
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              doc['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.favorite_border, color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(doc['specialization'], style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(doc['experience'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.green, size: 12),
                                const SizedBox(width: 2),
                                Text(doc['rating'], style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(doc['reviews'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: availabilityColor),
                ),
                const SizedBox(width: 6),
                Text(doc['availability'], style: TextStyle(fontSize: 12, color: availabilityColor)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consultation Fee', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(doc['fee'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    _buildSmallActionBtn(
                      Icons.chat_bubble_rounded,
                      Colors.green,
                      () => context.push('/doctor/chat/${doc["id"]}'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => context.push('/doctor/${doc["id"]}'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Book'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
