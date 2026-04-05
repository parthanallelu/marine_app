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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentUser as StudentModel;
    final now = DateTime.now();

    final upcomingTests = DummyData.tests.where((t) => t.scheduledDate.isAfter(now)).toList();
    final pastTests = DummyData.tests.where((t) => t.scheduledDate.isBefore(now)).toList();
    final results = DummyData.testResults.where((r) => r.studentId == student.id).toList();

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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          "Mock Tests",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
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
                      Tab(text: "Upcoming (${upcomingTests.length})"),
                      Tab(text: "Past (${pastTests.length})"),
                      Tab(text: "Results (${results.length})"),
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
                _TestList(tests: upcomingTests, isUpcoming: true),
                _TestList(tests: pastTests, isUpcoming: false),
                _ResultList(results: results),
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
      return const EmptyState(
        icon: Icons.quiz_rounded,
        title: "No Tests Found",
        subtitle: "There are no tests available at the moment.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
      margin: const EdgeInsets.only(bottom: 16),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha((0.10 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          test.companyTarget!,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(test.title, style: AppTextStyles.headingSmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MetaChip(icon: Icons.help_outline, label: "${test.questions.length} Qns"),
                    const SizedBox(width: 8),
                    _MetaChip(icon: Icons.timer_outlined, label: "${test.durationMinutes}m"),
                    const SizedBox(width: 8),
                    _MetaChip(icon: Icons.stars_rounded, label: "${test.totalMarks.toInt()} Marks"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.event_note, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      test.scheduledDate.toString().split(' ')[0],
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (isUpcoming)
                      CustomButton(
                        label: "Start Test",
                        height: 40,
                        color: typeColor,
                        onPressed: () => context.push('${AppRoutes.studentTests}/attempt/${test.id}'),
                      ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(20),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasPassed ? "PASSED" : "FAILED",
              style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
