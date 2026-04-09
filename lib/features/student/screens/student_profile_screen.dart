import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
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
        context.goNamed(AppRoutes.roleSelectionName);
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

    return AppPageShell(
      title: "My Profile",
      subtitle: "Student Center",
      showBackButton: false,
      headerWidgets: [
        Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
              child: Text(
                student.name[0],
                style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              student.name,
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              "Roll No: ${student.rollNumber}",
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CourseBadge(courseType: student.courseType),
                const SizedBox(width: AppSpacing.sm),
                BranchBadge(branch: student.branch),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Stats Row
            IntrinsicHeight(
              child: Row(
                children: [
                  _ProfileStat(
                    label: "Attendance",
                    value: _attendance.percentageLabel,
                    icon: Icons.calendar_today,
                    color: Colors.white,
                    isLight: true,
                  ),
                  const VerticalDivider(width: AppSpacing.xl, color: Colors.white24),
                  _ProfileStat(
                    label: "Test Avg",
                    value: "${_avgScore.toStringAsFixed(0)}%",
                    icon: Icons.quiz_rounded,
                    color: Colors.white,
                    isLight: true,
                  ),
                  const VerticalDivider(width: AppSpacing.xl, color: Colors.white24),
                  _ProfileStat(
                    label: "Fees Paid",
                    value: "${_feeRecord.percentagePaid.toStringAsFixed(0)}%",
                    icon: Icons.receipt_rounded,
                    color: Colors.white,
                    isLight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            DashboardCard(
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
            const SizedBox(height: AppSpacing.xxl),
            DashboardCard(
              title: "Quick Links",
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(color: AppColors.gold.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.gold, size: 20),
                    ),
                    title: Text("Fee Details", style: AppTextStyles.labelLarge),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.pushNamed(AppRoutes.studentFeesName),
                  ),
                  const Divider(height: 1, indent: 52),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(color: AppColors.warning.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: const Icon(Icons.campaign_rounded, color: AppColors.warning, size: 20),
                    ),
                    title: Text("Announcements", style: AppTextStyles.labelLarge),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.pushNamed(AppRoutes.studentAnnouncementsName),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            CustomButton(
              label: "Logout",
              isOutlined: true,
              color: AppColors.error,
              icon: Icons.logout_rounded,
              width: double.infinity,
              onPressed: () {
                GenericConfirmationDialog.show(
                  context,
                  title: "Logout",
                  content: "Are you sure you want to log out from your student account?",
                  confirmLabel: "Logout",
                  isDestructive: true,
                  onConfirm: () {
                    authProvider.logout();
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLight;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: isLight ? Colors.white : color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(
              color: isLight ? Colors.white : color, 
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isLight ? Colors.white70 : AppColors.textSecondary,
              fontSize: 10,
            ),
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
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppPageShell(
      title: "Fee Details",
      subtitle: "Payment Summary",
      showBackButton: true,
      headerWidgets: [
        Column(
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_rounded, color: AppColors.gold, size: 28),
                const SizedBox(width: AppSpacing.md),
                Text(
                  "Fee Summary",
                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FeeSummaryItem(label: "Total Fees", value: "₹${_feeRecord.totalFees.toInt()}"),
                _FeeSummaryItem(label: "Paid Amount", value: "₹${_feeRecord.paidAmount.toInt()}"),
                _FeeSummaryItem(
                  label: "Pending", 
                  value: "₹${_feeRecord.pendingAmount.toInt()}",
                  valueColor: _feeRecord.pendingAmount > 0 ? AppColors.warning : AppColors.gold,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: _feeRecord.paidAmount / _feeRecord.totalFees,
                minHeight: 8,
                backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${_feeRecord.percentagePaid.toStringAsFixed(1)}% paid",
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: "Payment History"),
            const SizedBox(height: AppSpacing.md),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feeRecord.installments.length,
              itemBuilder: (context, index) {
                return _InstallmentTile(installment: _feeRecord.installments[index]);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  final FeeInstallment installment;

  const _InstallmentTile({required this.installment});

  @override
  Widget build(BuildContext context) {
    final isPaid = installment.status == FeeStatus.paid;
    final color = isPaid ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
          const SizedBox(width: AppSpacing.md),
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
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  installment.status.toString().split('.').last.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10),
                ),
              ),
            ],
          ),
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
        SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
