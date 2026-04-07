import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late int totalStudents;
  late int totalProfessors;
  late int activeBatches;
  late double totalFeesPending;
  late Map<String, int> branchCounts;
  late Map<String, int> courseCounts;
  late List<AnnouncementModel> recentNotices;

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  void _computeData() {
    totalStudents = DummyData.students.length;
    totalProfessors = DummyData.professors.length;
    activeBatches = DummyData.batches.where((b) => b.isActive).length;

    // Sum of pending amounts across all fee records
    totalFeesPending = DummyData.feeRecords.fold(0, (sum, record) => sum + record.pendingAmount);

    // Branch counts
    branchCounts = {};
    for (var branch in AppConstants.branches) {
      branchCounts[branch] = DummyData.students.where((s) => s.branch == branch).length;
    }

    // Course counts
    courseCounts = {};
    for (var course in AppConstants.courseTypes) {
      courseCounts[course] = DummyData.students.where((s) => s.courseType == course).length;
    }

    recentNotices = DummyData.announcements.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — NavyHeader
          NavyHeader(
            title: "Admin Panel",
            subtitle: AppConstants.appName,
            actions: [
              CircleAvatar(
                radius: AppRadius.lg,
                backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                child: Text('A', style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold)),
              ),
            ],
          ),

          // SLIVER 2 — Stat Cards
          _buildStatCardsGrid(),

          // SLIVER 3 — Branch Distribution
          _buildBranchDistribution(),

          const SizedBox(height: AppSpacing.xl).toSliver,

          // SLIVER 4 — Course Distribution
          _buildCourseDistribution(),

          const SizedBox(height: AppSpacing.xl).toSliver,

          // SLIVER 5 — Recent Announcements
          _buildRecentNotices(context),
        ],
      ),
    );
  }

  Widget _buildStatCardsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                label: "Total Students",
                value: totalStudents.toString(),
                icon: Icons.school_rounded,
                color: AppColors.navyBlueBase,
              ),
              StatCard(
                label: "Professors",
                value: totalProfessors.toString(),
                icon: Icons.person_rounded,
                color: AppColors.oceanBlue,
              ),
              StatCard(
                label: "Active Batches",
                value: activeBatches.toString(),
                icon: Icons.class_rounded,
                color: AppColors.success,
              ),
              StatCard(
                label: "Pending Fees",
                value: "₹${totalFeesPending.toStringAsFixed(0)}",
                icon: Icons.payments_rounded,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchDistribution() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: DashboardCard(
          title: "Students by Branch",
          icon: Icons.bar_chart_rounded,
          child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (branchCounts.values.isEmpty ? 10 : branchCounts.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.navyBlueBase,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < AppConstants.branches.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              AppConstants.branches[index].substring(0, 3),
                              style: AppTextStyles.caption,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDistribution() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: DashboardCard(
          title: "Course Distribution",
          icon: Icons.pie_chart_rounded,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _generatePieSections(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AttendanceDot(color: AppColors.course11th, label: "11th"),
                  SizedBox(width: AppSpacing.lg),
                  _AttendanceDot(color: AppColors.course12th, label: "12th"),
                  SizedBox(width: AppSpacing.lg),
                  _AttendanceDot(color: AppColors.courseCrash, label: "Crash"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotices(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: DashboardCard(
          title: "Recent Notices",
          actionLabel: "All",
          onAction: () => context.goNamed(AppRoutes.adminAnnouncementsName),
          child: Column(
            children: recentNotices.map((notice) => Column(
              children: [
                AnnouncementTile(announcement: notice),
                if (notice != recentNotices.last) const Divider(height: AppSpacing.xxl),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }


  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(AppConstants.branches.length, (i) {
      final branch = AppConstants.branches[i];
      final count = branchCounts[branch] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: AppColors.navyBlueBase,
            width: AppSpacing.lg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs)),
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> _generatePieSections() {
    final colors = [AppColors.course11th, AppColors.course12th, AppColors.courseCrash];
    int i = 0;
    return courseCounts.entries.map((entry) {
      final index = i++;
      final value = entry.value.toDouble();
      final shortLabel = entry.key.split(' ')[0];
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '$shortLabel\n${value.toInt()}',
        radius: 80,
        titleStyle: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();
  }
}

class _AttendanceDot extends StatelessWidget {
  final Color color;
  final String label;
  const _AttendanceDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: AppSpacing.sm, height: AppSpacing.sm, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

extension on Widget {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}
