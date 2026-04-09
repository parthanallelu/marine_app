import 'package:flutter/material.dart';
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
  int totalStudents = 0;
  int totalProfessors = 0;
  int activeBatches = 0;
  double totalFeesPending = 0.0;
  double totalCollected = 0.0;
  double totalFees = 0.0;
  double collectedPct = 0.0;
  Map<String, int> branchCounts = {};
  Map<String, int> courseCounts = {};
  List<dynamic> feeAlerts = [];
  List<Map<String, dynamic>> attendanceAlerts = [];

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  void _computeData() {
    try {
      final now = DateTime.now();
      
      totalStudents = DummyData.students.length;
      totalProfessors = DummyData.professors.length;
      activeBatches = DummyData.batches.where((b) => b.isActive).length;

      // Fees computation
      totalFeesPending = DummyData.feeRecords.fold<double>(0.0, (sum, r) => sum + r.pendingAmount);
      totalCollected = DummyData.feeRecords.fold<double>(0.0, (sum, r) => sum + r.paidAmount);
      totalFees = totalCollected + totalFeesPending;
      collectedPct = totalFees > 0 ? (totalCollected / totalFees) : 0.0;

      // Alerts logic
      feeAlerts = [];
      for (var record in DummyData.feeRecords) {
        for (var inst in record.installments) {
          if (inst.status == FeeStatus.overdue || 
             (inst.status == FeeStatus.pending && inst.dueDate.isBefore(now))) {
            feeAlerts.add({
              'studentName': record.studentName,
              'amount': inst.amount,
              'title': inst.title,
              'daysLate': now.difference(inst.dueDate).inDays,
            });
          }
        }
      }

      attendanceAlerts = [];
      for (var s in DummyData.students) {
        final summary = DummyData.attendanceSummaryFor(s.id, DummyData.generateAttendanceForStudent(s.id, s.name, s.batchId));
        if (summary.percentage < 75) {
          attendanceAlerts.add({
            'student': s,
            'percentageLabel': summary.percentageLabel,
          });
        }
      }

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
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Error computing admin statistics: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _AdminHeader()),
          _buildStatsGrid(),
          _buildQuickActions(context),
          _buildAlertsSection(context),
          _buildFeeProgress(context),
          _buildBranchChart(),
          _buildCourseDistribution(),
          _buildRecentActivity(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Transform.translate(
          offset: const Offset(0, -20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                label: "Total Students",
                value: totalStudents.toString(),
                subLabel: "Across 4 branches",
                icon: Icons.group_rounded,
                iconBg: AppColors.navyBlueSurface,
                iconColor: AppColors.navyBlueBase,
                trendLabel: "+2 this mo",
                trendBg: AppColors.successSurface,
                trendColor: AppColors.success,
              ),
              _StatCard(
                label: "Professors",
                value: totalProfessors.toString(),
                subLabel: "${DummyData.professors.length} subjects covered",
                icon: Icons.person_rounded,
                iconBg: AppColors.oceanBlueSurface,
                iconColor: AppColors.oceanBlue,
                trendLabel: "All active",
                trendBg: AppColors.navyBlueSurface,
                trendColor: AppColors.navyBlueBase,
              ),
              _StatCard(
                label: "Active Batches",
                value: activeBatches.toString(),
                subLabel: "Mon–Sat schedule",
                icon: Icons.menu_book_rounded,
                iconBg: AppColors.successSurface,
                iconColor: AppColors.success,
                trendLabel: "Running",
                trendBg: AppColors.successSurface,
                trendColor: AppColors.success,
              ),
              _StatCard(
                label: "Pending Fees",
                value: "₹${(totalFeesPending / 1000).toStringAsFixed(0)}k",
                subLabel: "Needs follow-up",
                icon: Icons.payments_rounded,
                iconBg: AppColors.errorSurface,
                iconColor: AppColors.error,
                valueColor: AppColors.error,
                trendLabel: "Overdue: ${feeAlerts.length}",
                trendBg: AppColors.errorSurface,
                trendColor: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Quick Actions"),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              children: [
                QuickActionTile(
                  label: "Add Student",
                  icon: Icons.person_add_rounded,
                  color: AppColors.navyBlueBase,
                  onTap: () => context.goNamed(AppRoutes.adminStudentsName),
                ),
                QuickActionTile(
                  label: "New Batch",
                  icon: Icons.add_box_rounded,
                  color: AppColors.oceanBlue,
                  onTap: () => context.goNamed(AppRoutes.adminBatchesName),
                ),
                QuickActionTile(
                  label: "Post Notice",
                  icon: Icons.campaign_rounded,
                  color: AppColors.warning,
                  onTap: () => context.goNamed(AppRoutes.adminAnnouncementsName),
                ),
                QuickActionTile(
                  label: "Upload Material",
                  icon: Icons.upload_file_rounded,
                  color: AppColors.success,
                  onTap: () => AppSnackBar.showSuccess(context, "Upload functionality coming soon!"),
                ),
                QuickActionTile(
                  label: "Record Fee",
                  icon: Icons.credit_card_rounded,
                  color: AppColors.error,
                  onTap: () => context.goNamed(AppRoutes.adminFeesName),
                ),
                QuickActionTile(
                  label: "View Reports",
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.gold,
                  onTap: () => AppSnackBar.showInfo(context, "Reports coming soon"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    bool hasAlerts = feeAlerts.isNotEmpty || attendanceAlerts.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Alerts Needing Action"),
            const SizedBox(height: 12),
            if (!hasAlerts)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withAlpha((0.2 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text("All clear — no issues today", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success)),
                  ],
                ),
              )
            else ...[
              ...feeAlerts.take(2).map((alert) => _AlertTile(
                title: "Fee overdue — ${alert['studentName']}",
                subtitle: "₹${alert['amount']} · ${alert['title']} · ${alert['daysLate']} days late",
                actionLabel: "Follow up →",
                icon: Icons.error_rounded,
                color: AppColors.error,
                bgColor: AppColors.errorSurface,
                borderColor: AppColors.divider,
                onTap: () => context.goNamed(AppRoutes.adminFeesName),
              )),
              ...attendanceAlerts.take(2).map((alert) {
                final StudentModel student = alert['student'];
                return _AlertTile(
                  title: "Low attendance — ${student.name}",
                  subtitle: "${alert['percentageLabel']} · Below 75% threshold · ${student.branch}",
                  actionLabel: "Notify →",
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.warning,
                  bgColor: AppColors.warningSurface,
                  borderColor: AppColors.warningSurface,
                  onTap: () => AppSnackBar.showInfo(context, "Notification sent to ${student.name}"),
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeProgress(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            SectionHeader(
              title: "Fee Collection Progress",
              actionLabel: "Details →",
              onAction: () => context.goNamed(AppRoutes.adminFeesName),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(child: Text("₹${(totalCollected / 1000).toStringAsFixed(0)}k", style: AppTextStyles.headingSmall.copyWith(color: AppColors.success))),
                            Text("Collected", style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppColors.divider),
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(child: Text("₹${(totalFeesPending / 1000).toStringAsFixed(0)}k", style: AppTextStyles.headingSmall.copyWith(color: AppColors.error))),
                            Text("Pending", style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppColors.divider),
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(child: Text("₹${(totalFees / 1000).toStringAsFixed(0)}k", style: AppTextStyles.headingSmall)),
                            Text("Total", style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: collectedPct,
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      color: AppColors.oceanBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${(collectedPct * 100).toStringAsFixed(0)}% collected", style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                      Text("₹${(totalFeesPending / 1000).toStringAsFixed(0)}k remaining", style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchChart() {
    final maxCount = branchCounts.values.isEmpty ? 1 : branchCounts.values.reduce((a, b) => a > b ? a : b);
    final colors = [AppColors.navyBlueBase, AppColors.oceanBlue, AppColors.navyBlueLight, AppColors.textHint];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const SectionHeader(title: "Students by Branch"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: List.generate(AppConstants.branches.length, (i) {
                  final branch = AppConstants.branches[i];
                  final count = branchCounts[branch] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(branch, style: AppTextStyles.labelMedium.copyWith(fontSize: 13), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(height: 8, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8))),
                              FractionallySizedBox(
                                widthFactor: count / maxCount,
                                child: Container(height: 8, decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(8))),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(width: 20, child: FittedBox(child: Text(count.toString(), style: AppTextStyles.labelMedium.copyWith(fontSize: 12), textAlign: TextAlign.right))),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDistribution() {
    final c11 = courseCounts['11th Science'] ?? 0;
    final c12 = courseCounts['12th Science'] ?? 0;
    final crash = courseCounts['Crash Course'] ?? 0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const SectionHeader(title: "Course Distribution"),
            const SizedBox(height: 12),
            Row(
              children: [
                _CourseChip(label: "11th Science", count: c11, color: AppColors.course11th, bgColor: AppColors.navyBlueSurface),
                const SizedBox(width: 8),
                _CourseChip(label: "12th Science", count: c12, color: AppColors.course12th, bgColor: AppColors.navyBlueSurface),
                const SizedBox(width: 8),
                _CourseChip(label: "Crash Course", count: crash, color: AppColors.courseCrash, bgColor: AppColors.errorSurface),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            SectionHeader(title: "Recent Activity", actionLabel: "View All →", onAction: () {}),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  _ActivityRow(
                    icon: Icons.how_to_reg_rounded,
                    iconColor: AppColors.navyBlueBase,
                    iconBg: AppColors.navyBlueSurface,
                    title: "Attendance marked — Batch A Morning",
                    subtitle: "Capt. Anil Mehta · Camp · 5 present, 1 absent",
                    time: "2h ago",
                    isLast: false,
                  ),
                  _ActivityRow(
                    icon: Icons.upload_file_rounded,
                    iconColor: AppColors.success,
                    iconBg: AppColors.successSurface,
                    title: "New material uploaded",
                    subtitle: "IMU-CET Guide 2024 · Prof. Sunita Rao",
                    time: "5h ago",
                    isLast: false,
                  ),
                  _ActivityRow(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.gold,
                    iconBg: AppColors.goldSurface,
                    title: "Fee paid — Arjun Sharma",
                    subtitle: "₹15,000 · 1st installment · UPI",
                    time: "Yesterday",
                    isLast: false,
                  ),
                  _ActivityRow(
                    icon: Icons.campaign_rounded,
                    iconColor: AppColors.error,
                    iconBg: AppColors.errorSurface,
                    title: "Announcement posted",
                    subtitle: "IMU-CET deadline · High priority · All branches",
                    time: "2 days ago",
                    isLast: true,
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

class _AdminHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.navyBlueBase,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin Panel", style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                    Text(AppConstants.appName, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha((0.6 * 255).round()), fontSize: 13)),
                  ],
                ),
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.gold.withAlpha((0.25 * 255).round()),
                    child: Text("CM", style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text("Live", style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.55 * 255).round()), fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Wednesday, 9 April 2025 · All Branches",
            style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.45 * 255).round()), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String trendLabel;
  final Color trendBg;
  final Color trendColor;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.trendLabel,
    required this.trendBg,
    required this.trendColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: trendBg, borderRadius: BorderRadius.circular(20)),
                child: Text(trendLabel, style: AppTextStyles.labelSmall.copyWith(color: trendColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.headingLarge.copyWith(fontSize: 26, fontWeight: FontWeight.w500, color: valueColor)),
          ),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
          Text(subLabel, style: AppTextStyles.caption.copyWith(color: valueColor ?? AppColors.textSecondary, fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(8)),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
                            Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 11, color: color.withAlpha((0.7 * 255).round()))),
                          ],
                        ),
                      ),
                      Text(actionLabel, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
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

class _CourseChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _CourseChip({required this.label, required this.count, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.withAlpha((0.1 * 255).round())),
        ),
        child: Column(
          children: [
            FittedBox(child: Text(count.toString(), style: AppTextStyles.headingMedium.copyWith(color: color, fontSize: 20, fontWeight: FontWeight.w500))),
            Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String time;
  final bool isLast;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.textHint.withAlpha((0.1 * 255).round()), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 10)),
        ],
      ),
    );
  }
}
