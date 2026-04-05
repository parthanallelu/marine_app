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
                radius: 18,
                backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                child: const Text('A', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // SLIVER 2 — 4 Stat Cards in 2×2 Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 220, // Adjust height to fit 2 rows
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
                      color: AppColors.error, // Warning/Error color for collections
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SLIVER 3 — Branch Distribution DashboardCard
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  padding: const EdgeInsets.only(top: 8.0),
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
          ),

          const SizedBox(height: 20).toSliver,

          // SLIVER 4 — Course Distribution DashboardCard
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AttendanceDot(color: const Color(0xFF1565C0), label: "11th"),
                        const SizedBox(width: 16),
                        _AttendanceDot(color: const Color(0xFF6A1B9A), label: "12th"),
                        const SizedBox(width: 16),
                        _AttendanceDot(color: const Color(0xFFBF360C), label: "Crash"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20).toSliver,

          // SLIVER 5 — Recent Announcements DashboardCard
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: DashboardCard(
                title: "Recent Notices",
                actionLabel: "All",
                onAction: () => context.go(AppRoutes.adminAnnouncements),
                child: Column(
                  children: recentNotices.map((notice) => Column(
                    children: [
                      AnnouncementTile(announcement: notice),
                      if (notice != recentNotices.last) const Divider(height: 24),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ),
        ],
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
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> _generatePieSections() {
    final colors = [const Color(0xFF1565C0), const Color(0xFF6A1B9A), const Color(0xFFBF360C)];
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
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

extension on Widget {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}
