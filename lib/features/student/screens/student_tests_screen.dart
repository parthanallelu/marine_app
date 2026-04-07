import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class StudentTestsScreen extends StatefulWidget {
  const StudentTestsScreen({super.key});

  @override
  State<StudentTestsScreen> createState() => _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late List<TestModel> _upcomingTests;
  late List<TestModel> _pastTests;
  late List<TestResult> _results;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTestData();
  }

  void _loadTestData() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // final testData = await studentRepository.getStudentTests(studentId);
    
    final student = context.read<AuthProvider>().currentUser as StudentModel;
    final now = DateTime.now().toUtc();

    _upcomingTests = DummyData.tests.where((t) => t.scheduledDate.isAfter(now)).toList();
    _pastTests = DummyData.tests.where((t) => t.scheduledDate.isBefore(now)).toList();
    _results = DummyData.testResults.where((r) => r.studentId == student.id).toList();

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      children: [
                        Text(
                          "Mock Tests",
                          style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.gold,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: "Upcoming (${_upcomingTests.length})"),
                      Tab(text: "Past (${_pastTests.length})"),
                      Tab(text: "Results (${_results.length})"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TestList(tests: _upcomingTests, isUpcoming: true),
                _TestList(tests: _pastTests, isUpcoming: false),
                _ResultList(results: _results),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestList extends StatelessWidget {
  final List<TestModel> tests;
  final bool isUpcoming;
  const _TestList({required this.tests, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return EmptyState(
        icon: Icons.quiz_rounded,
        title: "No Tests Found",
        subtitle: isUpcoming ? "There are no upcoming tests scheduled." : "You have no past tests.",
      );
    }

    // LIST PERFORMANCE: Using ListView.builder for dynamic lists
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _TestCard(test: test, isUpcoming: isUpcoming);
      },
    );

  }
}

class _TestCard extends StatelessWidget {
  final TestModel test;
  final bool isUpcoming;
  const _TestCard({required this.test, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    switch (test.type) {
      case 'Mock Test':
      case 'IMU-CET Mock':
        typeColor = AppColors.navyBlueBase;
        break;
      case 'Company Specific':
        typeColor = AppColors.gold;
        break;
      case 'Psychometric':
      case 'Assessment':
        typeColor = AppColors.course12th;
        break;
      case 'English':
        typeColor = AppColors.oceanBlue;
        break;
      case 'Unit Test':
      case 'Practice Test':
        typeColor = AppColors.success;
        break;
      default:
        typeColor = AppColors.navyBlueBase;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha((0.10 * 255).round()),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: typeColor.withAlpha((0.30 * 255).round())),
                      ),
                      child: Text(
                        test.type,
                        style: AppTextStyles.labelSmall.copyWith(color: typeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (test.companyTarget != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navyBlueSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          test.companyTarget!,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(test.title, style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    _MetaChip(icon: Icons.help_outline_rounded, label: "${test.questions.length} Qns"),
                    const SizedBox(width: AppSpacing.sm),
                    _MetaChip(icon: Icons.timer_outlined, label: "${test.durationMinutes}m"),
                    const SizedBox(width: AppSpacing.sm),
                    _MetaChip(icon: Icons.stars_rounded, label: "${test.totalMarks.toInt()} Marks"),

                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textHint),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          test.scheduledDate.toString().split(' ')[0],
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isUpcoming)
                      CustomButton(
                        label: "Start Assessment",
                        height: 44,
                        width: 140,
                        color: typeColor,
                        onPressed: () => context.pushNamed(AppRoutes.testAttemptName, pathParameters: {'testId': test.id}),
                      ),

               ],
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  final List<TestResult> results;
  const _ResultList({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: "No Results Yet",
        subtitle: "Complete a test to see your grade here.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _ResultCard(result: result);
      },
    );

  }
}

class _ResultCard extends StatelessWidget {
  final TestResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final hasPassed = result.isPassed;
    final color = hasPassed ? AppColors.success : AppColors.error;
    final bgColor = hasPassed ? AppColors.successSurface : AppColors.errorSurface;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.testResultName, pathParameters: {'resultId': result.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.card,
        ),

        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                result.grade,
                style: AppTextStyles.headingMedium.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.testTitle, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    "Score: ${result.score.toInt()}/${result.totalMarks.toInt()} (${result.percentage.toStringAsFixed(1)}%)",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    result.submittedAt.toString().split(' ')[0],
                    style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),

              child: Text(
                hasPassed ? "PASSED" : "FAILED",
                style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
