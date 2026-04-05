import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  late List<BatchModel> _assignedBatches;
  late List<BatchModel> _todaysClasses;
  late int _totalStudents;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _computeDashboardData();
  }

  void _computeDashboardData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final professor = authProvider.currentUser as ProfessorModel?;

    if (professor == null) {
      _assignedBatches = [];
      _todaysClasses = [];
      _totalStudents = 0;
      return;
    }

    // Filter batches assigned to this professor
    _assignedBatches = DummyData.batches
        .where((b) => b.professorId == professor.id && b.isActive)
        .toList();

    // Calculate total students across all assigned batches
    _totalStudents = _assignedBatches.fold(0, (sum, b) => sum + b.studentIds.length);

    // Filter today's classes
    final today = DateFormat('EEEE').format(DateTime.now()); // e.g., "Monday"
    _todaysClasses = _assignedBatches
        .where((b) => b.days.contains(today))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final professor = context.watch<AuthProvider>().currentUser as ProfessorModel?;

    if (professor == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          NavyHeader(
            title: 'Welcome Back,',
            subtitle: professor.name,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(professor),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildTodaySchedule(context, professor),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildMyBatches(professor),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProfessorModel professor) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        StatCard(
          label: 'Batches',
          value: _assignedBatches.length.toString(),
          icon: Icons.groups_rounded,
          color: AppColors.navyBlueBase,
        ),
        StatCard(
          label: 'Students',
          value: _totalStudents.toString(),
          icon: Icons.person_rounded,
          color: AppColors.oceanBlue,
        ),
        StatCard(
          label: 'Subjects',
          value: professor.subjects.length.toString(),
          icon: Icons.book_rounded,
          color: AppColors.gold,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            QuickActionTile(
              label: 'Attendance',
              icon: Icons.how_to_reg_rounded,
              color: AppColors.navyBlueBase,
              onTap: () => context.push(AppRoutes.markAttendance),
            ),
            QuickActionTile(
              label: 'Upload',
              icon: Icons.upload_file_rounded,
              color: AppColors.oceanBlue,
              onTap: () => context.goNamed(AppRoutes.professorMaterials),
            ),
            QuickActionTile(
              label: 'Students',
              icon: Icons.person_search_rounded,
              color: AppColors.gold,
              onTap: () => _showStudentsBottomSheet(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(BuildContext context, ProfessorModel professor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: "Today's Classes"),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_todaysClasses.isEmpty)
          const EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No Classes Today',
            subtitle: "You don't have any classes scheduled for today.",
          )
        else
          ..._todaysClasses.map((batch) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: DashboardCard(
                  title: batch.name,
                  subtitle: batch.timing,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.class_rounded, color: AppColors.navyBlueBase),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CourseBadge(courseType: batch.courseType),
                      Text(
                        '${batch.studentIds.length} Students',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  onAction: () => context.push(AppRoutes.markAttendance),
                  actionLabel: 'Mark Attendance',
                ),
              )),
      ],
    );
  }

  Widget _buildMyBatches(ProfessorModel professor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'My Batches'),
        const SizedBox(height: AppSpacing.md),
        if (_assignedBatches.isEmpty)
          const EmptyState(
            icon: Icons.group_off_outlined,
            title: 'No Batches',
            subtitle: 'You are not assigned to any batches yet.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _assignedBatches.length,
            itemBuilder: (context, index) {
              final batch = _assignedBatches[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.cardRadius,
                  boxShadow: AppShadows.subtle,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.navyBlueBase),
                  ),
                  title: Text(batch.name, style: AppTextStyles.labelLarge),
                  subtitle: Text(
                    '${batch.courseType} • ${batch.branch}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {
                    // Future: Batch details
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  void _showStudentsBottomSheet() {
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel;
    final students = DummyData.students.where((s) => prof.batchIds.contains(s.batchId)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Assigned Students', style: AppTextStyles.headingSmall),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.navyBlueSurface,
                      child: Text(student.name[0], style: const TextStyle(color: AppColors.navyBlueBase)),
                    ),
                    title: Text(student.name, style: AppTextStyles.bodyLarge),
                    subtitle: Text('${student.batchName} | ${student.rollNumber}', style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.phone_outlined, size: 20, color: AppColors.oceanBlue),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
