import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/dummy_data.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalStudents = DummyData.students.length;
    final totalProfessors = DummyData.professors.length;
    final totalTests = DummyData.tests.length;
    final totalSubmissions = DummyData.testResults.length;
    final pendingReviews = DummyData.testResults
        .where((result) => result.feedback.isEmpty)
        .length;
    final averageScore = DummyData.testResults.isEmpty
        ? 0.0
        : DummyData.testResults
                  .map((result) => result.percentage)
                  .reduce((a, b) => a + b) /
              DummyData.testResults.length;

    return AppPageShell(
      title: "Reports",
      subtitle: "Academy analytics",
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  label: "Students",
                  value: totalStudents.toString(),
                  icon: Icons.groups_rounded,
                  color: AppColors.navyBlueBase,
                ),
                StatCard(
                  label: "Professors",
                  value: totalProfessors.toString(),
                  icon: Icons.person_rounded,
                  color: AppColors.oceanBlue,
                ),
                StatCard(
                  label: "Tests",
                  value: totalTests.toString(),
                  icon: Icons.assignment_rounded,
                  color: AppColors.gold,
                ),
                StatCard(
                  label: "Submissions",
                  value: totalSubmissions.toString(),
                  icon: Icons.fact_check_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            DashboardCard(
              title: "Test Activity",
              icon: Icons.insights_rounded,
              iconColor: AppColors.purple,
              child: Column(
                children: [
                  _MetricRow(
                    label: "Average Score",
                    value: "${averageScore.toStringAsFixed(1)}%",
                    color: AppColors.success,
                    progress: (averageScore / 100).clamp(0.0, 1.0),
                  ),
                  _MetricRow(
                    label: "Pending Reviews",
                    value: pendingReviews.toString(),
                    color: AppColors.warning,
                    progress: totalSubmissions == 0
                        ? 0
                        : pendingReviews / totalSubmissions,
                  ),
                  _MetricRow(
                    label: "Pass Rate",
                    value: "${_passRate().toStringAsFixed(1)}%",
                    color: AppColors.oceanBlue,
                    progress: (_passRate() / 100).clamp(0.0, 1.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            DashboardCard(
              title: "Branch Distribution",
              icon: Icons.location_city_rounded,
              iconColor: AppColors.gold,
              child: Column(
                children: AppColorsForReports.branchCounts.entries.map((entry) {
                  final progress = totalStudents == 0
                      ? 0.0
                      : entry.value / totalStudents;
                  return _MetricRow(
                    label: entry.key,
                    value: entry.value.toString(),
                    color: AppColors.navyBlueBase,
                    progress: progress,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _passRate() {
    if (DummyData.testResults.isEmpty) return 0;
    final passed = DummyData.testResults
        .where((result) => result.isPassed)
        .length;
    return (passed / DummyData.testResults.length) * 100;
  }
}

class AppColorsForReports {
  static Map<String, int> get branchCounts {
    return {
      for (final branch in DummyData.students.map((student) => student.branch))
        branch: DummyData.students
            .where((student) => student.branch == branch)
            .length,
    };
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double progress;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
