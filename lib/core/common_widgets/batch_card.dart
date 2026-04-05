import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class BatchCard extends StatelessWidget {
  final String name;
  final String courseType;
  final String timing;
  final String branch;
  final int studentCount;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BatchCard({
    super.key,
    required this.name,
    required this.courseType,
    required this.timing,
    required this.branch,
    required this.studentCount,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: name,
      subtitle: timing,
      onTap: onTap,
      onAction: onAction,
      actionLabel: actionLabel,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.navyBlueSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school_rounded, color: AppColors.navyBlueBase),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CourseBadge(courseType: courseType),
              Text(
                '$studentCount Students',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                branch,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
