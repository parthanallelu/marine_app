import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final professor = context.watch<AuthProvider>().currentUser as ProfessorModel;
    
    // Get batches assigned to this professor
    final professorBatches = DummyData.batches.where((b) => b.professorId == professor.id).toList();
    
    // Calculate total students
    final totalStudents = professorBatches.fold<int>(0, (sum, b) => sum + b.studentIds.length);
    
    // Get upcoming tests created by this professor
    final upcomingTests = DummyData.tests
        .where((t) => t.createdByProfessorId == professor.id && t.scheduledDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Professor Header
          SliverToBoxAdapter(
            child: _ProfessorHeader(professor: professor),
          ),

          // SLIVER 2 — Stats Row
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: "Total Students",
                      value: totalStudents.toString(),
                      icon: Icons.people_alt_rounded,
                      color: AppColors.oceanBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: "Active Batches",
                      value: professorBatches.length.toString(),
                      icon: Icons.groups_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: "Today's Classes",
                      value: "2", // Placeholder for schedule logic
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 3 — Quick Actions
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Quick Actions"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickActionCircle(
                        label: "Mark Attendance",
                        icon: Icons.how_to_reg_rounded,
                        color: AppColors.navyBlueBase,
                        onTap: () => context.go(AppRoutes.professorAttendance),
                      ),
                      const SizedBox(width: 16),
                      _QuickActionCircle(
                        label: "Upload Material",
                        icon: Icons.upload_file_rounded,
                        color: AppColors.oceanBlue,
                        onTap: () => context.go(AppRoutes.professorMaterials),
                      ),
                      const SizedBox(width: 16),
                      _QuickActionCircle(
                        label: "Add Test",
                        icon: Icons.add_task_rounded,
                        color: AppColors.success,
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _QuickActionCircle(
                        label: "Announce",
                        icon: Icons.campaign_rounded,
                        color: AppColors.warning,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 4 — My Batches
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: DashboardCard(
                title: "My Assigned Batches",
                icon: Icons.groups_rounded,
                iconColor: AppColors.gold,
                child: Column(
                  children: professorBatches.map((batch) => _BatchTile(batch: batch)).toList(),
                ),
              ),
            ),
          ),

          // SLIVER 5 — Upcoming Tests
          if (upcomingTests.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: DashboardCard(
                  title: "Upcoming Tests (Created by you)",
                  icon: Icons.quiz_rounded,
                  iconColor: AppColors.oceanBlue,
                  child: Column(
                    children: upcomingTests.map((test) => _TestOverviewTile(test: test)).toList(),
                  ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ProfessorHeader extends StatelessWidget {
  final ProfessorModel professor;
  const _ProfessorHeader({required this.professor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyBlueDark, AppColors.navyBlueBase],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                child: Text(
                  professor.name[0],
                  style: AppTextStyles.headingLarge.copyWith(color: AppColors.gold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    Text(
                      professor.name,
                      style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      professor.specialization,
                      style: AppTextStyles.caption.copyWith(color: AppColors.gold),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCircle({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
              textAlign: Alignment.center.x == 0 ? TextAlign.center : null,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  final BatchModel batch;
  const _BatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyBlueSurface),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.groups_rounded, color: AppColors.navyBlueBase, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.name, style: AppTextStyles.labelLarge),
                Text(
                  "${batch.timing} • ${batch.studentIds.length} Students",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _TestOverviewTile extends StatelessWidget {
  final TestModel test;
  const _TestOverviewTile({required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.oceanBlueSurface.withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz_rounded, color: AppColors.oceanBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: AppTextStyles.labelLarge),
                Text(
                  "Scheduled for ${test.scheduledDate.toString().split(' ')[0]}",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          PriorityTag(priority: "High"), // Placeholder logic
        ],
      ),
    );
  }
}
