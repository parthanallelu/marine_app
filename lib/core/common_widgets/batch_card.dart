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
        padding: const EdgeInsets.all(AppSpacing.lg),
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
              style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              timing,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  CourseBadge(courseType: courseType),
                  const SizedBox(width: AppSpacing.sm),
                  BranchBadge(branch: branch),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (actionLabel != null)
                  Flexible(
                    child: CustomButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      height: 36,
                      // width: 150, // Removed fixed width
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '$studentCount Students',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
