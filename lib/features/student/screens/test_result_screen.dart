import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';

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
    // If result was not passed via extra, we show an error (fallback)
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Result")),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: "Result Not Found",
          subtitle: "We couldn't retrieve the details of this test result.",
        ),
      );
    }

    final hasPassed = result!.isPassed;
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
                          result!.grade,
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
                        result!.testTitle,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha((0.8 * 255).round())),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ResultStat(
                            label: "Score",
                            value: "${result!.score.toInt()} / ${result!.totalMarks.toInt()}",
                          ),
                          _ResultStat(
                            label: "Percentage",
                            value: "${result!.percentage.toStringAsFixed(1)}%",
                          ),
                          _ResultStat(
                            label: "Time taken",
                            value: "${result!.timeTakenSeconds ~/ 60}m ${result!.timeTakenSeconds % 60}s",
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
                    onPressed: () => context.go(AppRoutes.studentTests),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: "Dashboard",
                    width: double.infinity,
                    isOutlined: true,
                    onPressed: () => context.go(AppRoutes.studentHome),
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
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha((0.7 * 255).round())),
        ),
      ],
    );
  }
}
