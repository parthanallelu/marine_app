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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyles.headingSmall.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              timing,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CourseBadge(courseType: courseType),
                const SizedBox(width: AppSpacing.sm),
                BranchBadge(branch: branch),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (actionLabel != null)
                  CustomButton(
                    label: actionLabel!,
                    onPressed: onAction,
                    height: 40,
                    width: 160,
                  ),
                const Spacer(),
                Text(
                  '$studentCount Students',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
