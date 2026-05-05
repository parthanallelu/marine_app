import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class ProfessorSubmissionsScreen extends StatefulWidget {
  const ProfessorSubmissionsScreen({super.key});

  @override
  State<ProfessorSubmissionsScreen> createState() =>
      _ProfessorSubmissionsScreenState();
}

class _ProfessorSubmissionsScreenState
    extends State<ProfessorSubmissionsScreen> {
  final _marksController = TextEditingController();
  final _feedbackController = TextEditingController();
  List<TestResult> _submissions = [];
  Map<String, TestModel> _testsById = {};
  Map<String, StudentModel> _studentsById = {};
  String _searchQuery = '';
  bool _pendingOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubmissions());
  }

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _loadSubmissions() {
    final professor =
        context.read<AuthProvider>().currentUser as ProfessorModel?;
    if (professor == null) return;

    final tests = DummyData.tests
        .where((test) => test.createdByProfessorId == professor.id)
        .toList();
    final testIds = tests.map((test) => test.id).toSet();

    setState(() {
      _testsById = {for (final test in tests) test.id: test};
      _studentsById = {
        for (final student in DummyData.students) student.id: student,
      };
      _submissions =
          DummyData.testResults
              .where((result) => testIds.contains(result.testId))
              .toList()
            ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    });
  }

  List<TestResult> get _filteredSubmissions {
    final query = _searchQuery.trim().toLowerCase();
    return _submissions.where((result) {
      final student = _studentsById[result.studentId];
      final test = _testsById[result.testId];
      final matchesPending = !_pendingOnly || result.feedback.isEmpty;
      final matchesSearch =
          query.isEmpty ||
          result.testTitle.toLowerCase().contains(query) ||
          (student?.name.toLowerCase().contains(query) ?? false) ||
          (student?.rollNumber.toLowerCase().contains(query) ?? false) ||
          (test?.subject.toLowerCase().contains(query) ?? false);
      return matchesPending && matchesSearch;
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

    final pendingCount = _submissions.where((r) => r.feedback.isEmpty).length;

    return AppPageShell(
      title: "Submissions",
      subtitle: "Review and grade",
      headerWidgets: [
        CustomTextField(
          hintText: "Search student, test, roll no...",
          prefixIcon: Icons.search_rounded,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _SummaryPill(
                label: "Total",
                value: _submissions.length.toString(),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SummaryPill(
                label: "Pending",
                value: pendingCount.toString(),
                color: AppColors.gold,
              ),
            ),
          ],
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
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _pendingOnly,
              onChanged: (value) => setState(() => _pendingOnly = value),
              title: Text(
                "Pending review only",
                style: AppTextStyles.labelLarge,
              ),
              activeThumbColor: AppColors.gold,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_filteredSubmissions.isEmpty)
              const EmptyState(
                icon: Icons.fact_check_outlined,
                title: "No Submissions",
                subtitle:
                    "Student attempts will appear here after tests are submitted.",
              )
            else
              ..._filteredSubmissions.map((result) {
                return _SubmissionCard(
                  result: result,
                  test: _testsById[result.testId],
                  student: _studentsById[result.studentId],
                  onGrade: () => _showGradeSheet(result),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showGradeSheet(TestResult result) {
    final test = _testsById[result.testId];
    _marksController.text = result.score.toStringAsFixed(0);
    _feedbackController.text = result.feedback;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Grade Submission", style: AppTextStyles.headingMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  result.testTitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                CustomTextField(
                  label: "Marks",
                  hintText: "0 - ${result.totalMarks.toInt()}",
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.score_outlined,
                  validator: (value) {
                    final marks = double.tryParse(value ?? '');
                    if (marks == null) return "Enter valid marks";
                    if (marks < 0 || marks > result.totalMarks) {
                      return "Marks must be within total marks";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
                  label: "Feedback",
                  hintText: "Add remarks for the student",
                  controller: _feedbackController,
                  prefixIcon: Icons.rate_review_outlined,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                CustomButton(
                  label: "Save Grade",
                  width: double.infinity,
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final marks = double.parse(_marksController.text);
                    final updated = result.copyWith(
                      score: marks,
                      isPassed:
                          marks >=
                          (test?.passingMarks ?? result.totalMarks * 0.4),
                      feedback: _feedbackController.text.trim(),
                    );
                    final index = DummyData.testResults.indexWhere(
                      (item) => item.id == result.id,
                    );
                    if (index != -1) {
                      DummyData.testResults[index] = updated;
                    }
                    setState(() {
                      final localIndex = _submissions.indexWhere(
                        (item) => item.id == result.id,
                      );
                      if (localIndex != -1) {
                        _submissions[localIndex] = updated;
                      }
                    });
                    Navigator.pop(context);
                    AppSnackBar.showSuccess(context, "Submission graded");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final TestResult result;
  final TestModel? test;
  final StudentModel? student;
  final VoidCallback onGrade;

  const _SubmissionCard({
    required this.result,
    required this.test,
    required this.student,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final pending = result.feedback.isEmpty;
    final statusColor = pending ? AppColors.warning : AppColors.success;
    final studentName = student?.name ?? "Unknown student";

    return DashboardCard(
      title: studentName,
      subtitle: student?.rollNumber,
      icon: pending ? Icons.pending_actions_rounded : Icons.verified_rounded,
      iconColor: statusColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      trailing: TextButton.icon(
        onPressed: onGrade,
        icon: Icon(
          pending ? Icons.edit_note_rounded : Icons.rate_review_outlined,
          size: 18,
        ),
        label: Text(pending ? "Grade" : "Update"),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.testTitle, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaChip(
                icon: Icons.subject_rounded,
                label: test?.subject ?? "Assessment",
              ),
              _MetaChip(
                icon: Icons.score_outlined,
                label:
                    "${result.score.toStringAsFixed(0)}/${result.totalMarks.toStringAsFixed(0)}",
              ),
              _MetaChip(
                icon: Icons.timer_outlined,
                label: "${result.timeTakenSeconds ~/ 60}m",
              ),
            ],
          ),
          if (result.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              result.feedback,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
