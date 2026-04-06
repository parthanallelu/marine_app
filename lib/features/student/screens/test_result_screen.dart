import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class TestResultScreen extends StatelessWidget {
  final String resultId;
  final TestResult? result;

  const TestResultScreen({
    super.key,
    required this.resultId,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    // Access Control Safety
    final auth = context.watch<AuthProvider>();
    if (!auth.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // SAFE CASTING: If result was not passed via extra, we try to fetch it or show error
    // TODO: Replace with Firestore fetch:
    // final testResult = result ?? await testRepository.getResultById(resultId);
    final testResult = result ?? DummyData.testResults.firstWhere(
      (r) => r.id == resultId,
      orElse: () => DummyData.testResults.first, // Fallback for dummy demo
    );

    final hasPassed = testResult.isPassed;
    final primaryColor = hasPassed ? AppColors.testPassed : AppColors.testFailed;
    final accentColor = hasPassed ? AppColors.success : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Result header
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.15 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          testResult.grade,
                          style: AppTextStyles.gradeLarge,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        hasPassed ? "Congratulations!" : "Keep Trying!",
                        style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        testResult.testTitle,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha((0.8 * 255).round())),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xxl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ResultStat(
                            label: "Score",
                            value: "${testResult.score.toInt()} / ${testResult.totalMarks.toInt()}",
                          ),
                          _ResultStat(
                            label: "Percentage",
                            value: "${testResult.percentage.toStringAsFixed(1)}%",
                          ),
                          _ResultStat(
                            label: "Time taken",
                            value: "${testResult.timeTakenSeconds ~/ 60}m ${testResult.timeTakenSeconds % 60}s",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SLIVER 2 — Actions
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  CustomButton(
                    label: "Back to Tests",
                    width: double.infinity,
                    icon: Icons.quiz_rounded,
                    // NAVIGATION SAFETY: Using goNamed
                    onPressed: () => context.goNamed(AppRoutes.studentTestsName),
                  ),
                  SizedBox(height: AppSpacing.md),
                  CustomButton(
                    label: "Dashboard",
                    width: double.infinity,
                    isOutlined: true,
                    // NAVIGATION SAFETY: Using goNamed
                    onPressed: () => context.goNamed(AppRoutes.studentHomeName),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.7 * 255).round())),
        ),
      ],
    );
  }
}
