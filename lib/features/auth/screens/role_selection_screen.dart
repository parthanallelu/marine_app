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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              // MAIN WHITE CARD
              // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 
                  70, // Padding for logo overlap
                  AppSpacing.xl, 
                  AppSpacing.xl
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.whoAreYou,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.navyBlueDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.selectRoleToContinue,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _RoleCard(
                      roleName: AppConstants.roleStudent,
                      subtitle: AppConstants.studentRoleDesc,
                      icon: Icons.school_rounded,
                      color: AppColors.navyBlueDark,
                      onTap: () => _selectRoleAndNavigate(context, AppConstants.roleStudent),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RoleCard(
                      roleName: AppConstants.roleProfessor,
                      subtitle: AppConstants.professorRoleDesc,
                      icon: Icons.person_search_rounded,
                      color: AppColors.oceanBlue,
                      onTap: () => _selectRoleAndNavigate(context, AppConstants.roleProfessor),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RoleCard(
                      roleName: AppConstants.roleAdmin,
                      subtitle: AppConstants.adminRoleDesc,
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.gold,
                      textColor: Colors.white,
                      onTap: () => _selectRoleAndNavigate(context, AppConstants.roleAdmin),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),

              // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              // OVERLAPPING LOGO
              // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              Positioned(
                top: -50, // Half of logo height (100)
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.25 * 255).round()),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2), // Slight inset for circle border
                    child: ClipOval(
                      child: Image.asset(AppConstants.logo, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.2 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON BOX
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: effectiveTextColor, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            
            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    roleName,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: effectiveTextColor,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: effectiveTextColor.withAlpha((0.85 * 255).round()),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // CHEVRON
            Icon(
              Icons.chevron_right_rounded, 
              color: effectiveTextColor, 
              size: 32
            ),
          ],
        ),
      ),
    );
  }
}
