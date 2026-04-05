import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../core/common_widgets/batch_card.dart';
import '../../../core/common_widgets/student_tile.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Simulate async network delay for future-readiness
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final professor = authProvider.currentUser as ProfessorModel?;

    if (professor == null) {
      setState(() {
        _assignedBatches = [];
        _todaysClasses = [];
        _totalStudents = 0;
        _isLoading = false;
      });
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

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final professor = authProvider.currentUser as ProfessorModel?;

    // Role security check
    if (!authProvider.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.roleSelection);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (professor == null || _isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  _buildTodaySchedule(context),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildMyBatches(),
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
              onTap: () => context.push(AppRoutes.professorMaterials),
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

  Widget _buildTodaySchedule(BuildContext context) {
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
                child: BatchCard(
                  name: batch.name,
                  courseType: batch.courseType,
                  timing: batch.timing,
                  branch: batch.branch,
                  studentCount: batch.studentIds.length,
                  actionLabel: 'Mark Attendance',
                  onAction: () => context.push(AppRoutes.markAttendance),
                ),
              )),
      ],
    );
  }

  Widget _buildMyBatches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'My Batches'),
        const SizedBox(height: AppSpacing.md),
        if (_assignedBatches.isEmpty)
          const EmptyState(
            icon: Icons.class_outlined,
            title: 'No Batches Assigned',
            subtitle: 'Contact admin if you believe this is an error.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _assignedBatches.length,
            itemBuilder: (context, index) {
              final batch = _assignedBatches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BatchCard(
                  name: batch.name,
                  courseType: batch.courseType,
                  timing: batch.timing,
                  branch: batch.branch,
                  studentCount: batch.studentIds.length,
                  onTap: () {
                    // Future: Batch details screen
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
            const SizedBox(height: 20),
            if (students.isEmpty)
              const Expanded(
                child: EmptyState(
                  icon: Icons.person_off_rounded,
                  title: 'No Students Found',
                  subtitle: 'You are not connected to any students yet.',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return StudentTile(
                      name: student.name,
                      rollNumber: student.rollNumber,
                      batchName: student.batchName,
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
