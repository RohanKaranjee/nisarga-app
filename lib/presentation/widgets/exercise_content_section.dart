import 'package:flutter/material.dart';
import '../../core/models/exercise_content.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/app_colors.dart';

class ExerciseContentSection extends StatelessWidget {
  final String condition;

  const ExerciseContentSection({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExerciseContent>>(
      stream: FirestoreService().watchExercises(condition),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final exercises = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'No exercises added yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...exercises.map((exercise) => _ExerciseCard(exercise: exercise)),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseContent exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                exercise.imageUrl,
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  child: const Center(
                    child: Icon(Icons.fitness_center,
                        color: AppColors.primary, size: 40),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(exercise.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
