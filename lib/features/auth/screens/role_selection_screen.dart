import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlueDark,
      body: Column(
        children: [
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // TOP SECTION
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: const Icon(Icons.anchor_rounded, color: AppColors.navyBlueDark, size: 44),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  const Text(
                    AppConstants.appName,
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // BOTTOM SECTION
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  topRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.whoAreYou, style: AppTextStyles.headingLarge),
                    SizedBox(height: AppSpacing.xs),
                    Text(AppConstants.selectRoleToContinue, style: AppTextStyles.bodyMedium),
                    SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        children: [
                          _RoleCard(
                            roleName: AppConstants.roleStudent,
                            subtitle: AppConstants.studentRoleDesc,
                            icon: Icons.school_rounded,
                            color: AppColors.navyBlueBase,
                            onTap: () => _selectRoleAndNavigate(context, AppConstants.roleStudent),
                          ),
                          SizedBox(height: AppSpacing.md),
                          _RoleCard(
                            roleName: AppConstants.roleProfessor,
                            subtitle: AppConstants.professorRoleDesc,
                            icon: Icons.person_search_rounded,
                            color: AppColors.oceanBlue,
                            onTap: () => _selectRoleAndNavigate(context, AppConstants.roleProfessor),
                          ),
                          SizedBox(height: AppSpacing.md),
                          _RoleCard(
                            roleName: AppConstants.roleAdmin,
                            subtitle: AppConstants.adminRoleDesc,
                            icon: Icons.admin_panel_settings_rounded,
                            color: AppColors.gold,
                            textColor: AppColors.navyBlueDark,
                            onTap: () => _selectRoleAndNavigate(context, AppConstants.roleAdmin),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectRoleAndNavigate(BuildContext context, String role) {
    context.read<AuthProvider>().selectRole(role);
    context.push(AppRoutes.login);
  }
}

class _RoleCard extends StatelessWidget {
  final String roleName;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.roleName,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.30 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: effectiveTextColor, size: 28),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleName,
                    style: AppTextStyles.labelLarge.copyWith(color: effectiveTextColor),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: effectiveTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: effectiveTextColor),
          ],
        ),
      ),
    );
  }
}
