import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class ProfessorStudentsScreen extends StatefulWidget {
  const ProfessorStudentsScreen({super.key});

  @override
  State<ProfessorStudentsScreen> createState() =>
      _ProfessorStudentsScreenState();
}

class _ProfessorStudentsScreenState extends State<ProfessorStudentsScreen> {
  List<StudentModel> _students = [];
  List<BatchModel> _batches = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStudents());
  }

  void _loadStudents() {
    final professor =
        context.read<AuthProvider>().currentUser as ProfessorModel?;
    if (professor == null) return;

    setState(() {
      _batches = DummyData.batches
          .where((batch) => batch.professorId == professor.id)
          .toList();
      final batchIds = _batches.map((batch) => batch.id).toSet();
      _students =
          DummyData.students
              .where((student) => batchIds.contains(student.batchId))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  List<StudentModel> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _students;
    return _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query) ||
          student.batchName.toLowerCase().contains(query) ||
          student.branch.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppPageShell(
      title: "My Students",
      subtitle: "${_students.length} assigned learners",
      headerWidgets: [
        CustomTextField(
          hintText: "Search students, roll no, batch...",
          prefixIcon: Icons.search_rounded,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BatchSummary(batches: _batches),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: "Assigned Students",
              actionLabel: "${_filteredStudents.length} found",
            ),
            const SizedBox(height: AppSpacing.md),
            if (_filteredStudents.isEmpty)
              const EmptyState(
                icon: Icons.person_off_outlined,
                title: "No Students Found",
                subtitle: "Assigned students will appear here.",
              )
            else
              ..._filteredStudents.map(
                (student) => StudentCard(
                  student: student,
                  onEdit: () => _showStudentDetails(student),
                  onDelete: () {},
                  trailing: IconButton(
                    tooltip: "View details",
                    onPressed: () => _showStudentDetails(student),
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.oceanBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(StudentModel student) {
    final attendance = DummyData.attendanceSummaryFor(
      student.id,
      DummyData.generateAttendanceForStudent(
        student.id,
        student.name,
        student.batchId,
      ),
    );
    final results = DummyData.testResults
        .where((result) => result.studentId == student.id)
        .toList();
    final avg = results.isEmpty
        ? 0.0
        : results.map((result) => result.percentage).reduce((a, b) => a + b) /
              results.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.name, style: AppTextStyles.headingMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "${student.rollNumber} • ${student.batchName}",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            InfoRow(
              icon: Icons.phone_outlined,
              label: "Phone",
              value: student.phone,
            ),
            InfoRow(
              icon: Icons.location_on_outlined,
              label: "Branch",
              value: student.branch,
            ),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              label: "Attendance",
              value: attendance.percentageLabel,
            ),
            InfoRow(
              icon: Icons.assignment_outlined,
              label: "Test Avg",
              value: "${avg.toStringAsFixed(1)}%",
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _BatchSummary extends StatelessWidget {
  final List<BatchModel> batches;

  const _BatchSummary({required this.batches});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: "Assigned Batches",
      icon: Icons.groups_rounded,
      iconColor: AppColors.gold,
      child: batches.isEmpty
          ? Text(
              "No active batches assigned.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: batches.map((batch) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(batch.name, style: AppTextStyles.labelSmall),
                );
              }).toList(),
            ),
    );
  }
}
