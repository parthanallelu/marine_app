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
  late Map<String, int> _batchStudentCounts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
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

      _assignedBatches = DummyData.batches
          .where((b) => b.professorId == professor.id && b.isActive)
          .toList();

      _totalStudents = 0;
      _batchStudentCounts = {};

      for (var batch in _assignedBatches) {
        final count = DummyData.students
            .where((s) => s.batchId == batch.id)
            .length;
        _batchStudentCounts[batch.id] = count;
        _totalStudents += count;
      }

      final today = DateFormat('EEEE').format(DateTime.now()); // e.g., "Monday"
      _todaysClasses = _assignedBatches
          .where((b) => b.days.contains(today))
          .toList();
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Error loading professor dashboard: $e");
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
    final professor = authProvider.currentUser as ProfessorModel?;

    if (!authProvider.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    if (professor == null || _isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: NavyHeader(
              title: 'Welcome Back,',
              subtitle: professor.name,
              logoPath: AppConstants.logo,
            ),
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
      childAspectRatio: 0.85,
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
          childAspectRatio: 0.9,
          children: [
            QuickActionTile(
              label: 'Attendance',
              icon: Icons.how_to_reg_rounded,
              color: AppColors.navyBlueBase,
              onTap: () => context.pushNamed(AppRoutes.professorAttendanceName),
            ),
            QuickActionTile(
              label: 'Upload',
              icon: Icons.upload_file_rounded,
              color: AppColors.oceanBlue,
              onTap: () => context.pushNamed(AppRoutes.professorMaterialsName),
            ),
            QuickActionTile(
              label: 'Tests',
              icon: Icons.assignment_rounded,
              color: AppColors.purple,
              onTap: () => context.pushNamed(AppRoutes.professorTestsName),
            ),
            QuickActionTile(
              label: 'Submissions',
              icon: Icons.fact_check_rounded,
              color: AppColors.success,
              onTap: () =>
                  context.pushNamed(AppRoutes.professorSubmissionsName),
            ),
            QuickActionTile(
              label: 'Students',
              icon: Icons.person_search_rounded,
              color: AppColors.gold,
              onTap: () => context.pushNamed(AppRoutes.professorStudentsName),
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
        SectionHeader(
          title: "Today's Classes",
          actionLabel: DateFormat('EEEE, MMM d').format(DateTime.now()),
        ),
        const SizedBox(height: AppSpacing.md),

        if (_todaysClasses.isEmpty)
          const EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No Classes Today',
            subtitle: "You don't have any classes scheduled for today.",
          )
        else
          ..._todaysClasses.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BatchCard(
                batch: batch,
                studentCount: _batchStudentCounts[batch.id] ?? 0,
                onManage: () =>
                    context.pushNamed(AppRoutes.professorAttendanceName),
              ),
            ),
          ),
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
                  batch: batch,
                  studentCount: _batchStudentCounts[batch.id] ?? 0,
                  onManage: () =>
                      context.pushNamed(AppRoutes.professorAttendanceName),
                ),
              );
            },
          ),
      ],
    );
  }
}
