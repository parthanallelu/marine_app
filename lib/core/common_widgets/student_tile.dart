import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String rollNumber;
  final String? batchName;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showAvatar;

  const StudentTile({
    super.key,
    required this.name,
    required this.rollNumber,
    this.batchName,
    this.trailing,
    this.onTap,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: showAvatar
            ? CircleAvatar(
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.navyBlueBase,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        title: Text(name, style: AppTextStyles.labelLarge),
        subtitle: Text(
          batchName != null ? 'Roll: $rollNumber • $batchName' : 'Roll: $rollNumber',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        trailing: trailing,
      ),
    );
  }
}
