import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../theme/app_theme.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// StatCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? bgColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.bgColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.navyBlueBase;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.statNumber.copyWith(color: AppColors.textPrimary, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (bgColor ?? cardColor).withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: cardColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;
  final String? statusLabel;
  final IconData? statusIcon;
  final Color? statusColor;

  const StudentStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
    this.statusLabel,
    this.statusIcon,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), 
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.2 * 255).round()), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: valueColor.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: valueColor, size: 16),
          ),
          const SizedBox(height: 4), 
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 18, 
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 0), 
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10, 
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (statusLabel != null) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (statusIcon != null) ...[
                  Icon(statusIcon, color: statusColor, size: 8),
                  const SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(
                    statusLabel!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DashboardCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final String? subtitle;

  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.iconColor,
    this.padding,
    this.actions,
    this.onTap,
    this.leading,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: AppSpacing.md),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 20, color: iconColor ?? AppColors.navyBlueBase),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.headingSmall),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) 
                    trailing!
                  else if (actionLabel != null)
                    TextButton(
                      onPressed: onAction,
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.oceanBlue),
                      ),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            Padding(
              padding: padding ?? EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// QuickActionTile
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.1 * 255).round())),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30, 
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16), 
                ),
                const SizedBox(height: 4), 
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 9, 
                        color: AppColors.textSecondary,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CustomButton
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.navyBlueBase;

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(isOutlined ? themeColor : Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );


    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: themeColor,
                side: BorderSide(color: themeColor, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
              ),
              child: content,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
              ),
              child: content,
            ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Badges
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CourseBadge extends StatelessWidget {
  final String courseType;
  const CourseBadge({super.key, required this.courseType});

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    if (courseType.contains('11th')) {
      baseColor = AppColors.course11th;
    } else if (courseType.contains('12th')) {
      baseColor = AppColors.course12th;
    } else {
      baseColor = AppColors.courseCrash;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withAlpha((0.10 * 255).round()),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: baseColor.withAlpha((0.30 * 255).round())),
      ),
      child: Text(
        courseType,
        style: AppTextStyles.labelSmall.copyWith(color: baseColor),
      ),
    );
  }
}

class BranchBadge extends StatelessWidget {
  final String branch;
  const BranchBadge({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: AppColors.navyBlueBase),
          const SizedBox(width: 4),
          Text(branch, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AttendanceDot
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AttendanceDot extends StatelessWidget {
  final Color color;
  final String label;
  final double size;

  const AttendanceDot({
    super.key,
    required this.color,
    required this.label,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// InfoRow
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? AppColors.textHint),
          SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SectionHeader
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingMedium),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.oceanBlue),
            ),
          ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EmptyState
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.navyBlueSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 40, color: AppColors.navyBlueBase),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: AppTextStyles.headingSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CustomButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NavyHeader
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class NavyHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final String? logoPath;
  final double minHeight;

