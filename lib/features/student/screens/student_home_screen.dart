import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart'
    show
        AnnouncementTile,
        AppSnackBar,
        QuickActionTile,
        SectionHeader,
        StudentStatCard,
        UpcomingTestTile;
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

      final records = DummyData.generateAttendanceForStudent(
        student.id,
        student.name,
        student.batchId,
      );
      _attendanceSummary = DummyData.attendanceSummaryFor(student.id, records);

      final results = DummyData.testResults
          .where((r) => r.studentId == student.id)
          .toList();
      _avgScore = results.isEmpty
          ? 0.0
          : results.map((r) => r.percentage).reduce((a, b) => a + b) /
                results.length;

      _feeRecord = DummyData.feeRecords.firstWhere(
        (f) => f.studentId == student.id,
        orElse: () => DummyData.feeRecords.first,
      );

      _announcements = DummyData.announcements.where((a) {
        final courseMatch = a.targetCourses.contains(student.courseType);
        final branchMatch =
            a.targetBranches.contains(student.branch) ||
            a.targetBranches.length >= 4;
        return courseMatch && branchMatch;
      }).toList();

      _upcomingTests =
          DummyData.tests.where((t) => t.scheduledDate.isAfter(now)).toList()
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

    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final student = authProvider.currentUser as StudentModel;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      endDrawer: const StudentDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(
              student: student,
              announcementCount: _announcements.length,
            ),
            SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsRow(),
                  _buildQuickActions(context),
                  _buildTargetCompany(context, student),
                  _buildUpcomingTests(context),
                  if (_announcements.isNotEmpty) _buildAnnouncements(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final bool isLowAttendance = _attendanceSummary.percentage < 85;
    final String attendanceStatus = isLowAttendance ? "⚠ Below 85%" : "✓ Good";

    final bool hasDue = _feeRecord.pendingAmount > 0;
    final String feeStatus = hasDue
        ? "₹${(_feeRecord.pendingAmount / 1000).toStringAsFixed(1)}k due"
        : "✓ Cleared";

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: StudentStatCard(
              label: "Attendance",
              value: _attendanceSummary.percentageLabel,
              icon: Icons.calendar_today_outlined,
              valueColor: AppColors.teal,
              statusLabel: attendanceStatus,
              statusColor: isLowAttendance ? AppColors.gold : AppColors.teal,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StudentStatCard(
            label: "Test Avg",
            value: "${_avgScore.toStringAsFixed(0)}%",
            icon: Icons.bar_chart_rounded,
            valueColor: AppColors.primaryLight,
            statusLabel: "✓ ${_upcomingTests.length} done",
            statusColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StudentStatCard(
              label: "Fees Paid",
              value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
              icon: Icons.attach_money_rounded,
              valueColor: AppColors.gold,
              statusLabel: feeStatus,
              statusColor: hasDue ? AppColors.error : AppColors.success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 20, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "Quick Actions",
                  style: AppTextStyles.headingSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.80,
            children: [
              QuickActionTile(
                label: "Attendance",
                icon: Icons.calendar_today_outlined,
                color: AppColors.primaryLight,
                onTap: () => context.goNamed(AppRoutes.studentAttendanceName),
              ),
              QuickActionTile(
                label: "Mock Tests",
                icon: Icons.check_box_outlined,
                color: AppColors.purple,
                onTap: () => context.goNamed(AppRoutes.studentTestsName),
              ),
              QuickActionTile(
                label: "Materials",
                icon: Icons.book_outlined,
                color: AppColors.teal,
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              QuickActionTile(
                label: "Interview",
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.orange,
                onTap: () => context.goNamed(AppRoutes.studentInterviewName),
              ),
              QuickActionTile(
                label: "Maritime GK",
                icon: Icons.shield_outlined,
                color: const Color(0xFF42A5F5),
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              QuickActionTile(
                label: "Fees",
                icon: Icons.attach_money_rounded,
                color: AppColors.error,
                onTap: () => context.pushNamed(AppRoutes.studentFeesName),
              ),
              QuickActionTile(
                label: "Notices",
                icon: Icons.notifications_none_rounded,
                color: AppColors.gold,
                badgeCount: _announcements.length,
                onTap: () =>
                    context.pushNamed(AppRoutes.studentAnnouncementsName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCompany(BuildContext context, StudentModel student) {
    if (student.targetCompany.isEmpty &&
        DummyData.students.first.targetCompany.isEmpty) {
      return const SizedBox();
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : theme.colorScheme.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDark ? AppColors.borderCardDark : AppColors.borderLight,
            width: isDark ? 0.8 : 1,
          ),
          boxShadow: isDark ? AppShadows.none : AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF202C40)
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.directions_boat_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Target company",
                    style: AppTextStyles.overline.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Maersk Line",
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.gold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Company-specific prep ready",
                    style: AppTextStyles.caption.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.goNamed(AppRoutes.studentTestsName),
              child: Text(
                "Practice",
                style: AppTextStyles.labelMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTests(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: SectionHeader(
              title: "Upcoming Tests",
              icon: Icons.access_time_rounded,
              iconColor: AppColors.primaryLight,
              actionLabel: "All Tests",
              onAction: () => context.goNamed(AppRoutes.studentTestsName),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_upcomingTests.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "No upcoming tests scheduled",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            )
          else
            Column(
              children: _upcomingTests
                  .take(2)
                  .map(
                    (t) => UpcomingTestTile(
                      test: t,
                      onTap: () => context.pushNamed(
                        AppRoutes.testAttemptName,
                        pathParameters: {'testId': t.id},
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: SectionHeader(
              title: "Announcements",
              icon: Icons.notifications_active_rounded,
              iconColor: AppColors.gold,
              actionLabel: "View All",
              onAction: () =>
                  context.pushNamed(AppRoutes.studentAnnouncementsName),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: _announcements
                .take(2)
                .map(
                  (a) => AnnouncementTile(
                    announcement: a,
                    onTap: () =>
                        context.pushNamed(AppRoutes.studentAnnouncementsName),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// THEME-AWARE REUSABLE LOCAL WIDGETS
// ---------------------------------------------------------

class _DashboardHeader extends StatelessWidget {
  final StudentModel student;
  final int announcementCount;

  const _DashboardHeader({
    required this.student,
    required this.announcementCount,
  });

  @override
  Widget build(BuildContext context) {
    String initials = "S";
    if (student.name.trim().isNotEmpty) {
      final parts = student.name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.navyChrome
                : AppColors.navyChromeLight,
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0D1F35)
                : const Color(0xFF0E3578),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.error,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    student.name.toUpperCase(),
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.notifications_none_rounded,
                    badgeCount: announcementCount,
                    onTap: () =>
                        context.pushNamed(AppRoutes.studentAnnouncementsName),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Builder(
                    builder: (ctx) => _ActionButton(
                      icon: Icons.menu_rounded,
                      onTap: () => Scaffold.of(ctx).openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF162133)
                  : AppColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark
                    ? AppColors.borderCardDark
                    : AppColors.borderLight,
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface.withAlpha(180),
              size: 22,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 6, height: 6),
              ),
            ),
        ],
      ),
    );
  }
}
