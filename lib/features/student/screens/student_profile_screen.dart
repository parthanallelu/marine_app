import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isLoading = false;
  late AttendanceSummary _attendance;
  late double _avgScore;
  late FeeRecord _feeRecord;

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
  }

  void _loadProfileStats() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // final profileData = await studentRepository.getStudentProfileStats(studentId);
    
    final student = context.read<AuthProvider>().currentUser as StudentModel;

    final records = DummyData.generateAttendanceForStudent(student.id, student.name, student.batchId);
    _attendance = DummyData.attendanceSummaryFor(student.id, records);
    
    final results = DummyData.testResults.where((r) => r.studentId == student.id).toList();
    _avgScore = results.isEmpty
        ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length;
    
    _feeRecord = DummyData.feeRecords.firstWhere(
      (f) => f.studentId == student.id,
      orElse: () => DummyData.feeRecords.first,
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed('role_selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final student = authProvider.currentUser as StudentModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Profile header
          SliverToBoxAdapter(
            child: Container(
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
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.gold.withAlpha((0.25 * 255).round()),
                        child: Text(
                          student.name[0],
                          style: AppTextStyles.headingLarge.copyWith(color: AppColors.gold, fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        student.name,
                        style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Roll No: ${student.rollNumber}",
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CourseBadge(courseType: student.courseType),
                          const SizedBox(width: 8),
                          BranchBadge(branch: student.branch),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SLIVER 2 — Floating stats card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.cardRadius,
                    boxShadow: AppShadows.elevated,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _ProfileStat(
                          label: "Attendance",
                          value: _attendance.percentageLabel,
                          icon: Icons.calendar_today,
                          color: AppColors.success,
                        ),
                        const VerticalDivider(width: 32),
                        _ProfileStat(
                          label: "Test Avg",
                          value: "${_avgScore.toStringAsFixed(0)}%",
                          icon: Icons.quiz_rounded,
                          color: AppColors.oceanBlue,
                        ),
                        const VerticalDivider(width: 32),
                        _ProfileStat(
                          label: "Fees Paid",
                          value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
                          icon: Icons.receipt_rounded,
                          color: _feeRecord.pendingAmount > 0 ? AppColors.warning : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SLIVER 3 — Personal Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: DashboardCard(
                title: "Personal Information",
                child: Column(
                  children: [
                    InfoRow(icon: Icons.email_outlined, label: "Email", value: student.email),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.phone_outlined, label: "Phone", value: student.phone),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.family_restroom_outlined, label: "Parent Phone", value: student.parentPhone),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.history_outlined, label: "Joined Date", value: student.createdAt.toString().split(' ')[0]),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.group_outlined, label: "Batch", value: student.batchName),
                    if (student.targetCompany.isNotEmpty) ...[
                      const Divider(height: 1),
                      InfoRow(
                        icon: Icons.stars_rounded, 
                        label: "Target", 
                        value: student.targetCompany,
                        iconColor: AppColors.gold,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // SLIVER 4 — Quick Links
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: DashboardCard(
                title: "Quick Links",
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.gold.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.gold, size: 20),
                      ),
                      title: Text("Fee Details", style: AppTextStyles.labelLarge),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      // NAVIGATION SAFETY: Using goNamed
                      onTap: () => context.pushNamed('student_fees'),
                    ),
                    const Divider(height: 1, indent: 52),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.warning.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.campaign_rounded, color: AppColors.warning, size: 20),
                      ),
                      title: Text("Announcements", style: AppTextStyles.labelLarge),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      // NAVIGATION SAFETY: Using goNamed
                      onTap: () => context.pushNamed('student_announcements'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SLIVER 5 — Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: CustomButton(
                label: "Logout",
                isOutlined: true,
                color: AppColors.error,
                icon: Icons.logout_rounded,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthProvider>().logout();
                          },
                          child: const Text("LOGOUT", style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: color, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// StudentFeesScreen
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StudentFeesScreen extends StatefulWidget {
  const StudentFeesScreen({super.key});

  @override
  State<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends State<StudentFeesScreen> {
  bool _isLoading = false;
  late FeeRecord _feeRecord;

  @override
  void initState() {
    super.initState();
    _loadFeeData();
  }

  void _loadFeeData() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // _feeRecord = await studentRepository.getStudentFees(studentId);
    
    final student = context.read<AuthProvider>().currentUser as StudentModel;
    _feeRecord = DummyData.feeRecords.firstWhere(
      (f) => f.studentId == student.id,
      orElse: () => DummyData.feeRecords.first,
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed('role_selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Fee Details", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Summary card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "Fee Summary",
                        style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FeeSummaryItem(label: "Total Fees", value: "₹${_feeRecord.totalFees.toInt()}"),
                      _FeeSummaryItem(label: "Paid Amount", value: "₹${_feeRecord.paidAmount.toInt()}"),
                      _FeeSummaryItem(
                        label: "Pending", 
                        value: "₹${_feeRecord.pendingAmount.toInt()}",
                        valueColor: _feeRecord.pendingAmount > 0 ? Colors.orange : AppColors.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _feeRecord.paidAmount / _feeRecord.totalFees,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${_feeRecord.percentagePaid.toStringAsFixed(1)}% paid",
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 2 — Installments heading
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(title: "Payment History"),
            ),
          ),

          // SLIVER 3 — LIST PERFORMANCE: Using SliverList.builder
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final installment = _feeRecord.installments[index];
                  final isPaid = installment.status == FeeStatus.paid;
                  final color = isPaid ? AppColors.success : AppColors.warning;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(installment.title, style: AppTextStyles.labelLarge),
                              Text(
                                "Due: ${installment.dueDate.toString().split(' ')[0]}",
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              if (isPaid && installment.paidDate != null)
                                Text(
                                  "Paid: ${installment.paidDate!.toString().split(' ')[0]}",
                                  style: AppTextStyles.caption.copyWith(color: AppColors.success),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${installment.amount.toInt()}",
                              style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.1 * 255).round()),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                installment.status.name.toUpperCase(),
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: _feeRecord.installments.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _FeeSummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _FeeSummaryItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingSmall.copyWith(color: valueColor ?? Colors.white, fontSize: 18),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
