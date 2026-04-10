import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import 'widgets/student_drawer.dart';

class StudentInterviewScreen extends StatelessWidget {
  const StudentInterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: "Interview Prep",
      subtitle: "Master your interaction",
      showBackButton: false,
      showMenuButton: true,
      endDrawer: const StudentDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildQuickStats(),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(title: "Preparation Modules"),
            const SizedBox(height: AppSpacing.md),
            _buildModuleGrid(context),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(title: "Upcoming Mock Interviews"),
            const SizedBox(height: AppSpacing.md),
            _buildUpcomingMocks(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _StatCard(title: "Mock Score", value: "8.5", icon: Icons.star_rounded, color: AppColors.gold),
        const SizedBox(width: AppSpacing.md),
        _StatCard(title: "Confidence", value: "High", icon: Icons.trending_up_rounded, color: AppColors.success),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    final modules = [
      {'title': 'General IQ', 'icon': Icons.psychology_rounded, 'color': Colors.blue},
      {'title': 'Technical', 'icon': Icons.engineering_rounded, 'color': Colors.orange},
      {'title': 'Psychometric', 'icon': Icons.remove_red_eye_rounded, 'color': Colors.purple},
      {'title': 'Communication', 'icon': Icons.record_voice_over_rounded, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.3,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.1 * 255).round())),
            boxShadow: AppShadows.card,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (module['color'] as Color).withAlpha((0.1 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(module['icon'] as IconData, color: module['color'] as Color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module['title'] as String, 
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingMocks() {
    return Column(
      children: [
        _MockInterviewTile(
          company: "MSC Shipping",
          date: "12 Oct, 10:00 AM",
          status: "Confirmed",
        ),
        _MockInterviewTile(
          company: "Synergy Maritime",
          date: "15 Oct, 02:30 PM",
          status: "Pending",
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DashboardCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTextStyles.headingMedium),
            Text(title, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MockInterviewTile extends StatelessWidget {
  final String company;
  final String date;
  final String status;

  const _MockInterviewTile({required this.company, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == "Confirmed";
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.1 * 255).round())),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.navyBlueBase.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.business_rounded, color: AppColors.navyBlueBase, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company, style: AppTextStyles.labelLarge),
                Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isConfirmed ? AppColors.success : AppColors.warning).withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                color: isConfirmed ? AppColors.success : AppColors.warning,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
