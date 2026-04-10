import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/common_widgets/common_widgets.dart';
import '../../../../providers/auth_provider.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final student = authProvider.currentUser;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context, student),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: "My Profile",
                  onTap: () {
                    context.pop();
                    // Since it's no longer in bottom nav, we push it to stack or replace
                    // I'll keep the profile screen but it might need its own route if not in shell
                    context.pushNamed(AppRoutes.studentProfileName);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.dark_mode_rounded,
                  title: "Dark Mode",
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: AppColors.oceanBlue,
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.assignment_rounded,
                  title: "Test Series",
                  onTap: () {
                    context.pop(); // Close drawer
                    context.pushNamed(AppRoutes.studentTestsName);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.download_rounded,
                  title: "My Downloads",
                  onTap: () {
                    // TODO: Implement Downloads screen
                    context.pop();
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_rounded,
                  title: "About Us",
                  onTap: () {
                    // TODO: Implement About Us screen
                    context.pop();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Divider(color: AppColors.divider),
                ),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  color: AppColors.error,
                  onTap: () {
                    context.pop();
                    GenericConfirmationDialog.show(
                      context,
                      title: "Logout",
                      content: "Are you sure you want to log out?",
                      confirmLabel: "Logout",
                      isDestructive: true,
                      onConfirm: () => authProvider.logout(),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic student) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 60, AppSpacing.xl, AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.navyBlueBase,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Text(
              student?.name[0] ?? "S",
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.name ?? "Student",
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  student?.email ?? "",
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(color: color ?? AppColors.textPrimary),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
      onTap: onTap,
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(
            "App Version 1.0.0",
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
