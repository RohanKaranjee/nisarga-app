import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/doctor.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String _selectedFilter = 'All';
  final FirestoreService _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      onChanged: (value) {
                        setState(() => _selectedFilter =
                            value.trim().isEmpty ? 'All' : value.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Gynecologist'),
                  _buildFilterChip('PCOS'),
                  _buildFilterChip('Fertility'),
                  _buildFilterChip('Endocrinologist'),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Doctor>>(
                stream: _service.watchDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final doctors = _filterDoctors(snapshot.data ?? []);
                  if (doctors.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No approved doctors available yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(context, doctors[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Doctor> _filterDoctors(List<Doctor> doctors) {
    if (_selectedFilter == 'All') return doctors;
    final query = _selectedFilter.toLowerCase();
    return doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
          doctor.specialization.toLowerCase().contains(query) ||
          doctor.location.toLowerCase().contains(query);
    }).toList();
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
          if (selected) setState(() => _selectedFilter = label);
        },
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    final theme = Theme.of(context);
    final imageProvider = doctor.photoUrl.isNotEmpty
        ? NetworkImage(doctor.photoUrl)
        : doctor.photo.isNotEmpty
            ? AssetImage(doctor.photo) as ImageProvider
            : null;

    return InkWell(
      onTap: () => context.push('/doctor/${doctor.id}'),
      borderRadius: BorderRadius.circular(20),
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
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person,
                          size: 40, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(doctor.specialization,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(doctor.location,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text('${doctor.experience} yrs exp',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    const Text('Available Slots',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '${doctor.availability.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_rounded,
                          color: Colors.green),
                      onPressed: () =>
                          context.push('/doctor/chat/${doctor.id}'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => context.push('/doctor/${doctor.id}'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
}
