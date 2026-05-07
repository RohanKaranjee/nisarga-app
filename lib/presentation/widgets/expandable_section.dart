import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.primary,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                widget.content,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
