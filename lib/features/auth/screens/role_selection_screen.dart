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
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: const Icon(Icons.anchor_rounded, color: AppColors.navyBlueDark, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
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
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Who are you?", style: AppTextStyles.headingLarge),
                    const SizedBox(height: 4),
                    Text("Select your role to continue", style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Column(
                        children: [
                          _RoleCard(
                            roleName: 'Student',
                            subtitle: 'Access materials, tests & attendance',
                            icon: Icons.school_rounded,
                            color: AppColors.navyBlueBase,
                            onTap: () => _selectRoleAndNavigate(context, AppConstants.roleStudent),
                          ),
                          const SizedBox(height: 14),
                          _RoleCard(
                            roleName: 'Professor',
                            subtitle: 'Manage batches & mark attendance',
                            icon: Icons.person_search_rounded,
                            color: AppColors.oceanBlue,
                            onTap: () => _selectRoleAndNavigate(context, AppConstants.roleProfessor),
                          ),
                          const SizedBox(height: 14),
                          _RoleCard(
                            roleName: 'Administrator',
                            subtitle: 'Academy management & reports',
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveTextColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleName,
                    style: AppTextStyles.labelLarge.copyWith(color: effectiveTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
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
