import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart' show AppSnackBar, CourseBadge, BranchBadge;
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import 'widgets/student_drawer.dart';

const Color _bgDark = Color(0xFF0F172A);
const Color _cardDark = Color(0xFF161F30);
const Color _borderDark = Color(0xFF2E3B4E);
const Color _textMuted = Color(0xFF94A3B8);

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

      final records = DummyData.generateAttendanceForStudent(student.id, student.name, student.batchId);
      _attendanceSummary = DummyData.attendanceSummaryFor(student.id, records);
      
      final results = DummyData.testResults.where((r) => r.studentId == student.id).toList();
      _avgScore = results.isEmpty
          ? 0.0
          : results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length;
      
      _feeRecord = DummyData.feeRecords.firstWhere(
        (f) => f.studentId == student.id,
        orElse: () => DummyData.feeRecords.first,
      );

      _announcements = DummyData.announcements.where((a) {
        final courseMatch = a.targetCourses.contains(student.courseType);
        final branchMatch = a.targetBranches.contains(student.branch) || a.targetBranches.length >= 4;
        return courseMatch && branchMatch;
      }).toList();

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
    
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final student = authProvider.currentUser as StudentModel;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bgDark,
      endDrawer: const StudentDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DarkDashboardHeader(
                student: student,
                announcementCount: _announcements.length,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsRowContent(),
              ),
              _buildQuickActionsContent(context),
              _buildTargetCompanyContent(context, student),
              _buildUpcomingTestsContent(context),
              if (_announcements.isNotEmpty) _buildAnnouncementsContent(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRowContent() {
    final bool isLowAttendance = _attendanceSummary.percentage < 85;
    final String attendanceStatus = isLowAttendance ? "⚠ Below 85%" : "✓ Good";

    final bool hasDue = _feeRecord.pendingAmount > 0;
    final String feeStatus = hasDue ? "₹${(_feeRecord.pendingAmount / 1000).toStringAsFixed(1)}k due" : "✓ Cleared";

    return Row(
      children: [
        Expanded(
          child: _DarkStatCard(
            label: "Attendance",
            value: _attendanceSummary.percentageLabel,
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFF20B2AA), 
            statusLabel: attendanceStatus,
            statusColor: isLowAttendance ? const Color(0xFFD4A017) : const Color(0xFF20B2AA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DarkStatCard(
            label: "Test Avg",
            value: "${_avgScore.toStringAsFixed(0)}%",
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF5C8DF6),  
            statusLabel: "✓ ${_upcomingTests.length} done",
            statusColor: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DarkStatCard(
            label: "Fees Paid",
            value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
            icon: Icons.attach_money_rounded,
            color: const Color(0xFFD4A017), 
            statusLabel: feeStatus,
            statusColor: hasDue ? const Color(0xFFD05454) : const Color(0xFF2E7D32), 
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 20, color: Color(0xFFD4A017)),
              const SizedBox(width: 8),
              Text("Quick Actions", style: AppTextStyles.headingSmall.copyWith(fontSize: 16, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.80,
            children: [
              _DarkQuickActionTile(
                label: "Attendance",
                icon: Icons.calendar_today_outlined,
                color: const Color(0xFF5C8DF6),
                onTap: () => context.goNamed(AppRoutes.studentAttendanceName),
              ),
              _DarkQuickActionTile(
                label: "Mock Tests",
                icon: Icons.check_box_outlined,
                color: const Color(0xFF916BDB), 
                onTap: () => context.goNamed(AppRoutes.studentTestsName),
              ),
              _DarkQuickActionTile(
                label: "Materials",
                icon: Icons.book_outlined,
                color: const Color(0xFF20B2AA), 
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              _DarkQuickActionTile(
                label: "Interview",
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFFC47B44), 
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              _DarkQuickActionTile(
                label: "Maritime GK",
                icon: Icons.shield_outlined,
                color: const Color(0xFF42A5F5), 
                onTap: () => context.goNamed(AppRoutes.studentMaterialsName),
              ),
              _DarkQuickActionTile(
                label: "Fees",
                icon: Icons.attach_money_rounded,
                color: const Color(0xFFD05454), 
                onTap: () => context.pushNamed(AppRoutes.studentFeesName),
              ),
              _DarkQuickActionTile(
                label: "Schedule",
                icon: Icons.access_time_rounded,
                color: const Color(0xFF2E7D32), 
                onTap: () => AppSnackBar.showInfo(context, "Schedule feature coming soon!"),
              ),
              _DarkQuickActionTile(
                label: "Notices",
                icon: Icons.notifications_none_rounded,
                color: const Color(0xFFD4A017), 
                badgeCount: _announcements.length,
                onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCompanyContent(BuildContext context, StudentModel student) {
    if (student.targetCompany.isEmpty && DummyData.students.first.targetCompany.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F3050), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF202C40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_boat_rounded, color: Color(0xFFD05454), size: 28), // Matches Maersk reddish
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Target company", style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B), fontSize: 10)),
                  const SizedBox(height: 2),
                  Text("Maersk Line", style: AppTextStyles.headingMedium.copyWith(color: const Color(0xFFD4A017), fontSize: 16)),
                  const SizedBox(height: 2),
                  Text("Company-specific prep ready", style: AppTextStyles.caption.copyWith(color: _textMuted)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.goNamed(AppRoutes.studentTestsName),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2A3D63), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text("Practice", style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTestsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DarkSectionHeader(
            title: "Upcoming Tests", 
            icon: Icons.access_time_rounded, 
            iconColor: const Color(0xFF5C8DF6),
            actionLabel: "All Tests",
            onAction: () => context.goNamed(AppRoutes.studentTestsName),
          ),
          const SizedBox(height: 16),
          if (_upcomingTests.isEmpty)
             Text("No upcoming tests scheduled", style: AppTextStyles.bodyMedium.copyWith(color: _textMuted))
          else
            Column(
              children: _upcomingTests.take(2).map((t) => _DarkUpcomingTestTile(
                test: t, 
                onTap: () => context.pushNamed(AppRoutes.testAttemptName, pathParameters: {'testId': t.id}),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DarkSectionHeader(
            title: "Announcements", 
            icon: Icons.notifications_active_rounded, 
            iconColor: const Color(0xFFD4A017),
            actionLabel: "View All",
            onAction: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
          ),
          const SizedBox(height: 16),
          Column(
            children: _announcements.take(2).map((a) => _DarkAnnouncementTile(
              announcement: a,
              onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// RE-USABLE LOCAL DARK WIDGETS
// ---------------------------------------------------------

class _DarkDashboardHeader extends StatelessWidget {
  final StudentModel student;
  final int announcementCount;

  const _DarkDashboardHeader({required this.student, required this.announcementCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back", style: AppTextStyles.bodyMedium.copyWith(color: _textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text("Howdy, ${student.name.split(' ')[0]}! 👋", style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 24)),
                  ],
                ),
              ),
              Row(
                children: [
                   _ActionButton(
                     icon: Icons.notifications_none_rounded, 
                     badgeCount: announcementCount,
                     onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
                   ),
                   const SizedBox(width: 12),
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DarkBadge(label: "12th Science", color: const Color(0xFF916BDB), isOutlined: true),
              _DarkBadge(label: student.branch, color: const Color(0xFF64748B), icon: Icons.location_on, isOutlined: true),
              _DarkBadge(label: student.batchName, color: const Color(0xFF64748B), isOutlined: true),
            ],
          ),
          const SizedBox(height: 16),
          Text("Wednesday, 8 April 2026", style: AppTextStyles.caption.copyWith(color: _textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _ActionButton({required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF162133), // Slightly lighter circle
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderDark, width: 0.5),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFD4A017), shape: BoxShape.circle),
                child: const SizedBox(width: 6, height: 6),
              ),
            ),
        ],
      ),
    );
  }
}

class _DarkBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isOutlined;

  const _DarkBadge({required this.label, required this.color, this.icon, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isOutlined ? 0.3 : 0.8), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DarkStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String statusLabel;
  final Color statusColor;

  const _DarkStatCard({
    required this.label, required this.value, required this.icon, 
    required this.color, required this.statusLabel, required this.statusColor
  });

  @override
  Widget build(BuildContext context) {
     return Container(
       decoration: BoxDecoration(
         color: _cardDark,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: _borderDark, width: 0.8),
       ),
       child: Stack(
         alignment: Alignment.topCenter,
         children: [
            Container(height: 3, width: 40, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
              child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
                  const SizedBox(height: 10),
                  Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
               ]
             ),
            ),
         ],
       )
     );
  }
}

class _DarkQuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  const _DarkQuickActionTile({required this.label, required this.icon, required this.color, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Stack(
           clipBehavior: Clip.none,
           children: [
             Container(
               height: 60,
               width: 60,
               decoration: BoxDecoration(
                 color: _cardDark,
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: _borderDark, width: 0.8),
               ),
               child: Center(
                 child: Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                   ),
                   child: Icon(icon, color: color, size: 22) 
                 )
               )
             ),
             if (badgeCount > 0)
               Positioned(
                 top: -6,
                 right: -6,
                 child: Container(
                   padding: const EdgeInsets.all(5),
                   decoration: const BoxDecoration(color: Color(0xFFD05454), shape: BoxShape.circle), 
                   child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, height: 1.0)),
                 ),
               ),
           ],
         ),
         const SizedBox(height: 10),
         Text(label, style: const TextStyle(color: _textMuted, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)
       ]
     ),
    );
  }
}

class _DarkSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback onAction;

  const _DarkSectionHeader({required this.title, required this.icon, required this.iconColor, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontSize: 16)),
          ],
        ),
        OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _borderDark, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(0, 36),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(actionLabel, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class _DarkUpcomingTestTile extends StatelessWidget {
  final TestModel test;
  final VoidCallback onTap;

  const _DarkUpcomingTestTile({required this.test, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = test.scheduledDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    String daysLabel;
    bool isUrgent = difference <= 1;
    if (difference == 0) daysLabel = "Today";
    else if (difference == 1) daysLabel = "Tomorrow";
    else daysLabel = "In $difference days";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderDark, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF916BDB).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit_document, color: Color(0xFF916BDB), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(test.title, style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("${test.durationMinutes} min • ${test.questions.length} questions • ${test.type}", style: AppTextStyles.caption.copyWith(color: _textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent ? const Color(0xFFD4A017).withOpacity(0.05) : _borderDark.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isUrgent ? const Color(0xFFD4A017).withOpacity(0.3) : _borderDark, width: 1.5),
              ),
              child: Text(daysLabel, style: AppTextStyles.labelSmall.copyWith(color: isUrgent ? const Color(0xFFD4A017) : _textMuted, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkAnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onTap;

  const _DarkAnnouncementTile({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHigh = announcement.priority.toLowerCase() == 'high';
    final isMedium = announcement.priority.toLowerCase() == 'medium';
    final color = isHigh ? const Color(0xFFD05454) : (isMedium ? const Color(0xFFD4A017) : const Color(0xFF20B2AA));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderDark, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(announcement.title, style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 14))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(announcement.priority, style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(announcement.description, style: AppTextStyles.bodySmall.copyWith(color: _textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text("${announcement.daysAgo} days ago • ${announcement.branch ?? 'All branches'}", style: AppTextStyles.caption.copyWith(color: const Color(0xFF64748B), fontSize: 11)),
                        ],
                      ),
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
