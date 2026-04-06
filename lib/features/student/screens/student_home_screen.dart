import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

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
    
    // TODO: Replace DummyData with Firestore query:
    // final studentData = await studentRepository.getStudentDashboard(studentId);
    
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

    setState(() => _isLoading = false);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Header widget _StudentHeader
          SliverToBoxAdapter(
            child: _StudentHeader(student: student, announcementCount: _announcements.length),
          ),

          // SLIVER 2 — Stats Row
          SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: "Attendance",
                      value: _attendanceSummary.percentageLabel,
                      icon: Icons.calendar_month_rounded,
                      color: _attendanceSummary.percentage >= AppConstants.attendanceGood
                          ? AppColors.success
                          : (_attendanceSummary.percentage >= AppConstants.attendanceWarning ? AppColors.warning : AppColors.error),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: "Test Average",
                      value: "${_avgScore.toStringAsFixed(0)}%",
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.oceanBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: "Fees Paid",
                      value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
                      icon: Icons.receipt_long_rounded,
                      color: _feeRecord.pendingAmount > 0 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 3 — Quick Actions
          SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Quick Actions"),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
                    children: [
                      QuickActionTile(
                        label: "Attendance",
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.navyBlueBase,
                        onTap: () => context.goNamed(AppRoutes.studentAttendanceName),
                      ),
                      QuickActionTile(
                        label: "Mock Tests",
                        icon: Icons.quiz_rounded,
                        color: AppColors.oceanBlue,
                        onTap: () => context.goNamed(AppRoutes.studentTestsName),
                      ),
                      QuickActionTile(
                        label: "Study Mat.",
                        icon: Icons.menu_book_rounded,
                        color: AppColors.success,
                        onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
                      ),
                      QuickActionTile(
                        label: "Interview",
                        icon: Icons.record_voice_over_rounded,
                        color: AppColors.gold,
                        onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
                      ),
                      QuickActionTile(
                        label: "Maritime GK",
                        icon: Icons.anchor_rounded,
                        color: AppColors.courseCrash,
                        onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
                      ),
                      QuickActionTile(
                        label: "Fees",
                        icon: Icons.receipt_rounded,
                        color: AppColors.course12th,
                        onTap: () => context.pushNamed(AppRoutes.studentFeesName),
                      ),
                      QuickActionTile(
                        label: "Schedule",
                        icon: Icons.schedule_rounded,
                        color: AppColors.oceanBlue,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Schedule feature coming soon!")),
                        ),
                      ),
                      QuickActionTile(
                        label: "Notice Board",
                        icon: Icons.announcement_rounded,
                        color: AppColors.warning,
                        badgeCount: _announcements.length,
                        onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 4 — Upcoming Tests
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              child: DashboardCard(
                title: "Upcoming Tests",
                icon: Icons.quiz_rounded,
                iconColor: AppColors.oceanBlue,
                actionLabel: "All Tests",
                onAction: () => context.goNamed(AppRoutes.studentTestsName),
                child: _upcomingTests.isEmpty 
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text("No upcoming tests scheduled", style: AppTextStyles.bodyMedium),
                      )
                    : Column(
                        children: _upcomingTests.take(3).map((t) => UpcomingTestTile(
                          test: t, 
                          onTap: () => context.pushNamed(AppRoutes.testAttemptName, pathParameters: {'testId': t.id}),
                        )).toList(),
                      ),
              ),
            ),
          ),

          // SLIVER 5 — Announcements
          if (_announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
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
              ),
            ),

          // SLIVER 6 — Target Company card
          if (student.targetCompany.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxxl),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.navyBlueDark, AppColors.navyBlueBase],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.cardRadius,
                    boxShadow: AppShadows.elevated,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha((0.2 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_boat_filled_rounded, color: AppColors.gold, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.targetCompany,
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold),
                            ),
                            Text(
                              "Focus on your dream company",
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.goNamed(AppRoutes.studentTestsName),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                        ),
                        child: const Text("Practice"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
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
    final hour = DateTime.now().toUtc().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    if (hour >= 17) greeting = 'Good evening';

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
          padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                      ),
                      Text(
                        student.name.split(' ')[0],
                        style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                  IconButton(
                    onPressed: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                      if (announcementCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                            alignment: Alignment.center,
                      child: Text(
                        announcementCount.toString(),
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 8, color: AppColors.navyBlueDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                    child: Text(
                      student.name[0],
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CourseBadge(courseType: student.courseType),
                  const SizedBox(width: AppSpacing.sm),
                  BranchBadge(branch: student.branch),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      student.batchName,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "${DateTime.now().toUtc().day}/${DateTime.now().toUtc().month}/${DateTime.now().toUtc().year}",
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
