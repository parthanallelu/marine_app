import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
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
        context.goNamed('role_selection');
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
    final primaryColor = hasPassed ? const Color(0xFF1B5E20) : const Color(0xFF7F0000);
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasPassed ? "Congratulations!" : "Keep Trying!",
                        style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testResult.testTitle,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha((0.8 * 255).round())),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  CustomButton(
                    label: "Back to Tests",
                    width: double.infinity,
                    icon: Icons.quiz_rounded,
                    // NAVIGATION SAFETY: Using goNamed
                    onPressed: () => context.goNamed('student_tests'),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: "Dashboard",
                    width: double.infinity,
                    isOutlined: true,
                    // NAVIGATION SAFETY: Using goNamed
                    onPressed: () => context.goNamed('student_home'),
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
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.7 * 255).round())),
        ),
      ],
    );
  }
}
