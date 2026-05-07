import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GradientHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const GradientHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
