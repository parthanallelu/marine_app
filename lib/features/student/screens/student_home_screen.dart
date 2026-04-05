import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentUser as StudentModel;
    final now = DateTime.now();

    // Compute data
    final records = DummyData.generateAttendanceForStudent(student.id, student.name, student.batchId);
    final attendance = DummyData.attendanceSummaryFor(student.id, records);
    
    final results = DummyData.testResults.where((r) => r.studentId == student.id).toList();
    final avgScore = results.isEmpty
        ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length;
    
    final feeRecord = DummyData.feeRecords.firstWhere(
      (f) => f.studentId == student.id,
      orElse: () => DummyData.feeRecords.first,
    );

    final announcements = DummyData.announcements.where((a) {
      final courseMatch = a.targetCourses.contains(student.courseType);
      final branchMatch = a.targetBranches.contains(student.branch) || a.targetBranches.length >= 4;
      return courseMatch && branchMatch;
    }).toList();

    final upcomingTests = DummyData.tests
        .where((t) => t.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Header widget _StudentHeader
          SliverToBoxAdapter(
            child: _StudentHeader(student: student, announcementCount: announcements.length),
          ),

          // SLIVER 2 — Stats Row
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: "Attendance",
                      value: attendance.percentageLabel,
                      icon: Icons.calendar_month_rounded,
                      color: attendance.percentage >= 85
                          ? AppColors.success
                          : (attendance.percentage >= 75 ? AppColors.warning : AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: "Test Average",
                      value: "${avgScore.toStringAsFixed(0)}%",
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.oceanBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: "Fees Paid",
                      value: "${feeRecord.percentagePaid.toStringAsFixed(0)}%",
                      icon: Icons.receipt_long_rounded,
                      color: feeRecord.pendingAmount > 0 ? AppColors.warning : AppColors.success,
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
                        onTap: () => context.go(AppRoutes.studentAttendance),
                      ),
                      QuickActionTile(
                        label: "Mock Tests",
                        icon: Icons.quiz_rounded,
                        color: AppColors.oceanBlue,
                        onTap: () => context.go(AppRoutes.studentTests),
                      ),
                      QuickActionTile(
                        label: "Study Mat.",
                        icon: Icons.menu_book_rounded,
                        color: AppColors.success,
                        onTap: () => context.go(AppRoutes.studentMaterials),
                      ),
                      QuickActionTile(
                        label: "Interview",
                        icon: Icons.record_voice_over_rounded,
                        color: AppColors.gold,
                        onTap: () => context.go(AppRoutes.studentMaterials),
                      ),
                      QuickActionTile(
                        label: "Maritime GK",
                        icon: Icons.anchor_rounded,
                        color: AppColors.courseCrash,
                        onTap: () => context.go(AppRoutes.studentMaterials),
                      ),
                      QuickActionTile(
                        label: "Fees",
                        icon: Icons.receipt_rounded,
                        color: AppColors.course12th,
                        onTap: () => context.push('${AppRoutes.studentProfile}/fees'),
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
                        badgeCount: announcements.length,
                        onTap: () => context.push('${AppRoutes.studentProfile}/announcements'),
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: DashboardCard(
                title: "Upcoming Tests",
                icon: Icons.quiz_rounded,
                iconColor: AppColors.oceanBlue,
                actionLabel: "All Tests",
                onAction: () => context.go(AppRoutes.studentTests),
                child: Column(
                  children: upcomingTests.take(3).map((t) => _UpcomingTestTile(test: t)).toList(),
                ),
              ),
            ),
          ),

          // SLIVER 5 — Announcements
          if (announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: DashboardCard(
                  title: "Announcements",
                  icon: Icons.announcement_rounded,
                  iconColor: AppColors.warning,
                  child: Column(
                    children: announcements.take(2).map((a) => _AnnouncementTile(announcement: a)).toList(),
                  ),
                ),
              ),
            ),

          // SLIVER 6 — Target Company card
          if (student.targetCompany.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha((0.2 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_boat_filled_rounded, color: AppColors.gold, size: 28),
                      ),
                      const SizedBox(width: 16),
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
                        onPressed: () => context.go(AppRoutes.studentTests),
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
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
    final hour = DateTime.now().hour;
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      Text(
                        student.name.split(' ')[0],
                        style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => context.push('${AppRoutes.studentProfile}/announcements'),
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
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.navyBlueDark),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                    child: Text(
                      student.name[0],
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CourseBadge(courseType: student.courseType),
                  const SizedBox(width: 8),
                  BranchBadge(branch: student.branch),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.batchName,
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: AppTextStyles.caption.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingTestTile extends StatelessWidget {
  final TestModel test;
  const _UpcomingTestTile({required this.test});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = test.scheduledDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    String daysLabel;
    bool isUrgent = difference <= 2;
    if (difference == 0) {
      daysLabel = "Today";
    } else if (difference == 1) {
      daysLabel = "Tomorrow";
    } else {
      daysLabel = "In $difference days";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.oceanBlueSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.oceanBlue.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.quiz_rounded, color: AppColors.oceanBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: AppTextStyles.labelLarge),
                Text(
                  "${test.durationMinutes}m • ${test.questions.length} Questions",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.errorSurface : AppColors.navyBlueSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              daysLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: isUrgent ? AppColors.error : AppColors.navyBlueBase,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementTile({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final isHigh = announcement.priority.toLowerCase() == 'high';
    final bgColor = isHigh ? AppColors.errorSurface : AppColors.warningSurface;
    final color = isHigh ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isHigh ? Icons.push_pin_rounded : Icons.announcement_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  announcement.description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PriorityTag(priority: announcement.priority),
        ],
      ),
    );
  }
}
