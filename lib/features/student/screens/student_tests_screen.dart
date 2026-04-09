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
        return TestCard(
          test: test,
          isUpcoming: isUpcoming,
          onStart: isUpcoming 
            ? () => context.pushNamed(AppRoutes.testAttemptName, pathParameters: {'testId': test.id})
            : null,
          onTap: () {
            // Future: Show test info
          },
        );
      },
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
        return ResultCard(
          result: result,
          onTap: () => context.pushNamed(AppRoutes.testResultName, pathParameters: {'resultId': result.id}),
        );
      },
    );
  }
}
