import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import 'widgets/student_drawer.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _isLoading = false;
  late AttendanceSummary _attendanceSummary;
  late double _avgScore;
  late FeeRecord _feeRecord;
  late List<AnnouncementModel> _announcements;
  late List<TestModel> _upcomingTests;

  @override
  void initState() {
    super.initState();
    _calculateDashboardData();
  }

  void _calculateDashboardData() {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final student = authProvider.currentUser as StudentModel;
      final now = DateTime.now().toUtc();

      // Compute attendance
      final records = DummyData.generateAttendanceForStudent(student.id, student.name, student.batchId);
      _attendanceSummary = DummyData.attendanceSummaryFor(student.id, records);
      
      // Compute test stats
      final results = DummyData.testResults.where((r) => r.studentId == student.id).toList();
      _avgScore = results.isEmpty
          ? 0.0
          : results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length;
      
      // Compute fee status
      _feeRecord = DummyData.feeRecords.firstWhere(
        (f) => f.studentId == student.id,
        orElse: () => DummyData.feeRecords.first,
      );

      // Compute announcements
      _announcements = DummyData.announcements.where((a) {
        final courseMatch = a.targetCourses.contains(student.courseType);
        final branchMatch = a.targetBranches.contains(student.branch) || a.targetBranches.length >= 4;
        return courseMatch && branchMatch;
      }).toList();

      // Compute upcoming tests
      _upcomingTests = DummyData.tests
          .where((t) => t.scheduledDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Error loading dashboard: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final student = authProvider.currentUser as StudentModel;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppPageShell(
      title: "Howdy, ${student.name.split(' ')[0]}!",
      subtitle: "Welcome back to your dashboard",
      showBackButton: false,
      showMenuButton: true,
      endDrawer: const StudentDrawer(),
      headerWidgets: [
        Row(
          children: [
            CourseBadge(courseType: student.courseType),
            const SizedBox(width: 8),
            BranchBadge(branch: student.branch),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.batchId,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Wednesday, 8 April 2026",
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
      body: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildStatsRowContent(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildQuickActionsContent(context),
          _buildUpcomingTestsContent(context),
          if (_announcements.isNotEmpty) _buildAnnouncementsContent(context),
          _buildTargetCompanyContent(context, student),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsRowContent() {
    final bool isLowAttendance = _attendanceSummary.percentage < 85;
    final String attendanceStatus = isLowAttendance ? "⚠ Below 85%" : "✓ Good";
    final Color attendanceStatusColor = isLowAttendance ? AppColors.error : AppColors.success;

    final bool hasDue = _feeRecord.pendingAmount > 0;
    final String feeStatus = hasDue ? "₹${(_feeRecord.pendingAmount / 1000).toStringAsFixed(1)}k due" : "✓ Cleared";
    final Color feeStatusColor = hasDue ? AppColors.error : AppColors.success;

    return Row(
      children: [
        Expanded(
          child: StudentStatCard(
            label: "Attendance",
            value: _attendanceSummary.percentageLabel,
            icon: Icons.calendar_today_outlined,
            valueColor: AppColors.success,
            statusLabel: attendanceStatus,
            statusColor: attendanceStatusColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StudentStatCard(
            label: "Test Avg",
            value: "${_avgScore.toStringAsFixed(0)}%",
            icon: Icons.bar_chart_rounded,
            valueColor: AppColors.oceanBlue,
            statusLabel: "✓ ${_upcomingTests.length} tests done",
            statusColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StudentStatCard(
            label: "Fees Paid",
            value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
            icon: Icons.receipt_long_outlined,
            valueColor: AppColors.gold,
            statusLabel: feeStatus,
            statusColor: feeStatusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 20, color: AppColors.warning),
              const SizedBox(width: 8),
              Text("Quick Actions", style: AppTextStyles.headingSmall.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              QuickActionTile(
                label: "Attendance",
                icon: Icons.calendar_month_rounded,
                color: Colors.blue.shade600,
                onTap: () => context.goNamed(AppRoutes.studentAttendanceName),
              ),
              QuickActionTile(
                label: "Mock Tests",
                icon: Icons.help_rounded,
                color: Colors.deepPurple.shade400,
                onTap: () => context.goNamed(AppRoutes.studentTestsName),
              ),
              QuickActionTile(
                label: "Materials",
                icon: Icons.menu_book_rounded,
                color: Colors.green.shade600,
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              QuickActionTile(
                label: "Interview",
                icon: Icons.forum_rounded,
                color: Colors.orange.shade700,
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              QuickActionTile(
                label: "Maritime GK",
                icon: Icons.anchor_rounded,
                color: Colors.blue.shade900,
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              QuickActionTile(
                label: "Fees",
                icon: Icons.receipt_long_rounded,
                color: Colors.purple.shade600,
                onTap: () => context.pushNamed(AppRoutes.studentFeesName),
              ),
              QuickActionTile(
                label: "Schedule",
                icon: Icons.watch_later_rounded,
                color: Colors.brown.shade400,
                onTap: () => AppSnackBar.showInfo(context, "Schedule feature coming soon!"),
              ),
              QuickActionTile(
                label: "Notices",
                icon: Icons.notifications_rounded,
                color: Colors.orange.shade800,
                badgeCount: _announcements.length,
                onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTestsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: DashboardCard(
        title: "Upcoming Tests",
        icon: Icons.quiz_rounded,
        iconColor: AppColors.oceanBlue,
        actionLabel: "All Tests",
        onAction: () => context.goNamed(AppRoutes.studentTestsName),
        child: _upcomingTests.isEmpty 
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text("No upcoming tests scheduled", style: AppTextStyles.bodyMedium),
              )
            : Column(
                children: _upcomingTests.take(3).map((t) => UpcomingTestTile(
                  test: t, 
                  onTap: () => context.pushNamed(AppRoutes.testAttemptName, pathParameters: {'testId': t.id}),
                )).toList(),
              ),
      ),
    );
  }

  Widget _buildAnnouncementsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: DashboardCard(
        title: "Announcements",
        icon: Icons.announcement_rounded,
        iconColor: AppColors.warning,
        actionLabel: "View All",
        onAction: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
        child: Column(
          children: _announcements.take(2).map((a) => AnnouncementTile(
            announcement: a,
            onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildTargetCompanyContent(BuildContext context, StudentModel student) {
    if (student.targetCompany.isEmpty) return const SizedBox(height: 32);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF071C47),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).round()),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_boat_rounded, color: AppColors.gold, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Target company",
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha((0.5 * 255).round()), fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.targetCompany,
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Company-specific prep available",
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha((0.5 * 255).round()), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.goNamed(AppRoutes.studentTestsName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Text(
                  "Practice",
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StudentHeader extends StatelessWidget {
  final StudentModel student;
  final int announcementCount;

  const _StudentHeader({required this.student, required this.announcementCount});

  @override
  Widget build(BuildContext context) {
    final initials = student.name.split(' ').take(2).map((s) => s[0]).join().toUpperCase();
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071C47), Color(0xFF0A2A66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 44), // Extra bottom padding for overlap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good afternoon",
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha((0.65 * 255).round())),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.name.split(' ')[0],
                          style: AppTextStyles.headingLarge.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha((0.12 * 255).round()),
                      shape: const CircleBorder(),
                    ),
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        if (announcementCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.gold.withAlpha((0.25 * 255).round()),
                    child: Text(
                      initials,
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CourseBadge(courseType: student.courseType),
                  const SizedBox(width: 8),
                  BranchBadge(branch: student.branch),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.batchId,
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Wednesday, 8 April 2026", // Mock date for UI match
                style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.45 * 255).round())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