  const NavyHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.logoPath,
    this.minHeight = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navyBlueDark,
            AppColors.navyBlueLight,
            AppColors.navyBlueBase,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (logoPath != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(logoPath!),
                  ),
                ),
              if (logoPath != null) const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle ?? '',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AppPageShell
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppPageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final List<Widget>? headerWidgets;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool isScrollable;
  final bool showBackButton;
  final Widget? endDrawer;
  final bool showMenuButton;

  const AppPageShell({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.headerWidgets,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
    this.isScrollable = true,
    this.showBackButton = true,
    this.endDrawer,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlueBase,
      endDrawer: endDrawer,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.extraLarge),
                  topRight: Radius.circular(AppRadius.extraLarge),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: isScrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: body,
                    )
                  : body,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navyBlueDark,
            AppColors.navyBlueLight,
            AppColors.navyBlueBase,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showBackButton && Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha((0.65 * 255).round()), fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                    if (actions != null) ...[
                      const SizedBox(width: 12),
                      ...actions!,
                    ],
                    if (showMenuButton) ...[
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ],
                ),
              if (headerWidgets != null && headerWidgets!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...headerWidgets!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PriorityTag
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PriorityTag extends StatelessWidget {
  final String priority;
  const PriorityTag({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    switch (priority.toLowerCase()) {
      case 'high':
        baseColor = AppColors.error;
        break;
      case 'medium':
        baseColor = AppColors.warning;
        break;
      default:
        baseColor = AppColors.success;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: baseColor.withAlpha((0.10 * 255).round()),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: baseColor.withAlpha((0.30 * 255).round())),
      ),
      child: Text(
        priority.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: baseColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AppSnackBar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.navyBlueBase,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }
}


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CustomTextField
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final int maxLines;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.focusNode,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelLarge),
          SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          focusNode: focusNode,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textHint, size: 20) : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          ),
        ),

      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpcomingTestTile
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UpcomingTestTile extends StatelessWidget {
  final TestModel test;
  final VoidCallback? onTap;

  const UpcomingTestTile({super.key, required this.test, this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scheduledDate = test.scheduledDate;
    final difference = scheduledDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    String daysLabel;
    bool isUrgent = difference <= 2;
    if (difference == 0) {
      daysLabel = "Today";
    } else if (difference == 1) {
      daysLabel = "Tomorrow";
    } else {
      daysLabel = "In $difference days";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.1 * 255).round())),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.oceanBlue.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_rounded, color: AppColors.oceanBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${test.durationMinutes}min • ${test.questions.length} questions • ${test.type}",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isUrgent ? AppColors.error : AppColors.navyBlueBase).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daysLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isUrgent ? AppColors.error : AppColors.navyBlueBase,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AnnouncementTile
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AnnouncementTile({
    super.key,
    required this.announcement,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isHigh = announcement.priority.toLowerCase() == 'high';
    final isMedium = announcement.priority.toLowerCase() == 'medium';
    final color = isHigh ? AppColors.error : (isMedium ? AppColors.warning : AppColors.success);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.1 * 255).round())),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PriorityTag(priority: announcement.priority),
                          if (onDelete != null) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        announcement.description,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${announcement.daysAgo} days ago • ${announcement.branch ?? 'All branches'}",
                              style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MaterialCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MaterialCard extends StatelessWidget {
  final StudyMaterialModel material;
  final VoidCallback? onDownload;

  const MaterialCard({super.key, required this.material, this.onDownload});

  @override
  Widget build(BuildContext context) {
    // Helper to determine category color (reproduced here for common widget)
    Color categoryColor;
    switch (material.category) {
      case 'IMU-CET':
        categoryColor = AppColors.navyBlueBase;
        break;
      case 'Psychometric':
        categoryColor = AppColors.course12th;
        break;
      case 'English Communication':
        categoryColor = AppColors.oceanBlue;
        break;
      case 'Maritime GK':
        categoryColor = AppColors.courseCrash;
        break;
      case 'Interview Prep':
        categoryColor = AppColors.gold;
        break;
      default:
        categoryColor = AppColors.navyBlueBase;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: categoryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              material.fileType == FileType.pdf ? Icons.description_rounded : Icons.play_circle_rounded,
              color: categoryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        material.category,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    if (material.companyTarget != null) ...[
                      const SizedBox(width: 6),
                      Text("•", style: AppTextStyles.caption),
                      const SizedBox(width: 6),
                      Text(
                        material.companyTarget!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${material.uploaderName} • ${material.fileSizeLabel}",
                  style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.file_download_outlined, color: AppColors.navyBlueBase),
          ),
        ],
      ),
    );
  }
}
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GenericConfirmationDialog
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class GenericConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const GenericConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = "Confirm",
    this.cancelLabel = "Cancel",
    required this.onConfirm,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = "Confirm",
    String cancelLabel = "Cancel",
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GenericConfirmationDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.headingSmall),
      content: Text(content, style: AppTextStyles.bodyMedium),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.navyBlueBase,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            elevation: 0,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// StudentCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssignBatch;
  final Widget? trailing;

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
    this.onAssignBatch,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppRadius.xxl,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : 'S',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyBlueBase),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.labelLarge),
                    Text(student.rollNumber, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              if (trailing != null) 
                trailing!
              else 
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                  tooltip: "Manage Student",
                  onSelected: (val) {
                    switch (val) {
                      case 'edit': onEdit(); break;
                      case 'assign': onAssignBatch?.call(); break;
                      case 'delete': onDelete(); break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text("Edit Info"),
                        ],
                      ),
                    ),
                    if (onAssignBatch != null)
                      const PopupMenuItem(
                        value: 'assign',
                        child: Row(
                          children: [
                            Icon(Icons.class_outlined, size: 18),
                            SizedBox(width: AppSpacing.sm),
                            Text("Assign Batch"),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text("Delete", style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (student.batchId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.class_outlined, size: 14, color: AppColors.gold),
                      const SizedBox(width: AppSpacing.xs),
                      Text(student.batchName, style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Text("Not Assigned", style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BranchBadge(branch: student.branch),
              CourseBadge(courseType: student.courseType),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// StudentTile (Simplified version of StudentCard for dense lists)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StudentTile extends StatelessWidget {
  final String name;
  final String rollNumber;
  final Widget? trailing;

  const StudentTile({
    super.key,
    required this.name,
    required this.rollNumber,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.navyBlueSurface,
            child: Text(
              name.isNotEmpty ? name[0] : 'S',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.navyBlueBase, fontSize: 12),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelMedium.copyWith(fontSize: 14)),
                Text(rollNumber, style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BatchCard extends StatelessWidget {
  final BatchModel batch;
  final int studentCount;
  final VoidCallback? onManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BatchCard({
    super.key,
    required this.batch,
    required this.studentCount,
    this.onManage,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.class_outlined, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name, style: AppTextStyles.labelLarge),
                    Text(batch.courseType, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              if (onEdit != null || onManage != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                  onSelected: (val) {
                    switch (val) {
                      case 'edit': onEdit?.call(); break;
                      case 'manage': onManage?.call(); break;
                      case 'delete': onDelete?.call(); break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: AppSpacing.sm),
                            Text("Edit Batch"),
                          ],
                        ),
                      ),
                    if (onManage != null)
                      const PopupMenuItem(
                        value: 'manage',
                        child: Row(
                          children: [
                            Icon(Icons.group_rounded, size: 18),
                            SizedBox(width: AppSpacing.sm),
                            Text("Manage Students"),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            const SizedBox(width: AppSpacing.sm),
                            Text("Delete", style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              _BatchMeta(icon: Icons.person_pin_outlined, label: batch.professorName),
              const Spacer(),
              _BatchMeta(icon: Icons.access_time_rounded, label: batch.timing),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _BatchMeta(icon: Icons.people_alt_outlined, label: "$studentCount Enrolled"),
              const Spacer(),
              TextButton.icon(
                onPressed: onManage,
                icon: const Icon(Icons.group_rounded, size: 18),
                label: const Text("Manage"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navyBlueBase,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatchMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BatchMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.oceanBlue),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TestCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TestCard extends StatelessWidget {
  final TestModel test;
  final String? batchName;
  final bool isUpcoming;
  final VoidCallback? onStart;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TestCard({
    super.key,
    required this.test,
    this.batchName,
    this.isUpcoming = false,
    this.onStart,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    switch (test.type.toLowerCase()) {
      case 'mock test':
      case 'imu-cet mock':
        typeColor = AppColors.navyBlueBase;
        break;
      case 'company specific':
        typeColor = AppColors.gold;
        break;
      case 'psychometric':
      case 'assessment':
        typeColor = AppColors.course12th;
        break;
      case 'english':
        typeColor = AppColors.oceanBlue;
        break;
      case 'unit test':
      case 'practice test':
        typeColor = AppColors.success;
        break;
      default:
        typeColor = AppColors.navyBlueBase;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: typeColor.withAlpha((0.2 * 255).round())),
                        ),
                        child: Text(
                          test.type,
                          style: AppTextStyles.labelSmall.copyWith(color: typeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(test.title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _TestMeta(icon: Icons.subject_rounded, label: test.subject),
                      if (batchName != null) ...[
                        const SizedBox(width: AppSpacing.lg),
                        _TestMeta(icon: Icons.class_outlined, label: batchName!),
                      ],
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    children: [
                      _TestMeta(icon: Icons.calendar_today_outlined, label: "${test.scheduledDate.day}/${test.scheduledDate.month}"),
                      const SizedBox(width: AppSpacing.lg),
                      _TestMeta(icon: Icons.timer_outlined, label: "${test.durationMinutes}m"),
                      const SizedBox(width: AppSpacing.lg),
                      _TestMeta(icon: Icons.assignment_outlined, label: "${test.questions.length} Qs"),
                      const Spacer(),
                      if (onStart != null && isUpcoming)
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onStart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: typeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            child: const Text("Start", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TestMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ResultCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ResultCard extends StatelessWidget {
  final TestResult result;
  final VoidCallback onTap;

  const ResultCard({super.key, required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPassed = result.isPassed;
    final color = hasPassed ? AppColors.success : AppColors.error;
    final bgColor = hasPassed ? AppColors.successSurface : AppColors.errorSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                result.grade,
                style: AppTextStyles.headingSmall.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.testTitle, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    "Score: ${result.score.toInt()}/${result.totalMarks.toInt()} (${result.percentage.toStringAsFixed(1)}%)",
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint.withAlpha(100)),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FeeCard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FeeCard extends StatelessWidget {
  final FeeRecord record;
  final VoidCallback onTap;

  const FeeCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pending = record.totalFees - record.paidAmount;
    final isFullyPaid = pending <= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isFullyPaid ? AppColors.success : AppColors.warning).withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFullyPaid ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                color: isFullyPaid ? AppColors.success : AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.studentName, style: AppTextStyles.labelLarge),
                  Text(
                    isFullyPaid ? "Fully Cleared" : "₹${pending.toInt()} outstanding",
                    style: AppTextStyles.caption.copyWith(
                      color: isFullyPaid ? AppColors.success : AppColors.error,
                      fontWeight: isFullyPaid ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${record.totalFees.toInt()}", style: AppTextStyles.labelMedium),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
